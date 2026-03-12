import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import '../data/resume_model.dart';

class PdfGenerator {
  static Future<Uint8List> generateResume(ResumeModel inputData) async {
    final pdf = pw.Document();

    pw.MemoryImage? profileImage;
    if (inputData.imagePath != null && File(inputData.imagePath!).existsSync()) {
      final bytes = File(inputData.imagePath!).readAsBytesSync();
      profileImage = pw.MemoryImage(bytes);
    }

    pw.Font baseFont;
    pw.Font boldFont;

    // ⬅️ NAYA: 12 Fonts ki loading conditions add ho gayi hain
    switch (inputData.fontStyle) {
      case 'Montserrat':
        baseFont = await PdfGoogleFonts.montserratRegular();
        boldFont = await PdfGoogleFonts.montserratBold();
        break;
      case 'Poppins':
        baseFont = await PdfGoogleFonts.poppinsRegular();
        boldFont = await PdfGoogleFonts.poppinsBold();
        break;
      case 'Open Sans':
        baseFont = await PdfGoogleFonts.openSansRegular();
        boldFont = await PdfGoogleFonts.openSansBold();
        break;
      case 'Oswald':
        baseFont = await PdfGoogleFonts.oswaldRegular();
        boldFont = await PdfGoogleFonts.oswaldBold();
        break;
      case 'Lato':
        baseFont = await PdfGoogleFonts.latoRegular();
        boldFont = await PdfGoogleFonts.latoBold();
        break;
      case 'Raleway':
        baseFont = await PdfGoogleFonts.ralewayRegular();
        boldFont = await PdfGoogleFonts.ralewayBold();
        break;
      case 'Ubuntu':
        baseFont = await PdfGoogleFonts.ubuntuRegular();
        boldFont = await PdfGoogleFonts.ubuntuBold();
        break;
      case 'Merriweather':
        baseFont = await PdfGoogleFonts.merriweatherRegular();
        boldFont = await PdfGoogleFonts.merriweatherBold();
        break;
      case 'Playfair Display':
        baseFont = await PdfGoogleFonts.playfairDisplayRegular();
        boldFont = await PdfGoogleFonts.playfairDisplayBold();
        break;
      case 'Nunito':
        baseFont = await PdfGoogleFonts.nunitoRegular();
        boldFont = await PdfGoogleFonts.nunitoBold();
        break;
      case 'Lora':
        baseFont = await PdfGoogleFonts.loraRegular();
        boldFont = await PdfGoogleFonts.loraBold();
        break;
      case 'Roboto':
      default:
        baseFont = await PdfGoogleFonts.robotoRegular();
        boldFont = await PdfGoogleFonts.robotoBold();
        break;
    }

    final myTheme = pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
    );

    final data = ResumeModel(
      fullName: inputData.fullName,
      jobTitle: inputData.jobTitle,
      email: inputData.email,
      phone: inputData.phone,
      address: inputData.address,
      linkedin: inputData.linkedin,
      github: inputData.github,
      summary: inputData.summary,
      skills: inputData.skills,
      languages: inputData.languages,
      selectedTemplate: inputData.selectedTemplate,
      imagePath: inputData.imagePath,
      themeColor: inputData.themeColor,
      pageMargin: inputData.pageMargin,
      headingTextSize: inputData.headingTextSize,
      bodyTextSize: inputData.bodyTextSize,
      fontStyle: inputData.fontStyle,
    );

