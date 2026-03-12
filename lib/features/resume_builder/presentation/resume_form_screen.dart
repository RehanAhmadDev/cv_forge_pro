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

    if (_resumeData.experienceList.isEmpty) _resumeData.experienceList.add(ExperienceItem());
    if (_resumeData.educationList.isEmpty) _resumeData.educationList.add(EducationItem());

    // ⬅️ Ab Tabs 3 ho gaye hain (Edit, Design, Preview)
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 2) { // 2 matlab Preview Tab
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
              duration: const Duration(seconds: 4)
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${widget.selectedTemplate} Editor', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade900,
        elevation: 0.5,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueGrey.shade900,
          labelColor: Colors.blueGrey.shade900,
          unselectedLabelColor: Colors.grey.shade500,
          isScrollable: true, // Tabs lambe ho gaye hain
          tabs: const [
            Tab(icon: Icon(Icons.edit_document), text: "Edit Details"),
            Tab(icon: Icon(Icons.palette), text: "Design"), // ⬅️ Naya Tab
            Tab(icon: Icon(Icons.remove_red_eye), text: "Live Preview")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Swipe to change band kiya taake sliders aaram se chalein
        children: [
          _EditDetailsTab(resumeData: _resumeData, pickImage: _pickImage),
          _DesignTab(resumeData: _resumeData, onUpdate: () => setState((){})), // ⬅️ Naya Customization Panel
          _PreviewTab(pdfController: _pdfController, handleSave: _handleSave),
        ],
      ),
    );
  }
}

// ===============================================
// 🌟 1. DESIGN / CUSTOMIZATION TAB (NEW)
// ===============================================
class _DesignTab extends StatefulWidget {
  final ResumeModel resumeData;
  final VoidCallback onUpdate;
  const _DesignTab({required this.resumeData, required this.onUpdate});

  @override
  State<_DesignTab> createState() => _DesignTabState();
}

