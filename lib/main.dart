import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:tuple/tuple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading pdf files',
      home: FlutterDemo(storage: PDFStorage()),
    );
  }
}

class PDFStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    if (kDebugMode) {
      print(directory.path);
    }

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tmp.pdf');
  }

  Future<Tuple2<String, int>> readPdf() async {
    try {
      final doc = await _pdfFromAsset('assets/sample.pdf');
      final numPages = doc.length;
      final docText = await doc.text;

      return Tuple2(docText, numPages);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return const Tuple2('', 0);
    }
  }

  Future<PDFDoc> _pdfFromAsset(String asset) async {
    File file;

    try {
      file = await _localFile;
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return await PDFDoc.fromFile(file);
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key, required this.storage}) : super(key: key);

  final PDFStorage storage;

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  String _docText = '';
  int _numPages = 0;

  @override
  void initState() {
    super.initState();
    widget.storage.readPdf().then((Tuple2<String, int> value) {
      setState(() {
        _docText = value.item1;
        _numPages = value.item2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read PDF File'),
      ),
      body: Center(
        child: Text(
          'Sample pdf has $_numPages page${_numPages == 1 ? '' : 's'}.\nSample Text:\n$_docText',
        ),
      ),
    );
  }
}
