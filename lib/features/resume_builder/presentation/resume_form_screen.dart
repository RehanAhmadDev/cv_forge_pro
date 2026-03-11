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

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        FocusScope.of(context).unfocus(); // Keyboard hide karne ke liye
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

  // ⬅️ Naya Custom Premium TextField
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

  // ⬅️ Section Header UI
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light premium background
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
                // Profile Picture Section
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Professional Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]),
                  child: Column(
                    children: [
                      _buildSectionHeader('Professional Info', Icons.business_center),
                      _buildPremiumTextField(label: 'Work Experience', icon: Icons.history, maxLines: 3, onChanged: (v) => _resumeData.experience = v),
                      _buildPremiumTextField(label: 'Education', icon: Icons.school_outlined, maxLines: 2, onChanged: (v) => _resumeData.education = v),
                      _buildPremiumTextField(label: 'Skills (Comma separated)', icon: Icons.star_border, onChanged: (v) => _resumeData.skills = v),
                      _buildPremiumTextField(label: 'Professional Summary', icon: Icons.edit_note, maxLines: 3, onChanged: (v) => _resumeData.summary = v),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card 3: Social Links
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
                    color: Colors.grey.shade300, // PDF background dark kiya hai taake white page highlight ho
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