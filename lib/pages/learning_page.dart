import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:bubonelka/classes/current_phrases_set.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/classes/settings_and_state.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final FlutterTts flutterTts = FlutterTts();
  final CurrentPhrasesSet phrasesSet = CurrentPhrasesSet();

  bool _isPaused = false;
  bool _isPauseBetween = false;
  double _speechRate = speechRateTranslation;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final selectedThemes = SettingsAndState.getInstance().chosenThemes;
    await phrasesSet.initialize(selectedThemes);

    if (mounted && phrasesSet.currentPhraseCard != emptyPhraseCard) {
      _speakCurrentPhrase();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    phrasesSet.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrase = phrasesSet.currentPhraseCard;
    final visiblePhrases = phrase.translationPhrases.isNotEmpty
        ? phrase.translationPhrases
        : ['Нет фраз для отображения'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Изучение фраз'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // TODO: Добавить вызов справки
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildTopControls(),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: visiblePhrases
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          _buildBottomControls(),
        ],
      ),
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
            onPressed: () => _showSpeedDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: _showGrammar,
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // TODO: Добавить/убрать из избранного
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Добавить действие редактирования
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Удалить фразу из изучения
            },
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
          _buildCircleButton(Icons.skip_previous, _previousPhrase),
          _buildCircleButton(_isPaused ? Icons.play_arrow : Icons.pause, _togglePause),
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

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) {
      _speakCurrentPhrase();
    } else {
      flutterTts.stop();
    }
  }

  void _nextPhrase() {
    if (phrasesSet.hasMore()) {
      setState(() {
        phrasesSet.getNextPhraseCard();
        _isPaused = false;
      });
      _speakCurrentPhrase();
    }
  }

  void _previousPhrase() {
    setState(() {
      phrasesSet.getPreviousPhraseCard();
      _isPaused = false;
    });
    _speakCurrentPhrase();
  }

  void _showGrammar() {
    // TODO: Реализовать вызов грамматической справки
  }

  Future<void> _speakCurrentPhrase() async {
    final phrase = phrasesSet.currentPhraseCard;

    await flutterTts.setLanguage('ru-RU');
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.setPitch(1.0);

    for (final p in phrase.translationPhrases) {
      if (_isPaused) return;
      await flutterTts.speak(p);
      await flutterTts.awaitSpeakCompletion(true);
    }

    if (_isPauseBetween) {
      await Future.delayed(const Duration(seconds: delayBeforGermanPhraseInSeconds));
    }

    await flutterTts.setLanguage('de-DE');
    await flutterTts.setSpeechRate(_speechRate);

    for (int i = 0; i < 5; i++) {
      for (final p in phrase.germanPhrases) {
        if (_isPaused) return;
        await flutterTts.speak(p);
        await flutterTts.awaitSpeakCompletion(true);
      }
    }

    if (!_isPaused && phrasesSet.hasMore()) {
      _nextPhrase();
    }
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Скорость речи'),
        content: Slider(
          value: _speechRate,
          min: 0.1,
          max: 2.0,
          divisions: 20,
          label: (_speechRate * 100).round().toString() + '%',
          onChanged: (v) => setState(() => _speechRate = v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
        ],
      ),
    );
  }
}
