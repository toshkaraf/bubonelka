import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

class GrammarPage extends StatefulWidget {
  final String grammarFilePath;

  const GrammarPage({super.key, required this.grammarFilePath});

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.dataFromString(
        '',
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString(widget.grammarFilePath);
    final uri = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    );
    _controller.loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Грамматическая справка')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
