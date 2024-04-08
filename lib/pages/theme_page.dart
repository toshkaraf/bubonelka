import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/pages/edit_phrasecard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ThemePage extends StatefulWidget {
  final String themeNameTranslation;

  ThemePage({required this.themeNameTranslation});

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final FlutterTts flutterTts = FlutterTts();
  CollectionProvider collectionProvider = CollectionProvider.getInstance();
  List<PhraseCard> psraseCardsList = [];
  bool isTranslationFirst = false;
  double textGap = 4.0; // Уменьшаем расстояние между словом и переводом
  PhraseCard _chosenflashCard = neutralPhraseCard;

  @override
  void initState() {
    super.initState();
    psraseCardsList = List<PhraseCard>.from(collectionProvider
        .getListOfPhrasesForTheme(widget.themeNameTranslation));
  }

  @override
  void dispose() {
    // collectionProvider.updateAllDictionariesStatistic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.themeNameTranslation), actions: [
        IconButton(
          onPressed: () {
            // Действие для кнопки "Загрузить"
          },
          icon: Icon(
            Icons.file_download, // Иконка "Загрузить"
            color: Colors.grey, // Цвет иконки
          ),
        ),
        IconButton(
          onPressed: () {
            // Действие для кнопки "Скачать"
          },
          icon: Icon(
            Icons.file_upload, // Иконка "Скачать"
            color: Colors.grey, // Цвет иконки
          ),
        ),
      ]),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'сначала перевод',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Checkbox(
                value: isTranslationFirst,
                onChanged: (value) {
                  setState(() {
                    isTranslationFirst = value!;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              itemCount: psraseCardsList.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: dividerWidth),
              itemBuilder: (context, index) {
                PhraseCard phraseCard = psraseCardsList[index];
                String frontText = isTranslationFirst
                    ? phraseCard.translationPhrase.toString()
                    : phraseCard.germanPhrase.toString();
                String backText = isTranslationFirst
                    ? phraseCard.germanPhrase.toString()
                    : phraseCard.translationPhrase.toString();

                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          _chosenflashCard = phraseCard;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPhraseCardPage(
                              widgetName: editPhrasePageName,
                              phraseCard: _chosenflashCard,
                              themeNameTranslation: widget.themeNameTranslation,
                            ),
                          ),
                        ).then((editedPhraseCard) {
                          if (editedPhraseCard.isDeleted) {
                            setState(() {
                              psraseCardsList = List<PhraseCard>.from(
                                  collectionProvider.getListOfPhrasesForTheme(
                                      widget.themeNameTranslation));
                            });
                          } else {
                            setState(() {
                              psraseCardsList = List<PhraseCard>.from(
                                  collectionProvider.getListOfPhrasesForTheme(
                                      widget.themeNameTranslation));
                            });
                          }
                        });
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            frontText,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors
                                  .black, // Set the German word text color to black
                              fontWeight: FontWeight.bold, // Remove bold
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            backText,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors
                                  .black, // Set the translation text color to black
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              speakGermanWord(
                                  phraseCard.germanPhrase.toString());
                            },
                            icon: const Icon(Icons.volume_up),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                phraseCard.toggleActive();
                              });
                            },
                            icon: Checkbox(
                              value: phraseCard.isActive,
                              onChanged: (value) {
                                setState(() {
                                  phraseCard.toggleActive();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: widget.themeNameTranslation !=
            favoritePhrasesSet, // Call a function to determine visibility
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPhraseCardPage(
                  widgetName: createPhrasePageName,
                  phraseCard: neutralPhraseCard,
                  themeNameTranslation: widget.themeNameTranslation,
                ),
              ),
            ).then((editedPhraseCard) {
              if (!editedPhraseCard.isDeleted) {
                // collectionProvider.addToMapOfAllDictionaries(editedPhraseCard);
                setState(() {
                  // psraseCardsList.add(editedPhraseCard);
                  psraseCardsList = List<PhraseCard>.from(collectionProvider
                      .getListOfPhrasesForTheme(widget.themeNameTranslation));
                });
              }
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void speakGermanWord(String word) async {
    await flutterTts.setLanguage('de-DE');
    await flutterTts.speak(word);
  }
}
