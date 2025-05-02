import 'package:bubonelka/rutes.dart';
import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/pages/learning_page.dart';

class ThemePage extends StatefulWidget {
  final ThemeClass theme;

  const ThemePage({super.key, required this.theme});

  @override
  State<ThemePage> createState() => _ThemeListPageState();
}

class _ThemeListPageState extends State<ThemePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<PhraseCard> phraseCardsList = [];
  bool showTranslation = false;

  @override
  void initState() {
    super.initState();
    _loadThemePhrases();
  }

  Future<void> _loadThemePhrases() async {
    final phrases = await dbHelper.getPhrasesForTheme(themeId: widget.theme.id!);
    setState(() => phraseCardsList = phrases);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.theme.themeName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: _showGrammarDialog, // пока заглушка
                  child: Row(
                    children: const [
                      Icon(Icons.menu_book, color: Colors.blueAccent),
                      SizedBox(width: 6),
                      Text(
                        'Справка по теме',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Перевод',
                  style: TextStyle(color: Colors.grey),
                ),
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
                      color: Colors.grey,
                    ),
                    itemBuilder: (context, index) {
                      final phrase = phraseCardsList[index];

                      // Собираем пары фраза + перевод
                      final pairs = <Widget>[];
                      final germanList = phrase.germanPhrases;
                      final translationList = phrase.translationPhrases;

                      final count = germanList.length; // обычно 1-3

                      for (int i = 0; i < count; i++) {
                        if (germanList[i].isEmpty) continue;
                        pairs.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  germanList[i],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (showTranslation && translationList.length > i)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      translationList[i],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: pairs,
                        ),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Редактировать фразу',
                              onPressed: () {
                                // Заглушка для редактирования
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Здесь будет переход в редактор фразы'),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Удалить фразу',
                              onPressed: () {
                                // Заглушка для удаления
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Здесь будет удаление фразы из темы'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: phraseCardsList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: 200,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      learningPageRoute,
                      arguments: {
                        'theme': widget.theme,
                        'mode': LearningMode.studyThemes,
                      },
                    );
                  },
                  label: const Text('Начать изучение'),
                  icon: const Icon(Icons.play_arrow),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showGrammarDialog() {
    // Заглушка для вызова грамматической справки
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Здесь будет вызов грамматической справки')),
    );
  }
}
