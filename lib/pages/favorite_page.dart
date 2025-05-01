import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/pages/learning_page.dart';

class FavoritePhrasesPage extends StatefulWidget {
  const FavoritePhrasesPage({super.key});

  @override
  State<FavoritePhrasesPage> createState() => _FavoritePhrasesPageState();
}

class _FavoritePhrasesPageState extends State<FavoritePhrasesPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<PhraseCard> phraseCardsList = [];
  bool showTranslation = false;

  @override
  void initState() {
    super.initState();
    _loadFavoritePhrases();
  }

  Future<void> _loadFavoritePhrases() async {
    final phrases =
        await dbHelper.getPhrasesForTheme(themeName: favoritePhrasesSet);
    final unique = {
      for (var phrase in phrases)
        '${phrase.germanPhrases.join()}-${phrase.translationPhrases.join()}':
            phrase
    }.values.toList();
    setState(() => phraseCardsList = unique);
  }

  Future<void> _deletePhraseCard(PhraseCard phraseCard) async {
    await dbHelper.deletePhraseFromFavorites(phraseCard);
    await _loadFavoritePhrases();
  }

  Future<void> _clearFavorites() async {
    final db = await dbHelper.database;
    await db.delete(DatabaseHelper.tablePhraseCard,
        where: 'theme_name = ?', whereArgs: [favoritePhrasesSet]);
    await _loadFavoritePhrases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        actions: [
          if (phraseCardsList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _confirmClearFavorites,
              tooltip: 'Очистить всё',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Перевод', style: TextStyle(color: Colors.grey)),
                Checkbox(
                  value: showTranslation,
                  onChanged: (val) => setState(() => showTranslation = val!),
                ),
              ],
            ),
          ),
          Expanded(
            child: phraseCardsList.isEmpty
                ? const Center(
                    child: Text('Список пуст', style: TextStyle(fontSize: 18)))
                : ListView.separated(
                    itemCount: phraseCardsList.length,
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 2,
                      color: Colors.grey, // Сделал разделитель более заметным
                    ),
                    itemBuilder: (context, index) {
                      final phrase = phraseCardsList[index];
                      final germanText = phrase.germanPhrases.join('\n\n');
                      final translationText =
                          phrase.translationPhrases.join('\n\n');

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              germanText,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (showTranslation) ...[
                              const SizedBox(height: 12),
                              Text(
                                translationText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_book,
                                  color: Colors.blueAccent),
                              tooltip: 'Грамматическая справка',
                              onPressed: () {
                                // Заглушка
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Здесь будет вызов грамматической справки'),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deletePhraseCard(phrase),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton.extended(
              heroTag: 'start_learning_hero_favorite',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  learningPageRoute,
                  arguments: {
                    'mode': LearningMode.repeatFavorites,
                  },
                );
              },
              label: const Text('Начать занятие'),
              icon: const Icon(Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearFavorites() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить избранное?'),
        content: const Text(
            'Вы уверены, что хотите удалить все фразы из избранного?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _clearFavorites();
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
