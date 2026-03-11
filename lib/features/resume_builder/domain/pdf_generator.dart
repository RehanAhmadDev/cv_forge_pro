import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/resume_model.dart';

class PdfGenerator {
  static Future<Uint8List> generateResume(ResumeModel inputData) async {
    final pdf = pw.Document();

    pw.MemoryImage? profileImage;
    if (inputData.imagePath != null && File(inputData.imagePath!).existsSync()) {
      final bytes = File(inputData.imagePath!).readAsBytesSync();
      profileImage = pw.MemoryImage(bytes);
    }

    // ⬅️ ASAL JADOO YAHAN HAI: Agar user ne kuch nahi likha, toh dummy data bhar do
    final data = ResumeModel(
      fullName: inputData.fullName.trim().isEmpty ? 'JONATHAN DOE' : inputData.fullName,
      jobTitle: inputData.jobTitle.trim().isEmpty ? 'Flutter Developer' : inputData.jobTitle,
      email: inputData.email.trim().isEmpty ? 'hello@jonathandoe.com' : inputData.email,
      phone: inputData.phone.trim().isEmpty ? '+92 300 1234567' : inputData.phone,
      address: inputData.address.trim().isEmpty ? 'Islamabad, Pakistan' : inputData.address,
      linkedin: inputData.linkedin.trim().isEmpty ? 'linkedin.com/in/jonathandoe' : inputData.linkedin,
      github: inputData.github.trim().isEmpty ? 'github.com/jonathandoe' : inputData.github,
      summary: inputData.summary.trim().isEmpty
          ? 'Passionate and results-driven Flutter Developer with extensive experience in developing scalable, cross-platform mobile applications. Proven ability to deliver high-quality, visually stunning products.'
          : inputData.summary,
      skills: inputData.skills.trim().isEmpty ? 'Flutter, Dart, REST APIs, Firebase, Git, BLoC' : inputData.skills,
      languages: inputData.languages.trim().isEmpty ? 'English (Professional), Urdu (Native)' : inputData.languages,
      selectedTemplate: inputData.selectedTemplate,
      imagePath: inputData.imagePath,
    );

    // Dummy Experience
    final validExp = inputData.experienceList.where((e) => e.company.trim().isNotEmpty || e.role.trim().isNotEmpty).toList();
    data.experienceList = validExp.isEmpty ? [
      ExperienceItem(role: 'Senior Mobile Developer', company: 'Tech Innovators', duration: 'Jan 2023 - Present', description: 'Leading the mobile app development team. Designed and deployed multiple high-performance apps.'),
      ExperienceItem(role: 'Flutter Developer', company: 'Creative Solutions', duration: 'Mar 2020 - Dec 2022', description: 'Developed robust cross-platform applications and integrated complex APIs.')
    ] : validExp;

    // Dummy Education
    final validEdu = inputData.educationList.where((e) => e.institution.trim().isNotEmpty || e.degree.trim().isNotEmpty).toList();
    data.educationList = validEdu.isEmpty ? [
      EducationItem(degree: 'Bachelor of Computer Science', institution: 'University of Engineering and Technology', year: '2016 - 2020', grade: '3.8 CGPA')
    ] : validEdu;

    // Dummy Projects
    final validProj = inputData.projectList.where((e) => e.title.trim().isNotEmpty).toList();
    data.projectList = validProj.isEmpty ? [
      ProjectItem(title: 'CV Forge Pro App', link: 'github.com/jonathandoe/cv_forge', description: 'A premium resume builder app featuring live PDF generation and Canva-like dynamic templates.')
    ] : validProj;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          pw.Widget design;
          switch (data.selectedTemplate) {
            case 'Executive':
              design = _buildUltraPremium(data, profileImage);
              break;
            case 'Professional':
              design = _buildProCanvaDesign(data, profileImage);
              break;
            case 'Creative':
              design = _buildCreativeCanvaDesign(data, profileImage);
              break;
            case 'Modern':
            case 'Minimalist':
            case 'Classic':
            default:
              design = _buildProCanvaDesign(data, profileImage);
              break;
          }

          return pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.topCenter,
            child: pw.Container(
              width: PdfPageFormat.a4.width,
              constraints: pw.BoxConstraints(minHeight: PdfPageFormat.a4.height),
              child: design,
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  // ==========================================
  // 🌟 1. ULTRA PREMIUM (3-COLOR GRADIENT & CUTS)
  // ==========================================
  static pw.Widget _buildUltraPremium(ResumeModel data, pw.MemoryImage? image) {
    final color1 = PdfColor.fromHex('#4158D0');
    final color2 = PdfColor.fromHex('#C850C0');
    final color3 = PdfColor.fromHex('#FFCC70');
    final darkText = PdfColor.fromHex('#1C1C1C');

    return pw.Container(
        width: PdfPageFormat.a4.width,
        height: PdfPageFormat.a4.height,
        child: pw.Stack(
            children: [
              pw.Positioned(
                top: -150, left: -100, right: -100,
                child: pw.Transform.rotate(
                  angle: -0.15,
                  child: pw.Container(
                    height: 400,
                    decoration: pw.BoxDecoration(
                        gradient: pw.LinearGradient(colors: [color1, color2, color3], begin: pw.Alignment.topLeft, end: pw.Alignment.bottomRight),
                        boxShadow: [pw.BoxShadow(color: PdfColors.black, blurRadius: 15, offset: const PdfPoint(0, 5))]
                    ),
                  ),
                ),
              ),
              pw.Positioned.fill(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.all(40),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Expanded(
                                      child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.SizedBox(height: 20),
                                            pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                                            pw.SizedBox(height: 5),
                                            pw.Text(data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: 16, color: PdfColors.white, letterSpacing: 3)),
                                            pw.SizedBox(height: 15),
                                            pw.Container(
                                                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: pw.BoxDecoration(color: const PdfColor(0, 0, 0, 0.3), borderRadius: pw.BorderRadius.circular(4)),
                                                child: pw.Column(
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    children: [
                                                      pw.Text('${data.phone}  |  ${data.email}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                                                      if (data.address.isNotEmpty) pw.Text(data.address, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                                                    ]
                                                )
                                            ),
                                          ]
                                      )
                                  ),
                                  if (image != null)
                                    pw.Container(
                                      width: 140, height: 140,
                                      decoration: pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          border: pw.Border.all(color: PdfColors.white, width: 4),
                                          boxShadow: [pw.BoxShadow(color: PdfColors.black, blurRadius: 10, offset: const PdfPoint(0, 5))],
                                          image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover)
                                      ),
                                    ),
                                ]
                            ),

                            pw.SizedBox(height: 40),

                            pw.Expanded(
                                child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                          flex: 6,
                                          child: pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                if (data.summary.isNotEmpty) ...[
                                                  _buildGradientTitle('PROFILE', color1, color2),
                                                  pw.Text(data.summary, style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: darkText)),
                                                  pw.SizedBox(height: 20),
                                                ],

                                                _buildGradientTitle('EXPERIENCE', color1, color2),
                                                _buildDynamicExperience(data.experienceList, color1),

                                                if (data.projectList.any((p) => p.title.isNotEmpty)) ...[
                                                  pw.SizedBox(height: 15),
                                                  _buildGradientTitle('PROJECTS', color1, color2),
                                                  _buildDynamicProjects(data.projectList, color1),
                                                ]
                                              ]
                                          )
                                      ),
                                      pw.SizedBox(width: 40),
                                      pw.Expanded(
                                          flex: 4,
                                          child: pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: [
                                                _buildGradientTitle('EDUCATION', color1, color2),
                                                _buildDynamicEducation(data.educationList, color1),

                                                pw.SizedBox(height: 20),

                                                if (data.skills.isNotEmpty) ...[
                                                  _buildGradientTitle('SKILLS', color1, color2),
                                                  ...data.skills.split(',').map((skill) {
                                                    if (skill.trim().isEmpty) return pw.SizedBox();
                                                    return pw.Padding(
                                                        padding: const pw.EdgeInsets.only(bottom: 8),
                                                        child: pw.Row(
                                                            children: [
                                                              pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color2, color3]), shape: pw.BoxShape.circle)),
                                                              pw.SizedBox(width: 10),
                                                              pw.Expanded(child: pw.Text(skill.trim(), style: pw.TextStyle(fontSize: 11, color: darkText))),
                                                            ]
                                                        )
                                                    );
                                                  }).toList(),
                                                  pw.SizedBox(height: 20),
                                                ],

                                                if (data.languages.isNotEmpty) ...[
                                                  _buildGradientTitle('LANGUAGES', color1, color2),
                                                  pw.Text(data.languages, style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: darkText)),
                                                ]
                                              ]
                                          )
                                      )
                                    ]
                                )
                            )
                          ]
                      )
                  )
              )
            ]
        )
    );
  }

  // ==========================================
  // 🌟 2. PROFESSIONAL (PRO CANVA STYLE)
  // ==========================================
  static pw.Widget _buildProCanvaDesign(ResumeModel data, pw.MemoryImage? image) {
    final primaryColor = PdfColor.fromHex('#1A237E');
    final accentColor = PdfColor.fromHex('#E8EAF6');

    return pw.Container(
        width: PdfPageFormat.a4.width,
        height: PdfPageFormat.a4.height,
        child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                  width: 220,
                  height: PdfPageFormat.a4.height,
                  color: primaryColor,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (image != null) ...[
                          pw.Container(
                            width: 120, height: 120,
                            decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border: pw.Border.all(color: PdfColors.white, width: 3),
                                image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover)
                            ),
                          ),
                          pw.SizedBox(height: 30),
                        ],

                        _buildDarkSidebarTitle('CONTACT'),
                        _buildContactItem('📞', data.phone),
                        _buildContactItem('✉️', data.email),
                        if (data.address.isNotEmpty) _buildContactItem('📍', data.address),
                        if (data.linkedin.isNotEmpty) _buildContactItem('🔗', data.linkedin),
                        if (data.github.isNotEmpty) _buildContactItem('💻', data.github),

                        pw.SizedBox(height: 30),

                        if (data.skills.isNotEmpty) ...[
                          _buildDarkSidebarTitle('SKILLS'),
                          ...data.skills.split(',').map((skill) {
                            if (skill.trim().isEmpty) return pw.SizedBox();
                            return pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 12),
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(skill.trim(), style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
                                      pw.SizedBox(height: 4),
                                      pw.Container(
                                          height: 4, width: double.infinity,
                                          decoration: pw.BoxDecoration(color: const PdfColor(1, 1, 1, 0.2), borderRadius: pw.BorderRadius.circular(2)),
                                          child: pw.Row(
                                              children: [
                                                pw.Expanded(flex: 85, child: pw.Container(decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(2)))),
                                                pw.Expanded(flex: 15, child: pw.SizedBox())
                                              ]
                                          )
                                      )
                                    ]
                                )
                            );
                          }).toList(),
                        ],

                        if (data.languages.isNotEmpty) ...[
                          pw.SizedBox(height: 20),
                          _buildDarkSidebarTitle('LANGUAGES'),
                          pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(data.languages, style: const pw.TextStyle(color: PdfColors.white, fontSize: 11, lineSpacing: 1.5))
                          )
                        ]
                      ]
                  )
              ),

              pw.Expanded(
                  child: pw.Container(
                      height: PdfPageFormat.a4.height,
                      color: PdfColors.white,
                      padding: const pw.EdgeInsets.all(40),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1.5)),
                            pw.SizedBox(height: 5),
                            pw.Text(data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600, letterSpacing: 2)),
                            pw.SizedBox(height: 25),

                            if (data.summary.isNotEmpty) ...[
                              pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.all(15),
                                decoration: pw.BoxDecoration(
                                    color: accentColor,
                                    borderRadius: pw.BorderRadius.circular(8),
                                    border: pw.Border.all(color: PdfColor(primaryColor.red, primaryColor.green, primaryColor.blue, 0.2))
                                ),
                                child: pw.Text(data.summary, style: pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey800, lineSpacing: 1.5)),
                              ),
                              pw.SizedBox(height: 25),
                            ],

                            pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                            pw.SizedBox(height: 10),
                            _buildDynamicExperience(data.experienceList, primaryColor),

                            pw.SizedBox(height: 15),

                            pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                            pw.SizedBox(height: 10),
                            _buildDynamicEducation(data.educationList, primaryColor),

                            if (data.projectList.any((p) => p.title.isNotEmpty)) ...[
                              pw.SizedBox(height: 15),
                              pw.Text('PROJECTS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                              pw.SizedBox(height: 10),
                              _buildDynamicProjects(data.projectList, primaryColor),
                            ]
                          ]
                      )
                  )
              )
            ]
        )
    );
  }

  // ==========================================
  // 🌟 3. CREATIVE (MODERN HEADER STYLE)
  // ==========================================
  static pw.Widget _buildCreativeCanvaDesign(ResumeModel data, pw.MemoryImage? image) {
    final darkColor = PdfColor.fromHex('#212121');
    final accentColor = PdfColor.fromHex('#FF6D00');

    return pw.Container(
        width: PdfPageFormat.a4.width,
        height: PdfPageFormat.a4.height,
        child: pw.Column(
            children: [
              pw.Container(
                  height: 180,
                  width: double.infinity,
                  color: darkColor,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 38, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                                  pw.SizedBox(height: 8),
                                  pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: 18, color: accentColor, letterSpacing: 1.5)),
                                ]
                            )
                        ),
                        if (image != null)
                          pw.Container(
                            width: 120, height: 120,
                            decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border: pw.Border.all(color: accentColor, width: 4),
                                image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover)
                            ),
                          ),
                      ]
                  )
              ),
              pw.Expanded(
                  child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                            width: 230,
                            height: double.infinity,
                            padding: const pw.EdgeInsets.all(30),
                            color: PdfColors.grey100,
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildCreativeSectionTitle('DETAILS', darkColor, accentColor),
                                  _buildDarkContactItem('Phone', data.phone),
                                  _buildDarkContactItem('Email', data.email),
                                  if (data.address.isNotEmpty) _buildDarkContactItem('Address', data.address),
                                  if (data.linkedin.isNotEmpty) _buildDarkContactItem('LinkedIn', data.linkedin),

                                  pw.SizedBox(height: 25),

                                  if (data.skills.isNotEmpty) ...[
                                    _buildCreativeSectionTitle('EXPERTISE', darkColor, accentColor),
                                    ...data.skills.split(',').map((skill) {
                                      if (skill.trim().isEmpty) return pw.SizedBox();
                                      return pw.Padding(
                                          padding: const pw.EdgeInsets.only(bottom: 8),
                                          child: pw.Row(
                                              children: [
                                                pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: accentColor, shape: pw.BoxShape.circle)),
                                                pw.SizedBox(width: 10),
                                                pw.Expanded(child: pw.Text(skill.trim(), style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800))),
                                              ]
                                          )
                                      );
                                    }).toList(),
                                  ],

                                  if (data.languages.isNotEmpty) ...[
                                    pw.SizedBox(height: 25),
                                    _buildCreativeSectionTitle('LANGUAGES', darkColor, accentColor),
                                    pw.Text(data.languages, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800, lineSpacing: 1.5))
                                  ]
                                ]
                            )
                        ),
                        pw.Expanded(
                            child: pw.Container(
                                height: double.infinity,
                                padding: const pw.EdgeInsets.all(40),
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      if (data.summary.isNotEmpty) ...[
                                        pw.Text('PROFILE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                        pw.SizedBox(height: 10),
                                        pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: PdfColors.black)),
                                        pw.SizedBox(height: 25),
                                      ],

                                      pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                      pw.SizedBox(height: 10),
                                      _buildDynamicExperience(data.experienceList, accentColor),

                                      pw.SizedBox(height: 15),

                                      pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                      pw.SizedBox(height: 10),
                                      _buildDynamicEducation(data.educationList, accentColor),

                                      if (data.projectList.any((p) => p.title.isNotEmpty)) ...[
                                        pw.SizedBox(height: 15),
                                        pw.Text('PROJECTS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                        pw.SizedBox(height: 10),
                                        _buildDynamicProjects(data.projectList, accentColor),
                                      ]
                                    ]
                                )
                            )
                        )
                      ]
                  )
              )
            ]
        )
    );
  }

  // ==========================================
  // --- HELPER WIDGETS FOR DYNAMIC LISTS ---
  // ==========================================

  static pw.Widget _buildGradientTitle(String text, PdfColor c1, PdfColor c2) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(text, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: c1)),
          pw.SizedBox(height: 5),
          pw.Container(height: 3, width: 40, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [c1, c2]))),
          pw.SizedBox(height: 15),
        ]
    );
  }

  static pw.Widget _buildCreativeSectionTitle(String text, PdfColor dark, PdfColor accent) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(text, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: dark)),
          pw.SizedBox(height: 5),
          pw.Container(height: 3, width: 30, color: accent),
          pw.SizedBox(height: 15),
        ]
    );
  }

  static pw.Widget _buildDarkSidebarTitle(String text) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2))),
          pw.SizedBox(height: 5),
          pw.Divider(color: PdfColors.white, thickness: 1),
          pw.SizedBox(height: 15),
        ]
    );
  }

  static pw.Widget _buildDynamicExperience(List<ExperienceItem> items, PdfColor color) {
    final validItems = items.where((e) => e.company.isNotEmpty || e.role.isNotEmpty).toList();
    if (validItems.isEmpty) return pw.SizedBox();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: validItems.map((item) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 15),
              padding: const pw.EdgeInsets.only(left: 15),
              decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColor(color.red, color.green, color.blue, 0.4), width: 2))),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.role.isEmpty ? 'Role' : item.role, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 2),
                    pw.Text('${item.company.isEmpty ? 'Company' : item.company}  |  ${item.duration}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
                    if (item.description.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(item.description, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: PdfColor(0, 0, 0, 0.87))),
                    ]
                  ]
              )
          );
        }).toList()
    );
  }

  static pw.Widget _buildDynamicEducation(List<EducationItem> items, PdfColor color) {
    final validItems = items.where((e) => e.institution.isNotEmpty || e.degree.isNotEmpty).toList();
    if (validItems.isEmpty) return pw.SizedBox();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: validItems.map((item) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.only(left: 15),
              decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColor(color.red, color.green, color.blue, 0.4), width: 2))),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.degree.isEmpty ? 'Degree' : item.degree, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 2),
                    pw.Text('${item.institution} ${item.year.isNotEmpty ? " | " + item.year : ""}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    if (item.grade.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text('Grade / CGPA: ${item.grade}', style: const pw.TextStyle(fontSize: 10, color: PdfColor(0, 0, 0, 0.87))),
                    ]
                  ]
              )
          );
        }).toList()
    );
  }

  static pw.Widget _buildDynamicProjects(List<ProjectItem> items, PdfColor color) {
    final validItems = items.where((e) => e.title.isNotEmpty).toList();
    if (validItems.isEmpty) return pw.SizedBox();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: validItems.map((item) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.only(left: 15),
              decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColor(color.red, color.green, color.blue, 0.4), width: 2))),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    if (item.link.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(item.link, style: pw.TextStyle(fontSize: 9, color: PdfColors.blue800, decoration: pw.TextDecoration.underline)),
                    ],
                    if (item.description.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(item.description, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5, color: PdfColor(0, 0, 0, 0.87))),
                    ]
                  ]
              )
          );
        }).toList()
    );
  }

  static pw.Widget _buildContactItem(String icon, String text) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Row(
            children: [
              pw.Text(icon, style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10))),
            ]
        )
    );
  }

  static pw.Widget _buildDarkContactItem(String label, String value) {
    if (value.isEmpty) return pw.SizedBox();
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label.toUpperCase(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.SizedBox(height: 2),
              pw.Text(value, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey900, fontWeight: pw.FontWeight.bold)),
            ]
        )
    );
  }

  static Future<String?> savePdfToDevice({required Uint8List bytes, required String fileName}) async {
    try {
      if (Platform.isAndroid) {
        if (!await Permission.storage.request().isGranted && !await Permission.manageExternalStorage.request().isGranted) return null;
      }
      Directory? directory = Platform.isAndroid ? Directory('/storage/emulated/0/Download/CV_Forge') : Directory('${(await getApplicationDocumentsDirectory()).path}/CV_Forge');
      if (!await directory.exists()) await directory.create(recursive: true);
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}