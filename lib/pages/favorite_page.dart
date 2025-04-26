// import 'package:flutter/material.dart';
// import 'package:bubonelka/rutes.dart';
// import 'package:bubonelka/pages/edit_phrasecard_page.dart';
// import 'package:bubonelka/const_parameters.dart';
// import 'package:bubonelka/classes/settings_and_state.dart';
// import 'package:bubonelka/utilites/database_helper.dart';
// import 'package:bubonelka/classes/phrase_card.dart';

// class FavoritePhrasesPage extends StatefulWidget {
//   @override
//   _FavoritePhrasesPageState createState() => _FavoritePhrasesPageState();
// }

// class _FavoritePhrasesPageState extends State<FavoritePhrasesPage> {
//   List<PhraseCard> phraseCardsList = [];
//   bool isTranslationFirst = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadFavoritePhrases();
//   }

//   Future<void> _loadFavoritePhrases() async {
//     final db = DatabaseHelper();
//     final all = await db.getPhrasesByThemeNameTranslation(favoritePhrasesSet);
//     final unique = {
//       for (var phrase in all) '${phrase.germanPhrases.join()}-${phrase.translationPhrases.join()}': phrase
//     }.values.toList();
//     setState(() => phraseCardsList = unique);
//   }

//   Future<void> _deletePhraseCard(PhraseCard phraseCard) async {
//     final db = DatabaseHelper();
//     await db.deletePhraseFromFavorites(phraseCard);
//     _loadFavoritePhrases();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Избранное')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 const Text('сначала перевод', style: TextStyle(color: Colors.grey)),
//                 Checkbox(
//                   value: isTranslationFirst,
//                   onChanged: (val) => setState(() => isTranslationFirst = val!),
//                 )
//               ],
//             ),
//           ),
//           Expanded(
//             child: phraseCardsList.isEmpty
//                 ? const Center(child: Text('Список пуст', style: TextStyle(fontSize: 18)))
//                 : ListView.separated(
//                     itemCount: phraseCardsList.length,
//                     separatorBuilder: (context, index) => const Divider(),
//                     itemBuilder: (context, index) {
//                       final phrase = phraseCardsList[index];
//                       final germanText = phrase.germanPhrases.join('\n\n');
//                       final translationText = phrase.translationPhrases.join('\n\n');
//                       final front = isTranslationFirst ? translationText : germanText;
//                       final back = isTranslationFirst ? germanText : translationText;

//                       return ListTile(
//                         title: Text(front, style: const TextStyle(fontWeight: FontWeight.bold)),
//                         subtitle: Text(back),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () => _deletePhraseCard(phrase),
//                         ),
//                         onTap: () async {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EditPhraseCardPage(
//                                 widgetName: editPhrasePageName,
//                                 phraseCard: phrase,
//                                 themeNameTranslation: favoritePhrasesSet,
//                               ),
//                             ),
//                           );
//                           _loadFavoritePhrases();
//                         },
//                       );
//                     },
//                   ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: FloatingActionButton.extended(
//               onPressed: () {
//                 SettingsAndState.getInstance().chosenThemes = [favoritePhrasesSet];
//                 Navigator.pushNamed(context, learningPageRoute);
//               },
//               label: const Text('Начать занятие'),
//               icon: const Icon(Icons.play_arrow),
//               heroTag: 'start_learning_hero',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
