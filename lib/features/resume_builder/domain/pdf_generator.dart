import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/resume_model.dart';

class PdfGenerator {
  static Future<Uint8List> generateResume(ResumeModel data) async {
    final pdf = pw.Document();

    pw.MemoryImage? profileImage;
    if (data.imagePath != null && File(data.imagePath!).existsSync()) {
      final bytes = File(data.imagePath!).readAsBytesSync();
      profileImage = pw.MemoryImage(bytes);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          switch (data.selectedTemplate) {
            case 'Executive':
              return _buildUltraPremium(data, profileImage);
            case 'Professional':
              return _buildProCanvaDesign(data, profileImage);
            case 'Creative':
              return _buildCreativeCanvaDesign(data, profileImage);
            case 'Modern':
            case 'Minimalist':
            case 'Classic':
            default:
              return _buildProCanvaDesign(data, profileImage);
          }
        },
      ),
    );
    return pdf.save();
  }

  // ==========================================
  // 🌟 1. ULTRA PREMIUM (3-COLOR GRADIENT & CUTS)
  // ==========================================
  static pw.Widget _buildUltraPremium(ResumeModel data, pw.MemoryImage? image) {
    // 3 Premium Colors
    final color1 = PdfColor.fromHex('#4158D0'); // Deep Blue
    final color2 = PdfColor.fromHex('#C850C0'); // Pink/Purple
    final color3 = PdfColor.fromHex('#FFCC70'); // Peach/Gold

    final darkText = PdfColor.fromHex('#1C1C1C');

    return pw.Stack(
        children: [
          // --- 1. ANGLED CUT BACKGROUND (3-COLOR GRADIENT) ---
          pw.Positioned(
            top: -150,
            left: -100,
            right: -100,
            child: pw.Transform.rotate(
              angle: -0.15, // Tircha Cut (Angled shape)
              child: pw.Container(
                height: 400,
                decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [color1, color2, color3],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                    boxShadow: [
                      pw.BoxShadow(color: PdfColors.black, blurRadius: 15, offset: const PdfPoint(0, 5))
                    ]
                ),
              ),
            ),
          ),

          // --- 2. MAIN CONTENT AREA ---
          pw.Positioned.fill(
              child: pw.Padding(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // HEADER SECTION (Overlapping the gradient cut)
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                  child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.SizedBox(height: 20),
                                        pw.Text(data.fullName.isEmpty ? 'YOUR NAME' : data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                                        pw.SizedBox(height: 5),
                                        pw.Text(data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: 16, color: PdfColors.white, letterSpacing: 3)),
                                        pw.SizedBox(height: 15),
                                        pw.Container(
                                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            // ⬅️ FIX: PdfColors.black.withOpacity(0.3) ki jagah theek color use kiya hai
                                            decoration: pw.BoxDecoration(color: const PdfColor(0, 0, 0, 0.3), borderRadius: pw.BorderRadius.circular(4)),
                                            child: pw.Text('${data.phone}  |  ${data.email}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10))
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

                        pw.SizedBox(height: 60),

                        // BODY SECTION
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // LEFT COLUMN
                              pw.Expanded(
                                  flex: 6,
                                  child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('PROFILE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color1)),
                                        pw.SizedBox(height: 5),
                                        pw.Container(height: 3, width: 40, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color1, color2]))),
                                        pw.SizedBox(height: 15),
                                        pw.Text(data.summary, style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: darkText)),

                                        pw.SizedBox(height: 30),

                                        pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color1)),
                                        pw.SizedBox(height: 5),
                                        pw.Container(height: 3, width: 40, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color1, color2]))),
                                        pw.SizedBox(height: 15),
                                        pw.Text(data.experience, style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: darkText)),
                                      ]
                                  )
                              ),
                              pw.SizedBox(width: 40),
                              // RIGHT COLUMN
                              pw.Expanded(
                                  flex: 4,
                                  child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color1)),
                                        pw.SizedBox(height: 5),
                                        pw.Container(height: 3, width: 40, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color1, color2]))),
                                        pw.SizedBox(height: 15),
                                        pw.Text(data.education, style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: darkText)),

                                        pw.SizedBox(height: 30),

                                        pw.Text('SKILLS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color1)),
                                        pw.SizedBox(height: 5),
                                        pw.Container(height: 3, width: 40, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color1, color2]))),
                                        pw.SizedBox(height: 15),
                                        ...data.skills.split(',').map((skill) {
                                          if (skill.trim().isEmpty) return pw.SizedBox();
                                          return pw.Padding(
                                              padding: const pw.EdgeInsets.only(bottom: 8),
                                              child: pw.Row(
                                                  children: [
                                                    pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(gradient: pw.LinearGradient(colors: [color2, color3]), shape: pw.BoxShape.circle)),
                                                    pw.SizedBox(width: 10),
                                                    pw.Expanded(child: pw.Text(skill.trim(), style: pw.TextStyle(fontSize: 11, color: darkText))),
                                                  ]
                                              )
                                          );
                                        }).toList(),
                                      ]
                                  )
                              )
                            ]
                        )
                      ]
                  )
              )
          )
        ]
    );
  }

  // ==========================================
  // 🌟 2. PROFESSIONAL (PRO CANVA STYLE)
  // ==========================================
  static pw.Widget _buildProCanvaDesign(ResumeModel data, pw.MemoryImage? image) {
    final primaryColor = PdfColor.fromHex('#1A237E');
    final accentColor = PdfColor.fromHex('#E8EAF6');

    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
              width: 200,
              height: double.infinity,
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

                    pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('CONTACT', style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2))),
                    pw.SizedBox(height: 5),
                    pw.Divider(color: PdfColors.white, thickness: 1),
                    pw.SizedBox(height: 10),
                    _buildContactItem('📞', data.phone),
                    _buildContactItem('✉️', data.email),

                    pw.SizedBox(height: 40),

                    pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('SKILLS', style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2))),
                    pw.SizedBox(height: 5),
                    pw.Divider(color: PdfColors.white, thickness: 1),
                    pw.SizedBox(height: 15),
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
                                    decoration: pw.BoxDecoration(
                                        color: const PdfColor(1, 1, 1, 0.2),
                                        borderRadius: pw.BorderRadius.circular(2)
                                    ),
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
                  ]
              )
          ),
          pw.Expanded(
              child: pw.Container(
                  color: PdfColors.white,
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.fullName.isEmpty ? 'YOUR NAME' : data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1.5)),
                        pw.SizedBox(height: 5),
                        pw.Text(data.jobTitle.isEmpty ? 'Professional Title' : data.jobTitle.toUpperCase(), style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600, letterSpacing: 2)),
                        pw.SizedBox(height: 30),

                        pw.Container(
                          padding: const pw.EdgeInsets.all(15),
                          decoration: pw.BoxDecoration(
                              color: accentColor,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(color: PdfColor(primaryColor.red, primaryColor.green, primaryColor.blue, 0.2))
                          ),
                          child: pw.Text(data.summary.isEmpty ? 'Your professional summary goes here.' : data.summary, style: pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey800, lineSpacing: 1.5)),
                        ),
                        pw.SizedBox(height: 30),

                        pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                        pw.SizedBox(height: 10),
                        _buildTimelineItem(data.experience, primaryColor),

                        pw.SizedBox(height: 25),

                        pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                        pw.SizedBox(height: 10),
                        _buildTimelineItem(data.education, primaryColor),
                      ]
                  )
              )
          )
        ]
    );
  }

  // ==========================================
  // 🌟 3. CREATIVE (MODERN HEADER STYLE)
  // ==========================================
  static pw.Widget _buildCreativeCanvaDesign(ResumeModel data, pw.MemoryImage? image) {
    final darkColor = PdfColor.fromHex('#212121');
    final accentColor = PdfColor.fromHex('#FF6D00');

    return pw.Column(
        children: [
          pw.Container(
              height: 200,
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
                              pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 38, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                              pw.SizedBox(height: 8),
                              pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: 18, color: accentColor, letterSpacing: 1.5)),
                            ]
                        )
                    ),
                    if (image != null)
                      pw.Container(
                        width: 130, height: 130,
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
                        width: 220,
                        padding: const pw.EdgeInsets.all(30),
                        color: PdfColors.grey100,
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('DETAILS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: darkColor)),
                              pw.SizedBox(height: 5),
                              pw.Container(height: 3, width: 30, color: accentColor),
                              pw.SizedBox(height: 15),
                              _buildDarkContactItem('Phone', data.phone),
                              _buildDarkContactItem('Email', data.email),

                              pw.SizedBox(height: 40),

                              pw.Text('EXPERTISE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: darkColor)),
                              pw.SizedBox(height: 5),
                              pw.Container(height: 3, width: 30, color: accentColor),
                              pw.SizedBox(height: 15),
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
                            ]
                        )
                    ),
                    pw.Expanded(
                        child: pw.Container(
                            padding: const pw.EdgeInsets.all(40),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('PROFILE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                  pw.SizedBox(height: 10),
                                  pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: PdfColors.black)),

                                  pw.SizedBox(height: 30),

                                  pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                  pw.SizedBox(height: 15),
                                  _buildCreativeTimeline(data.experience, accentColor),

                                  pw.SizedBox(height: 30),

                                  pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkColor)),
                                  pw.SizedBox(height: 15),
                                  _buildCreativeTimeline(data.education, accentColor),
                                ]
                            )
                        )
                    )
                  ]
              )
          )
        ]
    );
  }

  // --- HELPER WIDGETS ---
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

  static pw.Widget _buildTimelineItem(String text, PdfColor color) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
              margin: const pw.EdgeInsets.only(top: 4, right: 15),
              width: 2, height: 40, color: PdfColor(color.red, color.green, color.blue, 0.3)
          ),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5))),
        ]
    );
  }

  static pw.Widget _buildCreativeTimeline(String text, PdfColor accent) {
    return pw.Container(
        padding: const pw.EdgeInsets.only(left: 15),
        decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: accent, width: 2))),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5))
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