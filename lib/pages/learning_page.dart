// LearningPage, обновлённая для работы с базой данных

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/const_parameters.dart';

class LearningPage extends StatefulWidget {
  final List<String> selectedThemeNames;

  const LearningPage({super.key, required this.selectedThemeNames});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final FlutterTts flutterTts = FlutterTts();
  final DatabaseHelper dbHelper = DatabaseHelper();

  List<PhraseCard> _phrases = [];
  int _currentIndex = 0;
  bool _isPaused = false;
  bool _isPauseBetween = false;
  bool _isGerman = false;
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    List<PhraseCard> all = [];
    for (final themeName in widget.selectedThemeNames) {
      final list = await dbHelper.getPhrasesByThemeName(themeName);
      all.addAll(list);
    }
    setState(() {
      _phrases = all;
    });
    if (_phrases.isNotEmpty) {
      _speakPhrases();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _phrases.isEmpty ? emptyPhraseCard : _phrases[_currentIndex];
    final visiblePhrases = _isGerman ? current.germanPhrases : current.translationPhrases;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubonelka'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Switch(
                value: _isPauseBetween,
                onChanged: (v) => setState(() => _isPauseBetween = v),
              ),
              IconButton(
                icon: const Icon(Icons.speed),
                onPressed: () => _showSpeedDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () async {
                  await dbHelper.addToFavorites(current);
                  _showSnackbar('Фраза добавлена в "Избранное".');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...visiblePhrases.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(p, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
          )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _previousPhrase,
                ),
                IconButton(
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  onPressed: () {
                    setState(() => _isPaused = !_isPaused);
                    if (!_isPaused) _speakPhrases();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _nextPhrase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _speakPhrases() async {
    if (_phrases.isEmpty) return;
    final current = _phrases[_currentIndex];
    _isGerman = false;
    setState(() {});

    await flutterTts.setLanguage('ru-RU');
    await flutterTts.setSpeechRate(speechRateTranslation);
    await flutterTts.setPitch(1);

    for (final phrase in current.translationPhrases) {
      if (_isPaused) return;
      await flutterTts.speak(phrase);
      await flutterTts.awaitSpeakCompletion(true);
    }

    if (_isPauseBetween) {
      await Future.delayed(Duration(seconds: delayBeforGermanPhraseInSeconds));
    }

    _isGerman = true;
    setState(() {});

    await flutterTts.setLanguage('de-DE');
    await flutterTts.setSpeechRate(_speechRate);

    for (int i = 0; i < 7; i++) {
      for (final phrase in current.germanPhrases) {
        if (_isPaused) return;
        await flutterTts.speak(phrase);
        await flutterTts.awaitSpeakCompletion(true);
      }
    }

    if (!_isPaused && _currentIndex < _phrases.length - 1) {
      _nextPhrase();
    }
  }

  void _nextPhrase() {
    if (_currentIndex < _phrases.length - 1) {
      setState(() {
        _currentIndex++;
        _isPaused = false;
      });
      _speakPhrases();
    }
  }

  void _previousPhrase() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isPaused = false;
      });
      _speakPhrases();
    }
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выберите скорость'),
        content: Slider(
          value: _speechRate,
          min: 0.1,
          max: 2.0,
          divisions: 20,
          label: (_speechRate * 100).round().toString() + '%',
          onChanged: (v) => setState(() => _speechRate = v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          )
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