class _DesignTabState extends State<_DesignTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Map<String, String>> themeColors = [
    {'name': 'Deep Blue', 'hex': '#1A237E'},
    {'name': 'Charcoal', 'hex': '#212121'},
    {'name': 'Crimson', 'hex': '#B71C1C'},
    {'name': 'Forest', 'hex': '#1B5E20'},
    {'name': 'Orange', 'hex': '#E65100'},
    {'name': 'Teal', 'hex': '#004D40'},
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Color Selection ---
          const Text('Theme Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: themeColors.map((c) {
              final colorValue = Color(int.parse(c['hex']!.replaceFirst('#', '0xFF')));
              final isSelected = widget.resumeData.themeColor == c['hex'];
              return GestureDetector(
                onTap: () {
                  setState(() => widget.resumeData.themeColor = c['hex']!);
                  widget.onUpdate();
                },
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.blueAccent, width: 4) : Border.all(color: Colors.white, width: 2),
                    boxShadow: [if (isSelected) const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),

          // --- Margin Slider ---
          const Text('Page Margins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Slider(
            value: widget.resumeData.pageMargin,
            min: 10.0, max: 60.0, divisions: 10,
            activeColor: Colors.blueGrey.shade800,
            label: widget.resumeData.pageMargin.toStringAsFixed(0),
            onChanged: (v) {
              setState(() => widget.resumeData.pageMargin = v);
              widget.onUpdate();
            },
          ),
          const Center(child: Text('Adjust spacing around the edges of your PDF', style: TextStyle(fontSize: 12, color: Colors.grey))),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // --- Heading Size Slider ---
          const Text('Heading Text Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Slider(
            value: widget.resumeData.headingTextSize,
            min: 14.0, max: 30.0, divisions: 16,
            activeColor: Colors.blueGrey.shade800,
            label: widget.resumeData.headingTextSize.toStringAsFixed(0),
            onChanged: (v) {
              setState(() => widget.resumeData.headingTextSize = v);
              widget.onUpdate();
            },
          ),

          const SizedBox(height: 20),

          // --- Body Size Slider ---
          const Text('Body Text Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Slider(
            value: widget.resumeData.bodyTextSize,
            min: 8.0, max: 16.0, divisions: 8,
            activeColor: Colors.blueGrey.shade600,
            label: widget.resumeData.bodyTextSize.toStringAsFixed(0),
            onChanged: (v) {
              setState(() => widget.resumeData.bodyTextSize = v);
              widget.onUpdate();
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ===============================================
// 2. EDIT DETAILS TAB (OLD - UNCHANGED)
// ===============================================
class _EditDetailsTab extends StatefulWidget {
  final ResumeModel resumeData;
  final VoidCallback pickImage;
  const _EditDetailsTab({required this.resumeData, required this.pickImage});

  @override
  State<_EditDetailsTab> createState() => _EditDetailsTabState();
}

class _EditDetailsTabState extends State<_EditDetailsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfilePic(),
          const SizedBox(height: 25),
          _buildPersonalCard(),
          const SizedBox(height: 20),
          _buildProfessionalCard(),
          const SizedBox(height: 20),
          _buildExperienceCard(),
          const SizedBox(height: 20),
          _buildEducationCard(),
          const SizedBox(height: 20),
          _buildProjectsCard(),
          const SizedBox(height: 20),
          _buildSocialCard(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfilePic() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.blueGrey.shade50,
            backgroundImage: widget.resumeData.imagePath != null ? FileImage(File(widget.resumeData.imagePath!)) : null,
            child: widget.resumeData.imagePath == null ? Icon(Icons.person_outline, size: 50, color: Colors.blueGrey.shade200) : null,
          ),
          GestureDetector(
            onTap: widget.pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blueGrey.shade800, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalCard() {
    return _buildCardWrapper(
      title: 'Personal Details',
      icon: Icons.person,
      children: [
        _buildField('Full Name', Icons.badge, (v) => widget.resumeData.fullName = v, initial: widget.resumeData.fullName),
        _buildField('Job Title', Icons.work_outline, (v) => widget.resumeData.jobTitle = v, initial: widget.resumeData.jobTitle),
        _buildField('Email', Icons.email_outlined, (v) => widget.resumeData.email = v, initial: widget.resumeData.email),
        _buildField('Phone', Icons.phone_outlined, (v) => widget.resumeData.phone = v, initial: widget.resumeData.phone),
        _buildField('Address', Icons.location_on_outlined, (v) => widget.resumeData.address = v, initial: widget.resumeData.address),
      ],
    );
  }

  Widget _buildProfessionalCard() {
    return _buildCardWrapper(
      title: 'Professional Info',
      icon: Icons.psychology,
      children: [
        _buildField('Skills (Comma separated)', Icons.star_border, (v) => widget.resumeData.skills = v, initial: widget.resumeData.skills),
        _buildField('Languages', Icons.language, (v) => widget.resumeData.languages = v, initial: widget.resumeData.languages),
        _buildField('Summary', Icons.edit_note, (v) => widget.resumeData.summary = v, maxLines: 3, initial: widget.resumeData.summary),
      ],
    );
  }

  Widget _buildExperienceCard() {
    return _buildCardWrapper(
      title: 'Work Experience',
      icon: Icons.business_center,
      children: [
        ...widget.resumeData.experienceList.asMap().entries.map((entry) {
          int i = entry.key;
          ExperienceItem exp = entry.value;
          return _buildDynamicItem(
            title: 'Job ${i + 1}',
            onDelete: () => setState(() => widget.resumeData.experienceList.removeAt(i)),
            fields: [
              _buildSmallField('Company', (v) => exp.company = v, initial: exp.company),
              _buildSmallField('Role', (v) => exp.role = v, initial: exp.role),
              _buildSmallField('Duration', (v) => exp.duration = v, initial: exp.duration),
              _buildSmallField('Description', (v) => exp.description = v, maxLines: 2, initial: exp.description),
            ],
          );
        }),
        TextButton.icon(onPressed: () => setState(() => widget.resumeData.experienceList.add(ExperienceItem())), icon: const Icon(Icons.add), label: const Text('Add Job')),
      ],
    );
  }

  Widget _buildEducationCard() {
    return _buildCardWrapper(
      title: 'Education',
      icon: Icons.school_outlined,
      children: [
        ...widget.resumeData.educationList.asMap().entries.map((entry) {
          int i = entry.key;
          EducationItem edu = entry.value;
          return _buildDynamicItem(
            title: 'Degree ${i + 1}',
            onDelete: () => setState(() => widget.resumeData.educationList.removeAt(i)),
            fields: [
              _buildSmallField('Institution', (v) => edu.institution = v, initial: edu.institution),
              _buildSmallField('Degree', (v) => edu.degree = v, initial: edu.degree),
              _buildSmallField('Year', (v) => edu.year = v, initial: edu.year),
              _buildSmallField('Grade', (v) => edu.grade = v, initial: edu.grade),
            ],
          );
        }),
        TextButton.icon(onPressed: () => setState(() => widget.resumeData.educationList.add(EducationItem())), icon: const Icon(Icons.add), label: const Text('Add Education')),
      ],
    );
  }

  Widget _buildProjectsCard() {
    return _buildCardWrapper(
      title: 'Projects',
      icon: Icons.web_asset,
      children: [
        ...widget.resumeData.projectList.asMap().entries.map((entry) {
          int i = entry.key;
          ProjectItem proj = entry.value;
          return _buildDynamicItem(
            title: 'Project ${i + 1}',
            onDelete: () => setState(() => widget.resumeData.projectList.removeAt(i)),
            fields: [
              _buildSmallField('Title', (v) => proj.title = v, initial: proj.title),
              _buildSmallField('Link', (v) => proj.link = v, initial: proj.link),
              _buildSmallField('Description', (v) => proj.description = v, maxLines: 2, initial: proj.description),
            ],
          );
        }),
        TextButton.icon(onPressed: () => setState(() => widget.resumeData.projectList.add(ProjectItem())), icon: const Icon(Icons.add), label: const Text('Add Project')),
      ],
    );
  }

  Widget _buildSocialCard() {
    return _buildCardWrapper(
      title: 'Social Links',
      icon: Icons.link,
      children: [
        _buildField('LinkedIn', Icons.connect_without_contact, (v) => widget.resumeData.linkedin = v, initial: widget.resumeData.linkedin),
        _buildField('GitHub', Icons.code, (v) => widget.resumeData.github = v, initial: widget.resumeData.github),
      ],
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildCardWrapper({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: Colors.blueGrey), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, IconData icon, Function(String) onChanged, {int maxLines = 1, String initial = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildSmallField(String label, Function(String) onChanged, {int maxLines = 1, String initial = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initial,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  Widget _buildDynamicItem({required String title, required VoidCallback onDelete, required List<Widget> fields}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete)]),
          ...fields,
        ],
      ),
    );
  }
}

// ===============================================
// 3. PREVIEW TAB
// ===============================================
class _PreviewTab extends StatelessWidget {
  final PdfControllerPinch pdfController;
  final VoidCallback handleSave;
  const _PreviewTab({required this.pdfController, required this.handleSave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Container(color: Colors.grey.shade300, child: PdfViewPinch(controller: pdfController))),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55)),
            icon: const Icon(Icons.download),
            label: const Text("Export as PDF"),
            onPressed: handleSave,
          ),
        ),
      ],
    );
  }
}