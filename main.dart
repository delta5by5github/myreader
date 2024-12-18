import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PDF Viewer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _pdfPaths = [];

  @override
  void initState() {
    super.initState();
    _getPdfFiles();
  }

  Future<void> _getPdfFiles() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final directory = Directory(documentsDirectory.path);
      final files = directory.listSync();

      setState(() {
        _pdfPaths = files
            .where((file) => file.path.endsWith('.pdf'))
            .map((file) => file.path)
            .toList()
          ..sort();
      });
    } catch (e) {
      print('Error getting PDF files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _pdfPaths.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_pdfPaths[index].split('/').last),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(path: _pdfPaths[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final String path;

  const PdfViewerPage({super.key, required this.path});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getTotalPages();
  }

  Future<void> _getTotalPages() async {
    final doc = await PDFDocument.fromFile(File(widget.path));
    setState(() => _totalPages = doc.pageCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: widget.path,
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page ?? 0;
          });
        },
      ),
      bottomNavigationBar: Text(
        'Page: $_currentPage of $_totalPages',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PDFDocument {
  static fromFile(File file) {}
}
