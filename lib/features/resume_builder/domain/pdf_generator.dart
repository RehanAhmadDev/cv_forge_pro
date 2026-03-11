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

    // ⬅️ Tasweer ko PDF ke qabil banane ka logic
    pw.MemoryImage? profileImage;
    if (data.imagePath != null && File(data.imagePath!).existsSync()) {
      final bytes = File(data.imagePath!).readAsBytesSync();
      profileImage = pw.MemoryImage(bytes);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        // 2-Column designs ke liye margin zero rakha hai
        margin: (data.selectedTemplate == 'Professional' || data.selectedTemplate == 'Creative')
            ? pw.EdgeInsets.zero
            : const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          switch (data.selectedTemplate) {
            case 'Modern':
              return _buildModern(data, profileImage);
            case 'Professional':
              return _buildProfessional(data, profileImage);
            case 'Creative':
              return _buildCreative(data, profileImage);
            case 'Executive':
              return _buildExecutive(data, profileImage);
            case 'Minimalist':
              return _buildMinimalist(data, profileImage);
            case 'Classic':
            default:
              return _buildClassic(data, profileImage);
          }
        },
      ),
    );
    return pdf.save();
  }

  // --- HELPER WIDGETS ---
  static pw.Widget _sectionTitle(String title, {PdfColor color = PdfColors.blueGrey800}) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color, letterSpacing: 1.2)),
          pw.SizedBox(height: 4),
          pw.Container(height: 2, width: 40, color: color),
          pw.SizedBox(height: 10),
        ]
    );
  }

  // --- 1. PROFESSIONAL DESIGN (Canva Style 2-Column) ---
  static pw.Widget _buildProfessional(ResumeModel data, pw.MemoryImage? image) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left Sidebar (Dark Blue)
          pw.Container(
              width: 180,
              height: double.infinity,
              color: PdfColors.blue900,
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (image != null) ...[
                      pw.Container(
                        width: 100, height: 100,
                        decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover)),
                      ),
                      pw.SizedBox(height: 20),
                    ],
                    pw.Text('CONTACT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                    pw.Divider(color: PdfColors.white, thickness: 0.5),
                    pw.SizedBox(height: 10),
                    pw.Text(data.phone, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Text(data.email, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    if (data.linkedin.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(data.linkedin, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    ],
                    if (data.github.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(data.github, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    ],
                    pw.SizedBox(height: 30),
                    pw.Text('SKILLS', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                    pw.Divider(color: PdfColors.white, thickness: 0.5),
                    pw.SizedBox(height: 10),
                    pw.Text(data.skills, style: const pw.TextStyle(color: PdfColors.white, fontSize: 11, lineSpacing: 3)),
                  ]
              )
          ),
          // Right Main Content
          pw.Expanded(
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.SizedBox(height: 5),
                        pw.Text(data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle.toUpperCase(), style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey600, letterSpacing: 1)),
                        pw.SizedBox(height: 25),
                        _sectionTitle('Profile', color: PdfColors.blue900),
                        pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
                        pw.SizedBox(height: 20),
                        if (data.experience.isNotEmpty) ...[
                          _sectionTitle('Experience', color: PdfColors.blue900),
                          pw.Text(data.experience, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
                          pw.SizedBox(height: 20),
                        ],
                        if (data.education.isNotEmpty) ...[
                          _sectionTitle('Education', color: PdfColors.blue900),
                          pw.Text(data.education, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5)),
                        ]
                      ]
                  )
              )
          )
        ]
    );
  }

  // --- 2. CREATIVE DESIGN (Canva Style - Orange Sidebar) ---
  static pw.Widget _buildCreative(ResumeModel data, pw.MemoryImage? image) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
              flex: 2,
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (image != null) ...[
                          pw.Container(
                            width: 80, height: 80,
                            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover)),
                          ),
                          pw.SizedBox(height: 15),
                        ],
                        pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName, style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                        pw.Text(data.jobTitle, style: pw.TextStyle(fontSize: 18, color: PdfColors.orange800)),
                        pw.SizedBox(height: 30),
                        _sectionTitle('About Me', color: PdfColors.orange800),
                        pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 20),
                        _sectionTitle('Experience', color: PdfColors.orange800),
                        pw.Text(data.experience, style: const pw.TextStyle(fontSize: 11)),
                      ]
                  )
              )
          ),
          pw.Expanded(
              flex: 1,
              child: pw.Container(
                  height: double.infinity,
                  color: PdfColors.grey100,
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Details', color: PdfColors.grey800),
                        pw.Text(data.phone, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 5),
                        pw.Text(data.email, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 20),
                        _sectionTitle('Education', color: PdfColors.grey800),
                        pw.Text(data.education, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 20),
                        _sectionTitle('Skills', color: PdfColors.grey800),
                        pw.Text(data.skills, style: const pw.TextStyle(fontSize: 10)),
                      ]
                  )
              )
          )
        ]
    );
  }

  // --- 3. MODERN DESIGN (Header Style) ---
  static pw.Widget _buildModern(ResumeModel data, pw.MemoryImage? image) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(25),
            decoration: pw.BoxDecoration(color: PdfColors.blueGrey800, borderRadius: pw.BorderRadius.circular(10)),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName, style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        pw.SizedBox(height: 5),
                        pw.Text(data.jobTitle, style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey200)),
                      ]
                  ),
                  if (image != null)
                    pw.Container(
                      width: 70, height: 70,
                      decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover)),
                    ),
                ]
            )
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(5)),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
            pw.Text(data.email, style: const pw.TextStyle(fontSize: 11)),
            pw.Text(data.phone, style: const pw.TextStyle(fontSize: 11)),
            if (data.linkedin.isNotEmpty) pw.Text('LinkedIn', style: const pw.TextStyle(fontSize: 11)),
          ]),
        ),
        pw.SizedBox(height: 20),
        _sectionTitle('Summary'),
        pw.Text(data.summary, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 15),
        _sectionTitle('Experience'),
        pw.Text(data.experience, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 15),
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_sectionTitle('Education'), pw.Text(data.education, style: const pw.TextStyle(fontSize: 12))])),
              pw.SizedBox(width: 20),
              pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [_sectionTitle('Skills'), pw.Text(data.skills, style: const pw.TextStyle(fontSize: 12))])),
            ]
        )
      ],
    );
  }

  // --- 4. EXECUTIVE DESIGN ---
  static pw.Widget _buildExecutive(ResumeModel data, pw.MemoryImage? image) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (image != null) ...[
            pw.Container(width: 80, height: 80, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover))),
            pw.SizedBox(height: 10),
          ],
          pw.Text(data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
          pw.Text(data.jobTitle.toUpperCase(), style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700, letterSpacing: 1)),
          pw.SizedBox(height: 10),
          pw.Text('${data.email}  •  ${data.phone}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 2, color: PdfColors.black),
          pw.SizedBox(height: 10),
          _sectionTitle('Executive Summary', color: PdfColors.black),
          pw.Text(data.summary),
          pw.SizedBox(height: 15),
          _sectionTitle('Professional Experience', color: PdfColors.black),
          pw.Text(data.experience),
          pw.SizedBox(height: 15),
          _sectionTitle('Education & Expertise', color: PdfColors.black),
          pw.Text('Education:\n${data.education}\n\nCore Competencies:\n${data.skills}'),
        ]
    );
  }

  // --- 5. MINIMALIST DESIGN ---
  static pw.Widget _buildMinimalist(ResumeModel data, pw.MemoryImage? image) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (image != null) ...[
                  pw.Container(width: 60, height: 60, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover))),
                  pw.SizedBox(width: 15),
                ],
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data.fullName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(data.jobTitle, style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey500)),
                    ]
                )
              ]
          ),
          pw.SizedBox(height: 15),
          pw.Text('${data.email} | ${data.phone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 20),
          _sectionTitle('Summary', color: PdfColors.grey800),
          pw.Text(data.summary, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 15),
          _sectionTitle('Experience', color: PdfColors.grey800),
          pw.Text(data.experience, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 15),
          _sectionTitle('Education', color: PdfColors.grey800),
          pw.Text(data.education, style: const pw.TextStyle(fontSize: 11)),
        ]
    );
  }

  // --- 6. CLASSIC DESIGN ---
  static pw.Widget _buildClassic(ResumeModel data, pw.MemoryImage? image) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data.fullName, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                      pw.Text(data.jobTitle, style: const pw.TextStyle(fontSize: 16)),
                    ]
                ),
                if (image != null)
                  pw.Container(width: 60, height: 60, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover))),
              ]
          ),
          pw.SizedBox(height: 10),
          pw.Text('${data.email} | ${data.phone}'),
          pw.Divider(),
          pw.SizedBox(height: 10),
          _sectionTitle('Summary', color: PdfColors.black),
          pw.Text(data.summary),
          pw.SizedBox(height: 15),
          _sectionTitle('Experience', color: PdfColors.black),
          pw.Text(data.experience),
          pw.SizedBox(height: 15),
          _sectionTitle('Education', color: PdfColors.black),
          pw.Text(data.education),
          pw.SizedBox(height: 15),
          _sectionTitle('Skills', color: PdfColors.black),
          pw.Text(data.skills),
        ]
    );
  }

  // --- SAVE LOGIC ---
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