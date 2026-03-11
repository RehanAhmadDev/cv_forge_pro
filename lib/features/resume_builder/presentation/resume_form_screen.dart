import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:image_picker/image_picker.dart';
import '../data/resume_model.dart';
import '../domain/pdf_generator.dart';

class ResumeFormScreen extends StatefulWidget {
  final String selectedTemplate;

  const ResumeFormScreen({super.key, required this.selectedTemplate});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> with SingleTickerProviderStateMixin {
  final ResumeModel _resumeData = ResumeModel();

  late PdfControllerPinch _pdfController;
  late TabController _tabController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _resumeData.selectedTemplate = widget.selectedTemplate;

    // Default 1 khali item add kar dete hain taake form form lagay
    if (_resumeData.experienceList.isEmpty) _resumeData.experienceList.add(ExperienceItem());
    if (_resumeData.educationList.isEmpty) _resumeData.educationList.add(EducationItem());

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        FocusScope.of(context).unfocus();
        _updatePreview();
      }
    });

    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(PdfGenerator.generateResume(_resumeData)),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _resumeData.imagePath = image.path;
      });
      _updatePreview();
    }
  }

  Future<void> _updatePreview() async {
    final pdfBytes = await PdfGenerator.generateResume(_resumeData);
    _pdfController.loadDocument(PdfDocument.openData(pdfBytes));
  }

  Future<void> _handleSave() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving PDF...')));
    try {
      final pdfBytes = await PdfGenerator.generateResume(_resumeData);
      final fileName = '${_resumeData.fullName.isNotEmpty ? _resumeData.fullName.replaceAll(' ', '_') : 'My'}_Resume';
      final savedPath = await PdfGenerator.savePdfToDevice(bytes: pdfBytes, fileName: fileName);

      if (savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('✅ Auto-Saved at:\n$savedPath', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 4)
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // --- HELPER UI COMPONENTS ---
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey.shade800, size: 24),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade900)),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({required String label, required IconData icon, required Function(String) onChanged, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade400),
          prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 22),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blueGrey.shade600, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildDynamicTextField({required String label, required Function(String) onChanged, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blueGrey.shade400, width: 1)),
        ),
      ),
    );
  }

  // --- DYNAMIC SECTIONS ---
  Widget _buildExperienceSection() {
    return Column(
      children: [
        ..._resumeData.experienceList.asMap().entries.map((entry) {
          int index = entry.key;
          ExperienceItem exp = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Job ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => setState(() => _resumeData.experienceList.removeAt(index)),
                    )
                  ],
                ),
                _buildDynamicTextField(label: 'Company Name', onChanged: (v) => exp.company = v),
                _buildDynamicTextField(label: 'Job Role', onChanged: (v) => exp.role = v),
                _buildDynamicTextField(label: 'Duration (e.g. Jan 2023 - Present)', onChanged: (v) => exp.duration = v),
                _buildDynamicTextField(label: 'Description / Responsibilities', maxLines: 2, onChanged: (v) => exp.description = v),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => _resumeData.experienceList.add(ExperienceItem())),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Another Job'),
        )
      ],
    );
  }

  Widget _buildEducationSection() {
    return Column(
      children: [
        ..._resumeData.educationList.asMap().entries.map((entry) {
          int index = entry.key;
          EducationItem edu = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Degree ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => setState(() => _resumeData.educationList.removeAt(index)),
                    )
                  ],
                ),
                _buildDynamicTextField(label: 'Institution / University', onChanged: (v) => edu.institution = v),
                _buildDynamicTextField(label: 'Degree (e.g. BSCS)', onChanged: (v) => edu.degree = v),
                _buildDynamicTextField(label: 'Year of Graduation', onChanged: (v) => edu.year = v),
                _buildDynamicTextField(label: 'Grade / CGPA', onChanged: (v) => edu.grade = v),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => _resumeData.educationList.add(EducationItem())),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Another Degree'),
        )
      ],
    );
  }

  Widget _buildProjectSection() {
    return Column(
      children: [
        ..._resumeData.projectList.asMap().entries.map((entry) {
          int index = entry.key;
          ProjectItem proj = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Project ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => setState(() => _resumeData.projectList.removeAt(index)),
                    )
                  ],
                ),
                _buildDynamicTextField(label: 'Project Title', onChanged: (v) => proj.title = v),
                _buildDynamicTextField(label: 'Description', maxLines: 2, onChanged: (v) => proj.description = v),
                _buildDynamicTextField(label: 'Project Link (Optional)', onChanged: (v) => proj.link = v),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => _resumeData.projectList.add(ProjectItem())),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add A Project'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${widget.selectedTemplate} Editor', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade900,
        elevation: 0.5,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueGrey.shade900,
          indicatorWeight: 3,
          labelColor: Colors.blueGrey.shade900,
          unselectedLabelColor: Colors.grey.shade500,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.edit_document), text: "Edit Details"),
            Tab(icon: Icon(Icons.remove_red_eye), text: "Live Preview")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          // --- TAB 1: PREMIUM FORM ---
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.blueGrey.shade50,
                          backgroundImage: _resumeData.imagePath != null ? FileImage(File(_resumeData.imagePath!)) : null,
                          child: _resumeData.imagePath == null
                              ? Icon(Icons.person_outline, size: 50, color: Colors.blueGrey.shade200)
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blueGrey.shade800, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Card 1: Personal Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Personal Details', Icons.person),
                      _buildPremiumTextField(label: 'Full Name', icon: Icons.badge, onChanged: (v) => _resumeData.fullName = v),
                      _buildPremiumTextField(label: 'Job Title', icon: Icons.work_outline, onChanged: (v) => _resumeData.jobTitle = v),
                      _buildPremiumTextField(label: 'Email Address', icon: Icons.email_outlined, onChanged: (v) => _resumeData.email = v),
                      _buildPremiumTextField(label: 'Phone Number', icon: Icons.phone_outlined, onChanged: (v) => _resumeData.phone = v),
                      _buildPremiumTextField(label: 'Address / Location', icon: Icons.location_on_outlined, onChanged: (v) => _resumeData.address = v),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Professional Details (Skills, Lang, Summary)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Professional Info', Icons.psychology),
                      _buildPremiumTextField(label: 'Skills (Comma separated)', icon: Icons.star_border, onChanged: (v) => _resumeData.skills = v),
                      _buildPremiumTextField(label: 'Languages (Comma separated)', icon: Icons.language, onChanged: (v) => _resumeData.languages = v),
                      _buildPremiumTextField(label: 'Professional Summary', icon: Icons.edit_note, maxLines: 3, onChanged: (v) => _resumeData.summary = v),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 3: Experience (Dynamic)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Work Experience', Icons.business_center),
                      _buildExperienceSection(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 4: Education (Dynamic)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Education', Icons.school_outlined),
                      _buildEducationSection(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 5: Projects / Portfolio (Dynamic)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Projects / Portfolio', Icons.web_asset),
                      _buildProjectSection(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 6: Social Links
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Social Links', Icons.link),
                      _buildPremiumTextField(label: 'LinkedIn Profile', icon: Icons.connect_without_contact, onChanged: (v) => _resumeData.linkedin = v),
                      _buildPremiumTextField(label: 'GitHub Profile', icon: Icons.code, onChanged: (v) => _resumeData.github = v),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // --- TAB 2: LIVE PREVIEW ---
          Column(
            children: [
              Expanded(
                  child: Container(
                    color: Colors.grey.shade300,
                    child: PdfViewPinch(controller: _pdfController),
                  )
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade900,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Export as PDF", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}