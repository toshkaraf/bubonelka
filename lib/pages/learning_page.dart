import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/rutes.dart';
import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum LearningMode {
  studyThemes,
  repeatFavorites,
  repeatRecommended,
}

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  ThemeClass? _theme;
  LearningMode _mode = LearningMode.studyThemes;
  List<ThemeClass> _themeList = [];

  List<PhraseCard> _phrases = [];
  int _currentIndex = 0;
  bool _isPauseBetween = false;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _showingGermanYet = false;
  int _repeatCount = 0;

  late FlutterTts _flutterTts;
  bool _ttsInitialized = false;
  bool _isCancelled = false;

  final double _speechRateRu = speechRateTranslation;
  double _speechRateDe = 0.5;

  final List<Color> ratingColors = [
    Colors.red,
    Colors.deepOrange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  final List<String> labels = [
    'Очень трудно',
    'Трудно',
    'Средне',
    'Легко',
    'Очень легко'
  ];

  final List<String> nextIntervals = [
    'Следующее повторение через 1 день',
    'Следующее повторение через 3 дня',
    'Следующее повторение через 7 дней',
    'Следующее повторение через 14 дней',
    'Следующее повторение через 30 дней'
  ];

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
    if (args is Map) {
      _theme = args['theme'] as ThemeClass?;
      _mode = args['mode'] ?? LearningMode.studyThemes;
      if (args['themeList'] != null && args['themeList'] is List) {
        _themeList =
            (args['themeList'] as List).whereType<ThemeClass>().toList();
      }
      _loadPhrases();
    }
  }

  Future<void> _loadPhrases() async {
    final dbHelper = DatabaseHelper();

    if (_mode == LearningMode.repeatFavorites) {
      final phrases =
          await dbHelper.getPhrasesForTheme(themeName: favoritePhrasesSet);
      setState(() {
        _phrases = phrases;
        _isLoading = false;
      });
    } else if (_theme != null) {
      final phrases = await dbHelper.getPhrasesForTheme(themeId: _theme!.id);
      setState(() {
        _phrases = phrases;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
      // ✔ Гарантированно останавливаем проигрывание
      setState(() {
        _isPlaying = false;
        _showingGermanYet = false;
      });

      if (auto) {
        // 💡 Если вызов из автоцикла, проверяем, нужно ли что-то дополнительно завершить
        if (_mode == LearningMode.repeatFavorites) {
          // Это авто-следующий шаг в Избранном — сразу завершаем, не даём повторно воспроизвести
          _showEndOfFavoritesDialog();
          return;
        }
      }

      // ✴️ Основная логика для остальных режимов:
      if (_mode == LearningMode.repeatRecommended) {
        _showRatingDialog(onFinish: _showNextOrChooseDialog);
        _speakRussian('Как вам эта тема?');
      } else {
        _showRatingDialog(onFinish: () {
          Navigator.pop(context);
        });
        _speakRussian('Как вам эта тема?');
      }
    }
  }

  void _showRatingDialog({VoidCallback? onFinish}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Как тебе эта тема?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ratingColors[index],
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(labels[index]),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _theme != null
                        ? 'Следующее повторение через ${_theme!.predictNextIntervalMinutes(index + 1).toCompactTime()}'
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  if (_theme != null) {
                    await DatabaseHelper()
                        .updateRepetitionSchedule(_theme!, index + 1);
                  }
                  if (onFinish != null) {
                    onFinish();
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showEndOfFavoritesDialog() {
    _flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Повтор завершён'),
        content: const Text('Фраз для повторения больше нет.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, startRoute, (route) => false);
            },
            child: const Text('Назад'),
          ),
        ],
      ),
    );
    _speakRussian('Фраз для повторения больше нет.');
  }

  void _showNextOrChooseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Что дальше?'),
        content: const Text('Выберите действие:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Выбрать тему'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToNextTheme();
            },
            child: const Text('Следующая тема'),
          ),
        ],
      ),
    );
    _speakRussian('Что дальше? Выберите действие.');
  }

  void _goToNextTheme() {
    if (_themeList.isEmpty || _theme == null) return;

    final currentIndex = _themeList.indexWhere((t) => t.id == _theme!.id);
    if (currentIndex == -1 || currentIndex + 1 >= _themeList.length) {
      _showNoMoreThemesDialog();
    } else {
      final nextTheme = _themeList[currentIndex + 1];
      Navigator.pushReplacementNamed(
        context,
        learningPageRoute,
        arguments: {
          'theme': nextTheme,
          'mode': LearningMode.repeatRecommended,
          'themeList': _themeList,
        },
      );
    }
  }

  void _showNoMoreThemesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Темы завершены'),
        content: const Text('Больше тем для повторения нет.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Назад'),
          ),
        ],
      ),
    );
    _speakRussian('Больше тем для повторения нет.');
  }

  Future<void> _speakRussian(String text) async {
    await _flutterTts.setLanguage('ru-RU');
    await _flutterTts.setSpeechRate(_speechRateRu);
    await _flutterTts.setPitch(1.0);
    _flutterTts.speak(text);
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
                    Expanded(child: Center(child: _buildPhraseContent())),
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
        ...current.translationPhrases.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                e,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            )),
        const SizedBox(height: 12),
        Container(width: 60, height: 4, color: Colors.blueAccent),
        const SizedBox(height: 12),
        if (_showingGermanYet)
          ...current.germanPhrases.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  e,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              )),
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
              icon: const Icon(Icons.speed), onPressed: _showSpeedDialog),
          IconButton(
              icon: const Icon(Icons.menu_book),
              onPressed: () {/* TODO: реализация позже */}),
          if (_mode == LearningMode.studyThemes)
            IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: _addCurrentPhraseToFavorites),
          if (_mode == LearningMode.studyThemes)
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (_mode == LearningMode.repeatFavorites) {
                _removeFromFavorites();
              } else {
                _markAsInactive();
              }
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

  void _resetState() {
    _isPlaying = false;
    _repeatCount = 0;
    _showingGermanYet = false;
    _isCancelled = true;
    _flutterTts.stop();
  }

  void _togglePlay() {
    _isPlaying ? _pausePlayback() : _startPlayback();
  }

  void _pausePlayback() {
    setState(() => _isPlaying = false);
    _flutterTts.stop();
  }

  Future<void> _startPlayback() async {
    if (_mode == LearningMode.repeatFavorites &&
        _currentIndex >= _phrases.length - 1) {
      _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
      _showEndOfFavoritesDialog();
      return;
    }
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

    for (var translation in phrase.translationPhrases) {
      if (!_isPlaying || _isCancelled) return;
      await _flutterTts.setLanguage('ru-RU');
      await _flutterTts.setSpeechRate(_speechRateRu);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(translation);
      if (_isPauseBetween) await Future.delayed(phraseGap);
    }

    if (!_isPlaying || _isCancelled) return;
    if (_isPauseBetween) await Future.delayed(Duration(seconds: pauseSeconds));

    setState(() => _showingGermanYet = true);

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

    if (_isPlaying && !_isCancelled) {
      if (_mode == LearningMode.repeatFavorites) {
        if (_currentIndex + 1 < _phrases.length) {
          _nextPhrase(auto: true);
        } else {
          setState(() {
            _isPlaying = false; // жёстко выключаем воспроизведение
          });
          _showEndOfFavoritesDialog();
        }
      } else {
        if (_currentIndex + 1 < _phrases.length) {
          _nextPhrase(auto: true);
        } else {
          _nextPhrase(auto: false);
        }
      }
    }
  }

  void _addCurrentPhraseToFavorites() async {
    final dbHelper = DatabaseHelper();
    final currentPhrase = _phrases[_currentIndex];
    await dbHelper.addPhraseToFavorites(currentPhrase);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Фраза добавлена в "Избранное"')),
    );
  }

  void _removeFromFavorites() async {
    _flutterTts.stop();
    _isCancelled = true;
    _isPlaying = false;

    final dbHelper = DatabaseHelper();
    final currentPhrase = _phrases[_currentIndex];
    await dbHelper.deletePhraseFromFavorites(currentPhrase);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Фраза удалена из "Избранного"')),
    );

    _phrases.removeAt(_currentIndex);
    if (_phrases.isEmpty) {
      _showEndOfFavoritesDialog();
    } else {
      setState(() {
        _currentIndex = _currentIndex % _phrases.length;
      });
      _startPlayback(); // сразу продолжаем проигрывание
    }
  }

  void _markAsInactive() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Фраза помечена как неактивная')),
    );
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
                    onChanged: (value) =>
                        setStateInside(() => tempSpeedFactor = value),
                  ),
                  Text(
                      'Текущая скорость: ${tempSpeedFactor.toStringAsFixed(2)}x'),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена')),
                TextButton(
                  onPressed: () async {
                    final newRealSpeed = tempSpeedFactor * 0.6;
                    await settings.setSpeechRateBase(newRealSpeed);
                    setState(() => _speechRateDe = newRealSpeed);
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
