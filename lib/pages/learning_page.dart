import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/pages/current_phrases_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LearningPage extends StatefulWidget {
  @override
  _LearningPageState createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  CurrentPhrasesSet currentPhrasesSet = CurrentPhrasesSet();
  bool isGerman = false;
  bool _isPaused = false;
  double _speechRate = 0.5;
  bool _isPauseButtonActive = false; // upper menu
  PhraseCard _currentPhrase = neutralPhraseCard;
  List<String> _currentTextOnScreen = [];

  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    getNextPhraseCard();
  }

  @override
  void dispose() {
    flutterTts.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubonelka'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            color: Colors.black,
            onPressed: () {
              // Add help action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RoundedSwitch(
                value: _isPauseButtonActive,
                onChanged: (newValue) {
                  setState(() {
                    _isPauseButtonActive =
                        !_isPauseButtonActive; // Устанавливаем новое значение паузы/воспроизведения
                  });
                },
              ),
              TransparentIconButton(
                  icon: Icons.speed,
                  onPressed: () {
                    _showSpeedDialog(context);
                  }),
              TransparentIconButton(icon: Icons.book, onPressed: () {}),
              TransparentIconButton(
                  icon: Icons.star,
                  onPressed: () {
                    _currentPhrase.themeNameTranslation = favoritePhrasesSet;
                    CollectionProvider.getInstance()
                        .getTotalCollection()[favoritePhrasesSet]!
                        .add(_currentPhrase);
                    _showFavoriteSnackbar(context);
                  }),
            ],
          ),
          SizedBox(height: 20),
          _buildPhrases(),
          Spacer(),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoundedIconButton(
                    icon: Icons.skip_previous,
                    onPressed: () {
                      _isPaused = true;
                      getPreviousPhraseCard();
                    }),
                RoundedIconButton(
                    icon: _isPaused ? Icons.play_arrow : Icons.pause,
                    onPressed: () {
                      setState(() {
                        _isPaused = !_isPaused;
                      }); // Переключаем состояние паузы/воспроизведения
                      if (_isPaused) {
                        flutterTts.pause();
                      } else {
                        _speakPhrases();
                      }
                    }),
                RoundedIconButton(
                    icon: Icons.skip_next,
                    onPressed: () {
                      _isPaused = true;
                      _speakPhrases();
                      getNextPhraseCard();
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrases() {
    return Column(
      children: _currentTextOnScreen.map((phrase) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            phrase,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        );
      }).toList(),
    );
  }

  void _speakPhrases() async {
    await flutterTts.setLanguage('ru-RU');
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.setPitch(1);

    setState(() {
      _currentTextOnScreen = _currentPhrase.translationPhrase;
    });

    for (String phrase in _currentPhrase.translationPhrase) {
      if (!_isPaused) {
        await flutterTts.speak(phrase);
        await flutterTts.awaitSpeakCompletion(
            true); // Дождаться окончания озвучивания текущей фразы
      }
    }

    if (_isPauseButtonActive) {
      await Future.delayed(Duration(seconds: delayBeforGermanPhraseInSeconds));
    }

    if (!_isPaused) {
      setState(() {
        _currentTextOnScreen = _currentPhrase.germanPhrase;
      });
    }

    await flutterTts.setLanguage('de-DE');
    for (int i = 0; i < 3; i++) {
      for (String phrase in _currentPhrase.germanPhrase) {
        if (!_isPaused) {
          await flutterTts.speak(phrase);
          await flutterTts.awaitSpeakCompletion(true);
        } // Дождаться окончания озвучивания текущей фразы
      }
    }

    if (_currentPhrase != emptyPhraseCard && !_isPaused) {
      getNextPhraseCard();
    }
  }

  void getNextPhraseCard() {
    if (_currentPhrase != emptyPhraseCard) {
      _currentPhrase = currentPhrasesSet.getNextPhraseCard();
      // _isPaused = false;
      _speakPhrases();
    }
  }

  void getPreviousPhraseCard() {
    if (_currentPhrase != emptyPhraseCard) {
      _currentPhrase = currentPhrasesSet.getPreviousPhraseCard();
      _speakPhrases();
    }
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SpeedSliderDialog(
          initialValue: _speechRate,
          onChanged: (double value) {
            setState(() {
              _speechRate = value;
            });
          },
        );
      },
    );
  }

  void _showFavoriteSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Фраза добавлена в Избранное'),
      action: SnackBarAction(
        label: 'Открыть',
        onPressed: () {
          // Действие при нажатии на кнопку "Открыть"
          // Можно добавить переход на экран "Избранное"
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class SpeedSliderDialog extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double>? onChanged;

  SpeedSliderDialog({Key? key, required this.initialValue, this.onChanged})
      : super(key: key);

  @override
  _SpeedSliderDialogState createState() => _SpeedSliderDialogState();
}

class _SpeedSliderDialogState extends State<SpeedSliderDialog> {
  late double _tempSpeedRate;
  final double minSpeed = 0.1; // Минимальное значение скорости
  final double maxSpeed = 2.0; // Максимальное значение скорости

  @override
  void initState() {
    super.initState();
    _tempSpeedRate = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите скорость'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: (_tempSpeedRate - minSpeed) *
                    100 /
                    (maxSpeed - minSpeed) *
                    2.5 +
                50,
            min: 50,
            max: 200,
            divisions: 15, // С учетом диапазона от 50% до 200%
            label: '${(_tempSpeedRate * 100).round()}%',
            onChanged: (double value) {
              setState(() {
                _tempSpeedRate =
                    (value - 50) / 2.5 / 100 * (maxSpeed - minSpeed) + minSpeed;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Закрываем диалоговое окно и передаем новое значение скорости в родительский виджет
            widget.onChanged?.call(_tempSpeedRate.clamp(minSpeed, maxSpeed));
            Navigator.of(context).pop();
          },
          child: Text('Закрыть'),
        ),
      ],
    );
  }
}

class TransparentIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const TransparentIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.black,
      iconSize: 35,
      onPressed: onPressed,
    );
  }
}

// Виджет RoundedSwitch

class RoundedSwitch extends StatelessWidget {
  final bool value; // Значение переключателя
  final ValueChanged<bool>? onChanged; // Обратный вызов при изменении состояния

  const RoundedSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.black,
        onPressed: onPressed,
      ),
    );
  }
}
