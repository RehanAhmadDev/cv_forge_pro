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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: data.selectedTemplate == 'Professional' ? pw.EdgeInsets.zero : const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          switch (data.selectedTemplate) {
            case 'Modern':
              return _buildModern(data);
            case 'Professional':
              return _buildProfessional(data);
            case 'Minimalist':
              return _buildMinimalist(data);
            case 'Classic':
            default:
              return _buildClassic(data);
          }
        },
      ),
    );
    return pdf.save();
  }

  // --- 1. CLASSIC DESIGN ---
  static pw.Widget _buildClassic(ResumeModel data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
        pw.Text(data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle, style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
        pw.SizedBox(height: 15),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Email: ${data.email}'),
          pw.Text('Phone: ${data.phone}'),
        ]),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 10),
        pw.Text('Professional Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(data.summary.isEmpty ? 'Write a brief summary about yourself.' : data.summary),
        pw.SizedBox(height: 20),
        pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(data.skills.isEmpty ? 'List your skills here.' : data.skills),
      ],
    );
  }

  // --- 2. MODERN DESIGN (Dark Header) ---
  static pw.Widget _buildModern(ResumeModel data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(color: PdfColors.blueGrey800, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.Text(data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle, style: const pw.TextStyle(fontSize: 18, color: PdfColors.blueGrey200)),
                ]
            )
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
            pw.Text('Email: ${data.email}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Phone: ${data.phone}', style: const pw.TextStyle(fontSize: 12)),
          ]),
        ),
        pw.SizedBox(height: 20),
        pw.Text('SUMMARY', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
        pw.Divider(color: PdfColors.blueGrey200),
        pw.Text(data.summary.isEmpty ? 'Write a brief summary about yourself.' : data.summary),
        pw.SizedBox(height: 20),
        pw.Text('SKILLS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
        pw.Divider(color: PdfColors.blueGrey200),
        pw.Text(data.skills.isEmpty ? 'List your skills here.' : data.skills),
      ],
    );
  }

  // --- 3. PROFESSIONAL DESIGN (Left Sidebar) ---
  static pw.Widget _buildProfessional(ResumeModel data) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Sidebar
          pw.Container(
              width: 150,
              height: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              color: PdfColors.blue900,
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CONTACT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text(data.email, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Text(data.phone, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                    pw.SizedBox(height: 30),
                    pw.Text('SKILLS', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text(data.skills, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  ]
              )
          ),
          // Main Content
          pw.Expanded(
              child: pw.Container(
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName, style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text(data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle, style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey600)),
                        pw.SizedBox(height: 20),
                        pw.Divider(),
                        pw.SizedBox(height: 20),
                        pw.Text('PROFILE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.SizedBox(height: 10),
                        pw.Text(data.summary.isEmpty ? 'Write a brief summary about yourself.' : data.summary),
                      ]
                  )
              )
          )
        ]
    );
  }

  // --- 4. MINIMALIST DESIGN (Centered) ---
  static pw.Widget _buildMinimalist(ResumeModel data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 24, letterSpacing: 2, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(data.jobTitle.isEmpty ? 'JOB TITLE' : data.jobTitle.toUpperCase(), style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey500, letterSpacing: 1)),
        pw.SizedBox(height: 15),
        pw.Text('${data.email}  |  ${data.phone}', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 20),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 20),
        pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('SUMMARY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey800))),
        pw.SizedBox(height: 5),
        pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text(data.summary)),
        pw.SizedBox(height: 20),
        pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('SKILLS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey800))),
        pw.SizedBox(height: 5),
        pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text(data.skills)),
      ],
    );
  }

  static Future<String?> savePdfToDevice({required Uint8List bytes, required String fileName}) async {
    try {
      if (Platform.isAndroid) {
        if (!await Permission.storage.request().isGranted &&
            !await Permission.manageExternalStorage.request().isGranted) {
          return null;
        }
      }
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/CV_Forge');
      } else {
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/CV_Forge');
      }
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}