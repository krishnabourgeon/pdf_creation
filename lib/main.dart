import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class PdfGenerator extends StatefulWidget {
  @override
  _PdfGeneratorState createState() => _PdfGeneratorState();
}

class _PdfGeneratorState extends State<PdfGenerator> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  Future<void> _generatePdf(String name, String age) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('User Information', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Name: $name', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Age: $age', style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
    final pdfBytes = await pdf.save();
    await savePdfToDownloads(pdfBytes);
  }

  Future<void> savePdfToDownloads(List<int> pdfBytes) async {
    // Request storage permissions (for Android)
    if (Platform.isAndroid) {
      print("android..");
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Permission denied');
        return;
      }
    }

    // Get the downloads directory
    Directory? downloadsDirectory;
    if (Platform.isAndroid) {
      print("platfrom..");
      downloadsDirectory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    } else {
      downloadsDirectory = await getDownloadsDirectory(); // For Desktop
    }

    if (downloadsDirectory == null) {
      print('Could not find downloads directory');
      return;
    }

    // Define the file path and name
    final filePath = '${downloadsDirectory.path}/user_data.pdf';

    // Save the PDF file
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    print('PDF saved to $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create PDF with Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Enter Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Enter Age'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final age = _ageController.text;
                _generatePdf(name, age);
              },
              child: Text('Generate PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: PdfGenerator()));
}
