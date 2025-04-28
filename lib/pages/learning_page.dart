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
  bool _isGerman = false;
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
    final visiblePhrases = _isGerman ? phrase.germanPhrases : phrase.translationPhrases;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Изучение фраз'),
        actions: [
          IconButton(icon: const Icon(Icons.speed), onPressed: () => _showSpeedDialog(context)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildSwitches(),
          const SizedBox(height: 20),
          ...visiblePhrases.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(p, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
          )),
          const Spacer(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildSwitches() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Пауза между языками'),
        Switch(
          value: _isPauseBetween,
          onChanged: (v) => setState(() => _isPauseBetween = v),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
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
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: _previousPhrase),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
          ),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: _nextPhrase),
        ],
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

  Future<void> _speakCurrentPhrase() async {
    final phrase = phrasesSet.currentPhraseCard;
    _isGerman = false;
    setState(() {});

    await flutterTts.setLanguage('ru-RU');
    await flutterTts.setSpeechRate(speechRateTranslation);
    await flutterTts.setPitch(1.0);

    for (final p in phrase.translationPhrases) {
      if (_isPaused) return;
      await flutterTts.speak(p);
      await flutterTts.awaitSpeakCompletion(true);
    }

    if (_isPauseBetween) {
      await Future.delayed(const Duration(seconds: delayBeforGermanPhraseInSeconds));
    }

    _isGerman = true;
    setState(() {});

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
        title: const Text('Выберите скорость речи'),
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
