import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  ThemeClass? _theme;
  List<PhraseCard> _phrases = [];
  int _currentIndex = 0;
  bool _isPauseBetween = false;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _showingGermanYet = false;
  int _repeatCount = 0;

  // Новый экземпляр TTS
  late FlutterTts _flutterTts;
  bool _ttsInitialized = false;

  bool _isCancelled = false; // <=== контроль выхода

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSharedInstance(true);
    _ttsInitialized = true;
  }

  @override
  void dispose() {
    _isCancelled = true; // <=== метка отмены
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ThemeClass) {
      _theme = args;
      _loadPhrases();
    }
  }

  Future<void> _loadPhrases() async {
    if (_theme == null) return;
    final dbHelper = DatabaseHelper();
    final phrases = await dbHelper.getPhrasesForTheme(themeId: _theme!.id);
    setState(() {
      _phrases = phrases;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_theme?.themeNameTranslation ?? 'Изучение фраз'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              if (_theme != null) {
                _showGrammarDialog(_theme!.grammarFilePath);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _phrases.isEmpty
              ? const Center(child: Text('Нет фраз для этой темы'))
              : Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildTopControls(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: _buildPhraseContent(),
                      ),
                    ),
                    _buildBottomControls(),
                  ],
                ),
    );
  }

  Widget _buildPhraseContent() {
    final current = _phrases[_currentIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Русские фразы (всегда видны)
        ...current.translationPhrases
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ))
            .toList(),

        const SizedBox(height: 12),
        // Разделитель (всегда виден)
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),

        // Немецкие фразы (появляются только после русского блока)
        if (_showingGermanYet) ...current.germanPhrases
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Switch(
            value: _isPauseBetween,
            onChanged: (v) => setState(() => _isPauseBetween = v),
          ),
          IconButton(
            icon: const Icon(Icons.speed),
            onPressed: () {}, // TODO: скорость
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              if (_theme != null) {
                _showGrammarDialog(_theme!.grammarFilePath);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {}, // TODO: избранное
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {}, // TODO: редактировать фразу
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {}, // TODO: удалить фразу
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircleButton(Icons.skip_previous, _prevPhrase),
          _buildCircleButton(
              _isPlaying ? Icons.pause : Icons.play_arrow, _togglePlay),
          _buildCircleButton(Icons.skip_next, _nextPhrase),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.blueAccent,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 36,
        onPressed: onPressed,
      ),
    );
  }

  void _prevPhrase() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _phrases.length) % _phrases.length;
      _resetState();
    });
  }

  void _nextPhrase() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _phrases.length;
      _resetState();
    });
  }

  void _resetState() {
    _isPlaying = false;
    _repeatCount = 0;
    _showingGermanYet = false;
    _isCancelled = true; // останавливаем полностью
    _flutterTts.stop();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _pausePlayback();
    } else {
      _startPlayback();
    }
  }

  void _pausePlayback() {
    setState(() {
      _isPlaying = false;
    });
    _flutterTts.stop();
  }

  Future<void> _startPlayback() async {
    if (!_ttsInitialized) await _initTts();

    setState(() {
      _isPlaying = true;
      _showingGermanYet = false;
      _isCancelled = false; // сброс флага отмены
    });

    final phrase = _phrases[_currentIndex];

    // Проговариваем перевод один раз
    for (var translation in phrase.translationPhrases) {
      if (!_isPlaying || _isCancelled) return;
      await _flutterTts.setLanguage('ru-RU');
      await _flutterTts.setSpeechRate(0.9);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(translation);
      if (_isPauseBetween) await Future.delayed(const Duration(seconds: 1));
    }

    if (!_isPlaying || _isCancelled) return;

    // Показываем немецкий блок и начинаем повторение
    setState(() {
      _showingGermanYet = true;
    });

    _repeatCount = 0;
    while (_isPlaying && !_isCancelled && _repeatCount < 7) {
      for (var german in phrase.germanPhrases) {
        if (!_isPlaying || _isCancelled) return;
        await _flutterTts.setLanguage('de-DE');
        await _flutterTts.setSpeechRate(0.8);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.speak(german);
        if (_isPauseBetween) await Future.delayed(const Duration(seconds: 1));
      }
      _repeatCount++;
    }

    if (!_isPlaying || _isCancelled) return;

    // Переходим к следующей фразе автоматически
    _nextPhrase();
    if (_isPlaying && !_isCancelled) {
      await Future.delayed(const Duration(milliseconds: 300));
      _startPlayback(); // автозапуск следующей
    }
  }

  void _showGrammarDialog(String grammarPath) async {
    final dbHelper = DatabaseHelper();
    final content = await dbHelper.loadGrammarHtml(grammarPath);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Грамматическая справка'),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'))
        ],
      ),
    );
  }
}
