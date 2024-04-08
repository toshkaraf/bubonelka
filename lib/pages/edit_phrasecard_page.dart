import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EditPhraseCardPage extends StatefulWidget {
  PhraseCard phraseCard;
  String themeNameTranslation;
  final String widgetName;
  String selectedTheme; // Выбранный словарь

  EditPhraseCardPage({
    required this.widgetName,
    required this.phraseCard,
    required this.themeNameTranslation,
  }) : selectedTheme = themeNameTranslation;

  @override
  _EditPhraseCardPageState createState() => _EditPhraseCardPageState();
}

class _EditPhraseCardPageState extends State<EditPhraseCardPage> {
  CollectionProvider collectionProvider = CollectionProvider.getInstance();
  late TextEditingController _germanPhraseController_1;
  late TextEditingController _translationPhraseController_1;
  late TextEditingController _germanPhraseController_2;
  late TextEditingController _translationPhraseController_2;
  late TextEditingController _germanPhraseController_3;
  late TextEditingController _translationPhraseController_3;
  final FlutterTts flutterTts = FlutterTts();
  SettingsAndState settingsAndState = SettingsAndState.getInstance();
  late String text;

  @override
  @override
  void initState() {
    super.initState();
    _germanPhraseController_1 =
        TextEditingController(text: widget.phraseCard.germanPhrase[0]);
    _translationPhraseController_1 =
        TextEditingController(text: widget.phraseCard.translationPhrase[0]);
    _germanPhraseController_2 = TextEditingController(
        text: widget.phraseCard.germanPhrase.length > 1
            ? widget.phraseCard.germanPhrase[1]
            : '');
    _translationPhraseController_2 = TextEditingController(
        text: widget.phraseCard.translationPhrase.length > 1
            ? widget.phraseCard.translationPhrase[1]
            : '');
    _germanPhraseController_3 = TextEditingController(
        text: widget.phraseCard.germanPhrase.length > 2
            ? widget.phraseCard.germanPhrase[2]
            : '');
    _translationPhraseController_3 = TextEditingController(
        text: widget.phraseCard.translationPhrase.length > 2
            ? widget.phraseCard.translationPhrase[2]
            : '');
  }

  @override
  void dispose() {
    _germanPhraseController_1.dispose();
    _translationPhraseController_1.dispose();
    _germanPhraseController_2.dispose();
    _translationPhraseController_2.dispose();
    _germanPhraseController_3.dispose();
    _translationPhraseController_3.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _saveChanges() {
    if (_germanPhraseController_1.text.isEmpty) {
      _showSnackBar("Минимум одна фраза должна быть заполнена");
      return;
    }

    List<String> translationPhrase = [
      _translationPhraseController_1.text,
      _translationPhraseController_2.text,
      _translationPhraseController_3.text,
    ];

    List<String> germanPhrase = [
      _germanPhraseController_1.text,
      _germanPhraseController_2.text,
      _germanPhraseController_3.text,
    ];

    PhraseCard phraseCard = PhraseCard(
      themeNameTranslation: widget.selectedTheme,
      translationPhrase: translationPhrase,
      germanPhrase: germanPhrase,
      isActive: true,
    );

    collectionProvider.replacePhraseCard(widget.phraseCard, phraseCard);
    settingsAndState.currentThemeName = widget.selectedTheme;
    Navigator.pop(context, widget.phraseCard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.widgetName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (widget.widgetName == createCardPageName)
                    DropdownButton<String>(
                      value: widget.selectedTheme,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          widget.selectedTheme = newValue ??
                              ''; // Обновляем значение selectedTheme
                        });
                      },
                      items: collectionProvider
                          .getListOfThemesNames()
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            width: 200, // Установите желаемую ширину
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _germanPhraseController_1,
                      labelText: "Немецкая фраза 1",
                    ),
                    _buildTextField(
                      controller: _translationPhraseController_1,
                      labelText: "Перевод фразы 1",
                    ),
                    _buildTextField(
                      controller: _germanPhraseController_2,
                      labelText: "Немецкая фраза 2",
                    ),
                    _buildTextField(
                      controller: _translationPhraseController_2,
                      labelText: "Перевод фразы 2",
                    ),
                    _buildTextField(
                      controller: _germanPhraseController_3,
                      labelText: "Немецкая фраза 3",
                    ),
                    _buildTextField(
                      controller: _translationPhraseController_3,
                      labelText: "Перевод фразы 3",
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.widgetName == editPhrasePageName)
                  ElevatedButton(
                    onPressed: () {
                      _deletePhraseCard();
                    },
                    style: ElevatedButton.styleFrom(),
                    child: const Text(
                      "Удалить",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                if (widget.widgetName != editPhrasePageName)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(),
                    child: const Text(
                      "Отменить",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text(
                    "Сохранить",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            controller.clear();
          },
          icon: const Icon(
            Icons.clear, // Иконка для очистки текстового поля
            color: Colors.grey, // Цвет иконки
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }

  void _deletePhraseCard() {
    collectionProvider.deletePhraseCard(widget.phraseCard!);
    widget.phraseCard!.isDeleted = true;
    Navigator.pop(context, widget.phraseCard);
  }
}