    data.experienceList = inputData.experienceList.where((e) => e.company.trim().isNotEmpty || e.role.trim().isNotEmpty).toList();
    data.educationList = inputData.educationList.where((e) => e.institution.trim().isNotEmpty || e.degree.trim().isNotEmpty).toList();
    data.projectList = inputData.projectList.where((e) => e.title.trim().isNotEmpty).toList();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: myTheme,
          margin: pw.EdgeInsets.zero,
          pageFormat: PdfPageFormat.a4,
        ),
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
  // 🌟 1. ULTRA PREMIUM
  // ==========================================
  static pw.Widget _buildUltraPremium(ResumeModel data, pw.MemoryImage? image) {
    final color1 = PdfColor.fromHex(data.themeColor);
    final color2 = PdfColor.fromHex('#C850C0');
    final color3 = PdfColor.fromHex('#FFCC70');
    final darkText = PdfColor.fromHex('#1C1C1C');
    final double hSize = data.headingTextSize;
    final double bSize = data.bodyTextSize;

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
                    ),
                  ),
                ),
              ),
              pw.Positioned.fill(
                  child: pw.Padding(
                      padding: pw.EdgeInsets.all(data.pageMargin),
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
                                            pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: hSize * 2, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                                            if (data.jobTitle.isNotEmpty) ...[
                                              pw.SizedBox(height: 5),
                                              pw.Text(data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: hSize * 0.9, color: PdfColors.white, letterSpacing: 3)),
                                            ],
                                            pw.SizedBox(height: 15),
                                            pw.Container(
                                                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: pw.BoxDecoration(color: const PdfColor(0, 0, 0, 0.3), borderRadius: pw.BorderRadius.circular(4)),
                                                child: pw.Column(
                                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                    children: [
                                                      pw.Text('${data.phone}  |  ${data.email}', style: pw.TextStyle(color: PdfColors.white, fontSize: bSize - 1)),
                                                      if (data.address.isNotEmpty) pw.Text(data.address, style: pw.TextStyle(color: PdfColors.white, fontSize: bSize - 1)),
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
                                                  _buildGradientTitle('PROFILE', color1, color2, hSize),
                                                  pw.Text(data.summary, style: pw.TextStyle(fontSize: bSize, lineSpacing: 1.5, color: darkText)),
                                                  pw.SizedBox(height: 20),
                                                ],

                                                if (data.experienceList.isNotEmpty) ...[
                                                  _buildGradientTitle('EXPERIENCE', color1, color2, hSize),
                                                  _buildDynamicExperience(data.experienceList, color1, bSize),
                                                ],

                                                if (data.projectList.isNotEmpty) ...[
                                                  pw.SizedBox(height: 15),
                                                  _buildGradientTitle('PROJECTS', color1, color2, hSize),
                                                  _buildDynamicProjects(data.projectList, color1, bSize),
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
                                                if (data.educationList.isNotEmpty) ...[
                                                  _buildGradientTitle('EDUCATION', color1, color2, hSize),
                                                  _buildDynamicEducation(data.educationList, color1, bSize),
                                                  pw.SizedBox(height: 20),
                                                ],

                                                if (data.skills.isNotEmpty) ...[
                                                  _buildGradientTitle('SKILLS', color1, color2, hSize),
                                                  ...data.skills.split(',').map((skill) {
                                                    if (skill.trim().isEmpty) return pw.SizedBox();
                                                    return pw.Padding(
                                                        padding: const pw.EdgeInsets.only(bottom: 8),
                                                        child: pw.Row(
                                                            children: [
                                                              pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color2, color3]), shape: pw.BoxShape.circle)),
                                                              pw.SizedBox(width: 10),
                                                              pw.Expanded(child: pw.Text(skill.trim(), style: pw.TextStyle(fontSize: bSize, color: darkText))),
                                                            ]
                                                        )
                                                    );
                                                  }).toList(),
                                                  pw.SizedBox(height: 20),
                                                ],

                                                if (data.languages.isNotEmpty) ...[
                                                  _buildGradientTitle('LANGUAGES', color1, color2, hSize),
                                                  pw.Text(data.languages, style: pw.TextStyle(fontSize: bSize, lineSpacing: 1.5, color: darkText)),
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
  // 🌟 2. PROFESSIONAL
  // ==========================================
  static pw.Widget _buildProCanvaDesign(ResumeModel data, pw.MemoryImage? image) {
    final primaryColor = PdfColor.fromHex(data.themeColor);
    final accentColor = PdfColor.fromHex('#E8EAF6');
    final textGreyColor = PdfColor.fromHex('#757575');
    final darkBlueGreyColor = PdfColor.fromHex('#37474F');
    final double hSize = data.headingTextSize;
    final double bSize = data.bodyTextSize;

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
                  padding: pw.EdgeInsets.symmetric(horizontal: data.pageMargin / 2, vertical: data.pageMargin),
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

                        _buildDarkSidebarTitle('CONTACT', hSize),
                        _buildContactItem('📞', data.phone, bSize),
                        _buildContactItem('✉️', data.email, bSize),
                        if (data.address.isNotEmpty) _buildContactItem('📍', data.address, bSize),
                        if (data.linkedin.isNotEmpty) _buildContactItem('🔗', data.linkedin, bSize),
                        if (data.github.isNotEmpty) _buildContactItem('💻', data.github, bSize),

                        pw.SizedBox(height: 30),

                        if (data.skills.isNotEmpty) ...[
                          _buildDarkSidebarTitle('SKILLS', hSize),
                          ...data.skills.split(',').map((skill) {
                            if (skill.trim().isEmpty) return pw.SizedBox();
                            return pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 12),
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(skill.trim(), style: pw.TextStyle(color: PdfColors.white, fontSize: bSize)),
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
                          _buildDarkSidebarTitle('LANGUAGES', hSize),
                          pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(data.languages, style: pw.TextStyle(color: PdfColors.white, fontSize: bSize, lineSpacing: 1.5))
                          )
                        ]
                      ]
                  )
              ),

              pw.Expanded(
                  child: pw.Container(
                      height: PdfPageFormat.a4.height,
                      color: PdfColors.white,
                      padding: pw.EdgeInsets.all(data.pageMargin),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: hSize * 2, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1.5)),
                            if (data.jobTitle.isNotEmpty) ...[
                              pw.SizedBox(height: 5),
                              pw.Text(data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: hSize * 0.9, color: textGreyColor, letterSpacing: 2)),
                            ],
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
                                child: pw.Text(data.summary, style: pw.TextStyle(fontSize: bSize, color: darkBlueGreyColor, lineSpacing: 1.5)),
                              ),
                              pw.SizedBox(height: 25),
                            ],

                            if (data.experienceList.isNotEmpty) ...[
                              pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                              pw.SizedBox(height: 10),
                              _buildDynamicExperience(data.experienceList, primaryColor, bSize),
                              pw.SizedBox(height: 15),
                            ],

                            if (data.educationList.isNotEmpty) ...[
                              pw.Text('EDUCATION', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                              pw.SizedBox(height: 10),
                              _buildDynamicEducation(data.educationList, primaryColor, bSize),
                            ],

                            if (data.projectList.isNotEmpty) ...[
                              pw.SizedBox(height: 15),
                              pw.Text('PROJECTS', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                              pw.SizedBox(height: 10),
                              _buildDynamicProjects(data.projectList, primaryColor, bSize),
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
  // 🌟 3. CREATIVE
  // ==========================================
  static pw.Widget _buildCreativeCanvaDesign(ResumeModel data, pw.MemoryImage? image) {
    final darkColor = PdfColor.fromHex(data.themeColor);
    final accentColor = PdfColor.fromHex('#FF6D00');
    final lightGreyColor = PdfColor.fromHex('#F5F5F5');
    final textGreyDark = PdfColor.fromHex('#424242');
    final double hSize = data.headingTextSize;
    final double bSize = data.bodyTextSize;

    return pw.Container(
        width: PdfPageFormat.a4.width,
        height: PdfPageFormat.a4.height,
        child: pw.Column(
            children: [
              pw.Container(
                  height: 180,
                  width: double.infinity,
                  color: darkColor,
                  padding: pw.EdgeInsets.symmetric(horizontal: data.pageMargin, vertical: 30),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Expanded(
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: hSize * 2, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                                  if (data.jobTitle.isNotEmpty) ...[
                                    pw.SizedBox(height: 8),
                                    pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: hSize * 0.9, color: accentColor, letterSpacing: 1.5)),
                                  ]
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
                            padding: pw.EdgeInsets.all(data.pageMargin * 0.75),
                            color: lightGreyColor,
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildCreativeSectionTitle('DETAILS', darkColor, accentColor, hSize),
                                  _buildDarkContactItem('Phone', data.phone, bSize),
                                  _buildDarkContactItem('Email', data.email, bSize),
                                  if (data.address.isNotEmpty) _buildDarkContactItem('Address', data.address, bSize),
                                  if (data.linkedin.isNotEmpty) _buildDarkContactItem('LinkedIn', data.linkedin, bSize),

                                  pw.SizedBox(height: 25),

                                  if (data.skills.isNotEmpty) ...[
                                    _buildCreativeSectionTitle('EXPERTISE', darkColor, accentColor, hSize),
                                    ...data.skills.split(',').map((skill) {
                                      if (skill.trim().isEmpty) return pw.SizedBox();
                                      return pw.Padding(
                                          padding: const pw.EdgeInsets.only(bottom: 8),
                                          child: pw.Row(
                                              children: [
                                                pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: accentColor, shape: pw.BoxShape.circle)),
                                                pw.SizedBox(width: 10),
                                                pw.Expanded(child: pw.Text(skill.trim(), style: pw.TextStyle(fontSize: bSize, color: textGreyDark))),
                                              ]
                                          )
                                      );
                                    }).toList(),
                                  ],

                                  if (data.languages.isNotEmpty) ...[
                                    pw.SizedBox(height: 25),
                                    _buildCreativeSectionTitle('LANGUAGES', darkColor, accentColor, hSize),
                                    pw.Text(data.languages, style: pw.TextStyle(fontSize: bSize, color: textGreyDark, lineSpacing: 1.5))
                                  ]
                                ]
                            )
                        ),
                        pw.Expanded(
                            child: pw.Container(
                                height: double.infinity,
                                padding: pw.EdgeInsets.all(data.pageMargin),
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      if (data.summary.isNotEmpty) ...[
                                        pw.Text('PROFILE', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                        pw.SizedBox(height: 10),
                                        pw.Text(data.summary, style: pw.TextStyle(fontSize: bSize, lineSpacing: 1.5, color: PdfColors.black)),
                                        pw.SizedBox(height: 25),
                                      ],

                                      if (data.experienceList.isNotEmpty) ...[
                                        pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                        pw.SizedBox(height: 10),
                                        _buildDynamicExperience(data.experienceList, accentColor, bSize),
                                        pw.SizedBox(height: 15),
                                      ],

                                      if (data.educationList.isNotEmpty) ...[
                                        pw.Text('EDUCATION', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                        pw.SizedBox(height: 10),
                                        _buildDynamicEducation(data.educationList, accentColor, bSize),
                                      ],

                                      if (data.projectList.isNotEmpty) ...[
                                        pw.SizedBox(height: 15),
                                        pw.Text('PROJECTS', style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                        pw.SizedBox(height: 10),
                                        _buildDynamicProjects(data.projectList, accentColor, bSize),
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
  // --- HELPER WIDGETS ---
  // ==========================================

  static pw.Widget _buildGradientTitle(String text, PdfColor c1, PdfColor c2, double hSize) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(text, style: pw.TextStyle(fontSize: hSize, fontWeight: pw.FontWeight.bold, color: c1)),
          pw.SizedBox(height: 5),
          pw.Container(height: 3, width: 40, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [c1, c2]))),
          pw.SizedBox(height: 15),
        ]
    );
  }

  static pw.Widget _buildCreativeSectionTitle(String text, PdfColor dark, PdfColor accent, double hSize) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(text, style: pw.TextStyle(fontSize: hSize * 0.9, fontWeight: pw.FontWeight.bold, color: dark)),
          pw.SizedBox(height: 5),
          pw.Container(height: 3, width: 30, color: accent),
          pw.SizedBox(height: 15),
        ]
    );
  }

  static pw.Widget _buildDarkSidebarTitle(String text, double hSize) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontSize: hSize * 0.8, fontWeight: pw.FontWeight.bold, letterSpacing: 2))),
          pw.SizedBox(height: 5),
          pw.Divider(color: PdfColors.white, thickness: 1),
          pw.SizedBox(height: 15),
        ]
    );
  }

  static pw.Widget _buildDynamicExperience(List<ExperienceItem> items, PdfColor color, double bSize) {
    if (items.isEmpty) return pw.SizedBox();
    final textGrey = PdfColor.fromHex('#616161');

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((item) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 15),
              padding: const pw.EdgeInsets.only(left: 15),
              decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColor(color.red, color.green, color.blue, 0.4), width: 2))),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.role, style: pw.TextStyle(fontSize: bSize + 2, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 2),
                    pw.Text('${item.company}  |  ${item.duration}', style: pw.TextStyle(fontSize: bSize - 1, color: textGrey, fontStyle: pw.FontStyle.italic)),
                    if (item.description.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(item.description, style: pw.TextStyle(fontSize: bSize, lineSpacing: 1.5, color: const PdfColor(0, 0, 0, 0.87))),
                    ]
                  ]
              )
          );
        }).toList()
    );
  }

  static pw.Widget _buildDynamicEducation(List<EducationItem> items, PdfColor color, double bSize) {
    if (items.isEmpty) return pw.SizedBox();
    final textGrey = PdfColor.fromHex('#616161');

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((item) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.only(left: 15),
              decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColor(color.red, color.green, color.blue, 0.4), width: 2))),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.degree, style: pw.TextStyle(fontSize: bSize + 1, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 2),
                    pw.Text('${item.institution} ${item.year.isNotEmpty ? " | " + item.year : ""}', style: pw.TextStyle(fontSize: bSize - 1, color: textGrey)),
                    if (item.grade.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text('Grade / CGPA: ${item.grade}', style: pw.TextStyle(fontSize: bSize - 1, color: const PdfColor(0, 0, 0, 0.87))),
                    ]
                  ]
              )
          );
        }).toList()
    );
  }

  static pw.Widget _buildDynamicProjects(List<ProjectItem> items, PdfColor color, double bSize) {
    if (items.isEmpty) return pw.SizedBox();
    final linkBlue = PdfColor.fromHex('#1565C0');

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((item) {
          return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.only(left: 15),
              decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColor(color.red, color.green, color.blue, 0.4), width: 2))),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.title, style: pw.TextStyle(fontSize: bSize + 1, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    if (item.link.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(item.link, style: pw.TextStyle(fontSize: bSize - 2, color: linkBlue, decoration: pw.TextDecoration.underline)),
                    ],
                    if (item.description.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(item.description, style: pw.TextStyle(fontSize: bSize - 1, lineSpacing: 1.5, color: const PdfColor(0, 0, 0, 0.87))),
                    ]
                  ]
              )
          );
        }).toList()
    );
  }

  static pw.Widget _buildContactItem(String icon, String text, double bSize) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Row(
            children: [
              pw.Text(icon, style: pw.TextStyle(fontSize: bSize + 1)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontSize: bSize - 1))),
            ]
        )
    );
  }

  static pw.Widget _buildDarkContactItem(String label, String value, double bSize) {
    if (value.isEmpty) return pw.SizedBox();
    final labelGrey = PdfColor.fromHex('#757575');
    final textDark = PdfColor.fromHex('#212121');

    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: bSize - 2, color: labelGrey)),
              pw.SizedBox(height: 2),
              pw.Text(value, style: pw.TextStyle(fontSize: bSize - 1, color: textDark, fontWeight: pw.FontWeight.bold)),
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