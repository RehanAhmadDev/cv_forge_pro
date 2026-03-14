import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/resume_model.dart';
import '../domain/pdf_generator.dart';

class ResumeFormScreen extends StatefulWidget {
  // ⬅️ ASAL FIX: Yahan ab hum poora ResumeModel catch kar rahe hain
  final ResumeModel resumeData;

  const ResumeFormScreen({super.key, required this.resumeData});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> with SingleTickerProviderStateMixin {
  late ResumeModel _resumeData;
  late PdfControllerPinch _pdfController;
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        FocusScope.of(context).unfocus();
        _updatePreview();
      }
    });

    _loadSavedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      // ⬅️ ASAL FIX: Nayi CV ya Purani CV ka data Model se uthaya
      _resumeData = widget.resumeData;

      if (_resumeData.experienceList.isEmpty) _resumeData.experienceList.add(ExperienceItem());
      if (_resumeData.educationList.isEmpty) _resumeData.educationList.add(EducationItem());

      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(await PdfGenerator.generateResume(_resumeData)),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Data load error: $e");
      setState(() => _isLoading = false);
    }
  }

  // ⬅️ ASAL FIX: Auto Save ab poori CV List (Dashboard) ko update karega
  Future<void> _autoSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profilesJson = prefs.getString('cv_profiles_list');
      List<ResumeModel> allProfiles = [];

      if (profilesJson != null) {
        final List<dynamic> decodedList = json.decode(profilesJson);
        allProfiles = decodedList.map((item) => ResumeModel.fromJson(item)).toList();
      }

      // Check karein ke ye CV (is ID ki) list mein kahan hai?
      int index = allProfiles.indexWhere((p) => p.id == _resumeData.id);

      if (index != -1) {
        allProfiles[index] = _resumeData; // Purani CV ko Update karo
      } else {
        allProfiles.add(_resumeData); // Nayi CV ko Add karo
      }

      // List ko wapas JSON mein convert karke save kar do
      final String encodedList = json.encode(allProfiles.map((e) => e.toJson()).toList());
      await prefs.setString('cv_profiles_list', encodedList);
    } catch (e) {
      debugPrint("Auto-save error: $e");
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _resumeData.imagePath = image.path;
      });
      _autoSave();
      _updatePreview();
    }
  }

  Future<void> _updatePreview() async {
    final pdfBytes = await PdfGenerator.generateResume(_resumeData);
    _pdfController.loadDocument(PdfDocument.openData(pdfBytes));
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Please fill all required fields first!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
      );
      return;
    }

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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Colors.blueGrey)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        // Yahan Editor ke uper us CV ka naam aayega
        title: Text('${_resumeData.profileName} Editor', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade900,
        elevation: 0.5,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueGrey.shade900,
          labelColor: Colors.blueGrey.shade900,
          unselectedLabelColor: Colors.grey.shade500,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.edit_document), text: "Edit Details"),
            Tab(icon: Icon(Icons.palette), text: "Design"),
            Tab(icon: Icon(Icons.remove_red_eye), text: "Live Preview")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _EditDetailsTab(
            resumeData: _resumeData,
            pickImage: _pickImage,
            onDataChanged: _autoSave,
            formKey: _formKey,
          ),
          _DesignTab(
              resumeData: _resumeData,
              onUpdate: () {
                setState((){});
                _autoSave();
              }
          ),
          _PreviewTab(
            pdfController: _pdfController,
            handleSave: _handleSave,
            resumeData: _resumeData,
            tabController: _tabController,
          ),
        ],
      ),
    );
  }
}

