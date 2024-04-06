import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';


class ThemePage extends StatefulWidget {
  final String themeName;

  ThemePage({required this.themeName});

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final FlutterTts flutterTts = FlutterTts();
  CollectionProvider collectionProvider = CollectionProvider.getInstance();
  List<PhraseCard> phraseCards = [];
  bool isTranslationFirst = false;
  double textGap = 4.0; // Уменьшаем расстояние между словом и переводом
  PhraseCard? _chosenPhraseCard;

  @override
  void initState() {
    super.initState();
   phraseCards = collectionProvider.getListOfPhrasesForTheme(widget.themeName) != null
    ? List<PhraseCard>.from(collectionProvider.getListOfPhrasesForTheme(widget.themeName)!)
    : [];

  }

  @override
  void dispose() {
    // collectionProvider.updateAllDictionariesStatistic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.themeName), actions: [
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
      //   children: [
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         const Text(
      //           'сначала перевод',
      //           style: TextStyle(fontSize: 16, color: Colors.grey),
      //         ),
      //         Checkbox(
      //           value: isTranslationFirst,
      //           onChanged: (value) {
      //             setState(() {
      //               isTranslationFirst = value!;
      //             });
      //           },
      //           activeColor: Colors.blue,
      //         ),
      //       ],
      //     ),
      //     Expanded(
      //       child: ListView.separated(
      //         itemCount: phraseCards.length,
      //         separatorBuilder: (context, index) =>
      //             SizedBox(width: dividerWidth),
      //         itemBuilder: (context, index) {
      //           PhraseCard phraseCard = phraseCards[index];
      //           String frontText = isTranslationFirst
      //               ? phraseCard.translation
      //               : phraseCard.germanWord;
      //           String backText = isTranslationFirst
      //               ? phraseCard.germanWord
      //               : phraseCard.translation;

      //           return Column(
      //             children: [
      //               ListTile(
      //                 onTap: () {
      //                   setState(() {
      //                     _chosenPhraseCard = PhraseCard;
      //                   });
      //                   Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       builder: (context) => EditPhraseCardPage(
      //                         widgetName: editCardPageName,
      //                         PhraseCard: _chosenPhraseCard,
      //                         themeName: themeName,
      //                       ),
      //                     ),
      //                   ).then((editedPhraseCard) {
      //                     if (editedPhraseCard.isDeleted) {
      //                       setState(() {
      //                         phraseCards.remove(_chosenPhraseCard);
      //                       });
      //                     } else {
      //                       setState(() {
      //                         phraseCards.remove(_chosenPhraseCard);
      //                         phraseCards.add(editedPhraseCard);
      //                       });
      //                     }
      //                   });
      //                 },
      //                 title: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     const SizedBox(height: 4),
      //                     Text(
      //                       frontText,
      //                       style: const TextStyle(
      //                         fontSize: 16.0,
      //                         color: Colors
      //                             .black, // Set the German word text color to black
      //                         fontWeight: FontWeight.bold, // Remove bold
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 subtitle: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     const SizedBox(height: 8),
      //                     Text(
      //                       backText,
      //                       style: const TextStyle(
      //                         fontSize: 14.0,
      //                         color: Colors
      //                             .black, // Set the translation text color to black
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 trailing: Row(
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     IconButton(
      //                       onPressed: () {
      //                         speakGermanWord(PhraseCard.germanWord);
      //                       },
      //                       icon: const Icon(Icons.volume_up),
      //                     ),
      //                     IconButton(
      //                       onPressed: () {
      //                         setState(() {
      //                           PhraseCard.toggleFavorite();
      //                         });
      //                       },
      //                       icon: Icon(
      //                         Icons.star,
      //                         color: PhraseCard.isFavorite
      //                             ? Colors.blue
      //                             : Colors.grey,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               const Divider(),
      //             ],
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      ),
      // floatingActionButton: Visibility(
      //   visible: themeName != favoriteDictionaryName, // Call a function to determine visibility
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => EditPhraseCardPage(
      //             widgetName: createCardPageName,
      //             PhraseCard: emptyPhraseCard,
      //             themeName: themeName,
      //           ),
      //         ),
      //       ).then((editedPhraseCard) {
      //         if (!editedPhraseCard.isDeleted) {
      //           collectionProvider.addToMapOfAllDictionaries(editedPhraseCard);
      //           setState(() {
      //             PhraseCards.add(editedPhraseCard);
      //           });
      //         }
      //       });
      //     },
      //     child: Icon(Icons.add),
      //   ),
      // ),
    );
  }

  void speakGermanWord(String word) async {
    await flutterTts.setLanguage('de-DE');
    await flutterTts.speak(word);
  }
}