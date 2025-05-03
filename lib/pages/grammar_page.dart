import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_html/flutter_html.dart';

class GrammarPage extends StatefulWidget {
  final String grammarFilePath;
  final String title;

  const GrammarPage({
    super.key,
    required this.grammarFilePath,
    required this.title,
  });

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  String? _htmlContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      final content = await rootBundle.loadString(widget.grammarFilePath);
      setState(() {
        _htmlContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _htmlContent = '<p style="color:red;">Не удалось загрузить файл справки.</p>';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Html(data: _htmlContent ?? 'Ошибка загрузки'),
            ),
    );
  }
}
