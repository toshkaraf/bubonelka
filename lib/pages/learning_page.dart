import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/const_parameters.dart';
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
  bool _noMorePhrases = false;

  late FlutterTts _flutterTts;
  bool _ttsInitialized = false;
  bool _isCancelled = false;

  final double _speechRateRu = speechRateTranslation;
  double _speechRateDe = 0.5;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();

    final settings = SettingsAndState.getInstance();
    _speechRateDe = settings.speechRateBase;
    _isPauseBetween = settings.isPauseEnabled;
  }

  Future<void> _initTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSharedInstance(true);
    _ttsInitialized = true;
  }

  @override
  void dispose() {
    _isCancelled = true;
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
    if (_noMorePhrases) {
      return const Text(
        'Фраз больше нет!\nЧто делаем дальше?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      );
    }

    final current = _phrases[_currentIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        if (_showingGermanYet)
          ...current.germanPhrases
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
            onChanged: (v) async {
              final settings = SettingsAndState.getInstance();
              await settings.setIsPauseEnabled(v);
              setState(() {
                _isPauseBetween = v;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.speed),
            onPressed: _showSpeedDialog,
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
          _buildCircleButton(Icons.skip_next, () => _nextPhrase(auto: false)),
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
      _currentIndex = (_currentIndex - 1 + _phrases.length) % _phrases.length;
      _resetState();
    });
  }

  void _nextPhrase({bool auto = false}) {
    if (_currentIndex + 1 < _phrases.length) {
      setState(() {
        _currentIndex++;
        _resetState();
      });
      if (auto) {
        _startPlayback();
      }
    } else {
      setState(() {
        _isPlaying = false;
        _noMorePhrases = true;
        _showingGermanYet = false;
      });
      _playNoMorePhrasesMessage();
    }
  }

  void _resetState() {
    _isPlaying = false;
    _repeatCount = 0;
    _showingGermanYet = false;
    _isCancelled = true;
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
      _isCancelled = false;
    });

    final phrase = _phrases[_currentIndex];
    const phraseGap = Duration(milliseconds: 300);
    final settings = SettingsAndState.getInstance();
    final pauseSeconds = settings.delayBeforeGerman;

    // Проговариваем перевод один раз
    for (var translation in phrase.translationPhrases) {
      if (!_isPlaying || _isCancelled) return;
      await _flutterTts.setLanguage('ru-RU');
      await _flutterTts.setSpeechRate(_speechRateRu);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(translation);
      if (_isPauseBetween) await Future.delayed(phraseGap);
    }

    if (!_isPlaying || _isCancelled) return;

    if (_isPauseBetween) {
      await Future.delayed(Duration(seconds: pauseSeconds));
    }

    setState(() {
      _showingGermanYet = true;
    });

    _repeatCount = 0;
    while (_isPlaying && !_isCancelled && _repeatCount < 7) {
      for (var german in phrase.germanPhrases) {
        if (!_isPlaying || _isCancelled) return;
        await _flutterTts.setLanguage('de-DE');
        await _flutterTts.setSpeechRate(_speechRateDe);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.speak(german);
        if (_isPauseBetween) await Future.delayed(phraseGap);
      }
      _repeatCount++;
    }

    if (!_isPlaying || _isCancelled) return;

    _nextPhrase(auto: true);
  }

  Future<void> _playNoMorePhrasesMessage() async {
    const String message = 'Фраз больше нет! Что делаем дальше?';

    await _flutterTts.setLanguage('ru-RU');
    await _flutterTts.setSpeechRate(_speechRateRu);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);

    await _flutterTts.awaitSpeakCompletion(true);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final settings = SettingsAndState.getInstance();
        final double savedSpeed = settings.speechRateBase;
        double tempSpeedFactor = savedSpeed / 0.6;

        const double minFactor = 0.3;
        const double maxFactor = 1.5;

        return StatefulBuilder(
          builder: (context, setStateInside) {
            return AlertDialog(
              title: const Text('Регулировка скорости'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: tempSpeedFactor,
                    min: minFactor,
                    max: maxFactor,
                    divisions: 6,
                    label: '${tempSpeedFactor.toStringAsFixed(2)}x',
                    onChanged: (value) {
                      setStateInside(() {
                        tempSpeedFactor = value;
                      });
                    },
                  ),
                  Text(
                      'Текущая скорость: ${tempSpeedFactor.toStringAsFixed(2)}x'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    final newRealSpeed = tempSpeedFactor * 0.6;
                    await settings.setSpeechRateBase(newRealSpeed);
                    setState(() {
                      _speechRateDe = newRealSpeed;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
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
