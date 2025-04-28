import 'package:flutter/material.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/rutes.dart'; // твой файл с маршрутами

class ChooseThemePage extends StatefulWidget {
  final int parentId;
  final String? parentTitle;

  const ChooseThemePage({super.key, this.parentId = 0, this.parentTitle});

  @override
  State<ChooseThemePage> createState() => _ChooseThemePageState();
}

class _ChooseThemePageState extends State<ChooseThemePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _filterController = TextEditingController();

  List<ThemeClass> allThemes = [];
  List<ThemeClass> filteredThemes = [];
  final Set<int> selectedThemeIds = {};
  bool filterA1A2 = true;
  bool filterB1B2 = true;
  bool showTranslations = true;
  bool showGrammarIcons = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
    _filterController.addListener(_applyFilter);
  }

  Future<void> _loadThemes() async {
    List<ThemeClass> result = await dbHelper.getThemesByParentId(widget.parentId);

    // Добавляем Избранное как обычную тему, но только на корневом уровне
    if (widget.parentId == 0) {
      result.insert(0, favoriteSet.copyWith(id: -9999)); // id -9999, чтобы не путаться с реальными id
    }

    setState(() {
      allThemes = result;
      filteredThemes = result;
    });
  }

  void _applyFilter() {
    final query = _filterController.text.toLowerCase();
    final matches = allThemes.where((theme) {
      final matchesQuery = theme.themeNameTranslation.toLowerCase().contains(query) ||
                           theme.themeName.toLowerCase().contains(query);
      final matchesLevel = (filterA1A2 && theme.levels.any((l) => l.startsWith('A'))) ||
                           (filterB1B2 && theme.levels.any((l) => l.startsWith('B')));
      return matchesQuery && matchesLevel;
    }).toList();

    setState(() {
      filteredThemes = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'hero_new',
          child: Text(widget.parentTitle ?? 'Темы'),
        ),
        leading: widget.parentId != 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredThemes.isEmpty
                ? const Center(child: Text('Список пуст'))
                : ListView.builder(
                    itemCount: filteredThemes.length,
                    itemBuilder: (context, index) {
                      final theme = filteredThemes[index];
                      final isFavorite = theme.themeNameTranslation == favoritePhrasesSet;
                      final isFolder = theme.fileName.isEmpty && !isFavorite;

                      return ListTile(
                        leading: isFavorite
                            ? const Icon(Icons.star, color: Colors.amber)
                            : (isFolder ? const Icon(Icons.folder, color: Colors.blue) : null),
                        title: Text(theme.themeNameTranslation),
                        subtitle: showTranslations ? Text(theme.themeName) : null,
                        trailing: !isFolder
                            ? Checkbox(
                                value: selectedThemeIds.contains(theme.id),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedThemeIds.add(theme.id!);
                                    } else {
                                      selectedThemeIds.remove(theme.id);
                                    }
                                  });
                                },
                              )
                            : null,
                        onTap: () {
                          if (isFolder) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChooseThemePage(
                                  parentId: theme.id!,
                                  parentTitle: theme.themeNameTranslation,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: selectedThemeIds.isNotEmpty
          ? Hero(
              tag: 'start_learning_hero',
              child: FloatingActionButton.extended(
                onPressed: () {
                  final selectedThemes = filteredThemes
                      .where((t) => selectedThemeIds.contains(t.id))
                      .map((t) => t.themeNameTranslation)
                      .toList();
                  SettingsAndState.getInstance().chosenThemes = selectedThemes;
                  Navigator.pushNamed(context, learningPageRoute);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Изучать выбранное'),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _filterController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Фильтр по названию темы',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 16,
            children: [
              _buildCheckbox('A1-A2', filterA1A2, (v) => setState(() {
                filterA1A2 = v;
                _applyFilter();
              })),
              _buildCheckbox('B1-B2', filterB1B2, (v) => setState(() {
                filterB1B2 = v;
                _applyFilter();
              })),
              _buildCheckbox('Перевод', showTranslations, (v) => setState(() => showTranslations = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v!)),
        Text(label),
      ],
    );
  }
}
