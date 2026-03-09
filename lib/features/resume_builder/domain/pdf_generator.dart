import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/resume_model.dart';

class PdfGenerator {
  // 1. PDF Generate Logic
  static Future<Uint8List> generateResume(ResumeModel data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(data.fullName.isEmpty ? 'Your Name' : data.fullName,
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Text(data.jobTitle.isEmpty ? 'Job Title' : data.jobTitle,
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
              pw.SizedBox(height: 15),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Email: ${data.email}'),
                pw.Text('Phone: ${data.phone}'),
              ]),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text('Professional Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 5),
              pw.Text(data.summary.isEmpty ? 'Write a brief summary about yourself.' : data.summary),
              pw.SizedBox(height: 20),
              pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 5),
              pw.Text(data.skills.isEmpty ? 'List your skills here.' : data.skills),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  // 2. 1-Click Silent Save PDF (Bina pooche Download folder mein)
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
      print("Save Error: $e");
      return null;
    }
  }
}