// ===============================================
// 1. DESIGN / CUSTOMIZATION TAB
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

  final List<String> fontStyles = [
    'Roboto', 'Montserrat', 'Poppins', 'Open Sans', 'Oswald',
    'Lato', 'Raleway', 'Ubuntu', 'Merriweather', 'Playfair Display',
    'Nunito', 'Lora'
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

          const Text('Typography (Font Style)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: fontStyles.map((font) {
              final isSelected = widget.resumeData.fontStyle == font;
              return ChoiceChip(
                label: Text(
                  font,
                  style: GoogleFonts.getFont(
                    font,
                    textStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.blueGrey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.blueGrey.shade800,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.blueGrey.shade800 : Colors.grey.shade300)),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => widget.resumeData.fontStyle = font);
                    widget.onUpdate();
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),

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

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

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
// 2. EDIT DETAILS TAB
// ===============================================
class _EditDetailsTab extends StatefulWidget {
  final ResumeModel resumeData;
  final VoidCallback pickImage;
  final VoidCallback onDataChanged;
  final GlobalKey<FormState> formKey;
  const _EditDetailsTab({required this.resumeData, required this.pickImage, required this.onDataChanged, required this.formKey});

  @override
  State<_EditDetailsTab> createState() => _EditDetailsTabState();
}

class _EditDetailsTabState extends State<_EditDetailsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
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
        _buildField('Full Name', Icons.badge, (v) => widget.resumeData.fullName = v, initial: widget.resumeData.fullName, isRequired: true),
        _buildField('Job Title', Icons.work_outline, (v) => widget.resumeData.jobTitle = v, initial: widget.resumeData.jobTitle, isRequired: true),
        _buildField('Email', Icons.email_outlined, (v) => widget.resumeData.email = v, initial: widget.resumeData.email, keyboardType: TextInputType.emailAddress, textCapitalization: TextCapitalization.none, isRequired: true),
        _buildField('Phone', Icons.phone_outlined, (v) => widget.resumeData.phone = v, initial: widget.resumeData.phone, keyboardType: TextInputType.phone, isRequired: true),
        _buildField('Address', Icons.location_on_outlined, (v) => widget.resumeData.address = v, initial: widget.resumeData.address),
      ],
    );
  }

  Widget _buildProfessionalCard() {
    return _buildCardWrapper(
      title: 'Professional Info',
      icon: Icons.psychology,
      children: [
        _buildField('Skills (Comma separated)', Icons.star_border, (v) => widget.resumeData.skills = v, initial: widget.resumeData.skills, isRequired: true),
        _buildField('Languages', Icons.language, (v) => widget.resumeData.languages = v, initial: widget.resumeData.languages),
        _buildField('Summary', Icons.edit_note, (v) => widget.resumeData.summary = v, maxLines: 3, initial: widget.resumeData.summary, textInputAction: TextInputAction.newline, textCapitalization: TextCapitalization.sentences),
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
            onDelete: () {
              setState(() => widget.resumeData.experienceList.removeAt(i));
              widget.onDataChanged();
            },
            fields: [
              _buildSmallField('Company', (v) => exp.company = v, initial: exp.company),
              _buildSmallField('Role', (v) => exp.role = v, initial: exp.role),
              _buildSmallField('Duration', (v) => exp.duration = v, initial: exp.duration),
              _buildSmallField('Description', (v) => exp.description = v, maxLines: 2, initial: exp.description, textInputAction: TextInputAction.newline, textCapitalization: TextCapitalization.sentences),
            ],
          );
        }),
        TextButton.icon(
            onPressed: () {
              setState(() => widget.resumeData.experienceList.add(ExperienceItem()));
              widget.onDataChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Job')
        ),
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
            onDelete: () {
              setState(() => widget.resumeData.educationList.removeAt(i));
              widget.onDataChanged();
            },
            fields: [
              _buildSmallField('Institution', (v) => edu.institution = v, initial: edu.institution),
              _buildSmallField('Degree', (v) => edu.degree = v, initial: edu.degree),
              _buildSmallField('Year', (v) => edu.year = v, initial: edu.year),
              _buildSmallField('Grade', (v) => edu.grade = v, initial: edu.grade),
            ],
          );
        }),
        TextButton.icon(
            onPressed: () {
              setState(() => widget.resumeData.educationList.add(EducationItem()));
              widget.onDataChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Education')
        ),
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
            onDelete: () {
              setState(() => widget.resumeData.projectList.removeAt(i));
              widget.onDataChanged();
            },
            fields: [
              _buildSmallField('Title', (v) => proj.title = v, initial: proj.title),
              _buildSmallField('Link', (v) => proj.link = v, initial: proj.link, keyboardType: TextInputType.url, textCapitalization: TextCapitalization.none),
              _buildSmallField('Description', (v) => proj.description = v, maxLines: 2, initial: proj.description, textInputAction: TextInputAction.newline, textCapitalization: TextCapitalization.sentences),
            ],
          );
        }),
        TextButton.icon(
            onPressed: () {
              setState(() => widget.resumeData.projectList.add(ProjectItem()));
              widget.onDataChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Project')
        ),
      ],
    );
  }

  Widget _buildSocialCard() {
    return _buildCardWrapper(
      title: 'Social Links',
      icon: Icons.link,
      children: [
        _buildField('LinkedIn', Icons.connect_without_contact, (v) => widget.resumeData.linkedin = v, initial: widget.resumeData.linkedin, keyboardType: TextInputType.url, textCapitalization: TextCapitalization.none),
        _buildField('GitHub', Icons.code, (v) => widget.resumeData.github = v, initial: widget.resumeData.github, keyboardType: TextInputType.url, textCapitalization: TextCapitalization.none),
      ],
    );
  }

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

  Widget _buildField(String label, IconData icon, Function(String) onChanged, {
    int maxLines = 1,
    String initial = '',
    TextInputType keyboardType = TextInputType.name,
    TextCapitalization textCapitalization = TextCapitalization.words,
    TextInputAction textInputAction = TextInputAction.next,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please enter your $label';
          }
          return null;
        },
        onChanged: (v) {
          onChanged(v);
          widget.onDataChanged();
        },
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildSmallField(String label, Function(String) onChanged, {
    int maxLines = 1,
    String initial = '',
    TextInputType keyboardType = TextInputType.name,
    TextCapitalization textCapitalization = TextCapitalization.words,
    TextInputAction textInputAction = TextInputAction.next,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initial,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Required';
          }
          return null;
        },
        onChanged: (v) {
          onChanged(v);
          widget.onDataChanged();
        },
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
// 3. PREVIEW TAB (WITH LOCK FEATURE)
// ===============================================
class _PreviewTab extends StatelessWidget {
  final PdfControllerPinch pdfController;
  final VoidCallback handleSave;
  final ResumeModel resumeData;
  final TabController tabController;

  const _PreviewTab({
    required this.pdfController,
    required this.handleSave,
    required this.resumeData,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    bool isReady = resumeData.fullName.trim().isNotEmpty &&
        resumeData.jobTitle.trim().isNotEmpty &&
        resumeData.email.trim().isNotEmpty &&
        resumeData.phone.trim().isNotEmpty;

    if (!isReady) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.blueGrey.shade300),
            const SizedBox(height: 20),
            Text('Preview Locked', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please fill in your Full Name, Job Title, Email, and Phone number in the Edit tab to unlock your PDF Preview.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () => tabController.animateTo(0),
              icon: const Icon(Icons.edit),
              label: const Text('Go to Edit Details'),
            )
          ],
        ),
      );
    }

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