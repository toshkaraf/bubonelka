import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/pages/edit_phrasecard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FavoritePhrasesPage extends StatefulWidget {
  @override
  _FavoritePhrasesPageState createState() => _FavoritePhrasesPageState();
}

class _FavoritePhrasesPageState extends State<FavoritePhrasesPage> {
  final FlutterTts flutterTts = FlutterTts();
  CollectionProvider collectionProvider = CollectionProvider.getInstance();
  List<PhraseCard> phraseCardsList = [];
  bool isTranslationFirst = false;
  double textGap = 3.0; // Уменьшаем расстояние между словом и переводом

  @override
  void initState() {
    super.initState();
    phraseCardsList =
        collectionProvider.getListOfPhrasesForTheme(favoritePhrasesSet) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
            child: phraseCardsList.isEmpty
                ? Center(
                    child: Text(
                      'Список пуст',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: phraseCardsList.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      PhraseCard phraseCard = phraseCardsList[index];
                      String translateText = '';
                      String getmanText = '';

                      for (int i = 0; i < 3; i++) {
                        if (phraseCard.translationPhrase[i] != '') {
                          translateText +=
                              '${phraseCard.translationPhrase[i]}\n\n';
                        }
                        if (phraseCard.germanPhrase[i] != '') {
                          getmanText += '${phraseCard.germanPhrase[i]}\n\n';
                        }
                      }
                      String frontText =
                          isTranslationFirst ? translateText : getmanText;
                      String backText =
                          isTranslationFirst ? getmanText : translateText;

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPhraseCardPage(
                                widgetName: editPhrasePageName,
                                phraseCard: phraseCard,
                                themeNameTranslation: favoritePhrasesSet,
                              ),
                            ),
                          ).then((editedPhraseCard) {
                            setState(() {
                              phraseCardsList =
                                  collectionProvider.getListOfPhrasesForTheme(
                                          favoritePhrasesSet) ??
                                      [];
                            });
                          });
                        },
                        title: Text(
                          frontText,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors
                                .black, // Set the German word text color to black
                            fontWeight: FontWeight.bold, // Remove bold
                          ),
                        ),
                        subtitle: Text(
                          backText,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors
                                .black, // Set the translation text color to black
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            _deletePhraseCard(phraseCard);
                          },
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                // Add logic to start learning with chosen themes
              },
              label: Text('Начать занятие'),
              icon: Icon(Icons.play_arrow),
              heroTag: 'start_learning_hero',
            ),
          ),
        ],
      ),
    );
  }

  void _deletePhraseCard(PhraseCard phraseCard) {
    collectionProvider.deletePhraseCard(phraseCard);
    setState(() {
      phraseCardsList =
          collectionProvider.getListOfPhrasesForTheme(favoritePhrasesSet) ?? [];
    });
  }
}
