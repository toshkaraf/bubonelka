import 'package:bubonelka/pages/learning_page.dart';
import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/classes/theme.dart';

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
  final Set<int> expandedIds = {};

  bool filterA1A2 = true;
  bool filterB1B2 = true;
  bool showTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadAllThemes();
    _filterController.addListener(_applyFilter);
  }

  Future<void> _loadAllThemes() async {
    final themes = await dbHelper.getAllThemes();
    setState(() {
      allThemes = themes..sort((a, b) => a.position.compareTo(b.position));
    });
  }

  void _applyFilter() {
    setState(() {
      expandedIds.clear();
      if (_filterController.text.isNotEmpty) {
        _expandMatchingThemes();
      }
    });
  }

  void _expandMatchingThemes() {
    final query = _filterController.text.toLowerCase();
    for (var theme in allThemes) {
      if (theme.themeName.toLowerCase().contains(query) ||
          theme.themeNameTranslation.toLowerCase().contains(query)) {
        expandedIds.add(theme.parentId);
      }
    }
  }

  bool _matchesFilter(ThemeClass theme) {
    final query = _filterController.text.toLowerCase();
    final matchesQuery = theme.themeName.toLowerCase().contains(query) ||
        theme.themeNameTranslation.toLowerCase().contains(query);
    final matchesLevel =
        (filterA1A2 && theme.levels.any((l) => l.startsWith('A'))) ||
            (filterB1B2 && theme.levels.any((l) => l.startsWith('B')));
    if (query.isEmpty && filterA1A2 && filterB1B2) return true;
    return matchesQuery && matchesLevel;
  }

List<ThemeClass> _getChildren(int parentId) {
  return allThemes
      .where((theme) =>
          theme.parentId == parentId &&
          theme.themeName != favoritePhrasesSet) // 🔥 Исключаем "Избранное"
      .where(_matchesFilter)
      .toList()
    ..sort((a, b) => a.position.compareTo(b.position));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: 'hero_new', child: Text(widget.parentTitle ?? 'Темы')),
        leading: widget.parentId != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context))
            : null,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildFilterOptions(),
          Expanded(
            child: ListView(
              children: _buildThemeTree(widget.parentId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _filterController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Фильтр по названию темы',
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: filterA1A2,
                onChanged: (val) => setState(() => filterA1A2 = val!),
              ),
              const Text('A1-A2'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: filterB1B2,
                onChanged: (val) => setState(() => filterB1B2 = val!),
              ),
              const Text('B1-B2'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: showTranslations,
                onChanged: (val) => setState(() => showTranslations = val!),
              ),
              const Text('Перевод'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildThemeTree(int parentId) {
    final children = _getChildren(parentId);

    if (children.isEmpty) {
      return [];
    }

    return children.map((theme) {
      final hasChildren = allThemes.any((t) => t.parentId == theme.id);
      if (hasChildren) {
        final isExpanded = expandedIds.contains(theme.id);
        return ExpansionTile(
          leading: Icon(isExpanded ? Icons.folder_open : Icons.folder,
              color: Colors.amber),
          title: Text(theme.themeName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: showTranslations
              ? Text(theme.themeNameTranslation,
                  style: const TextStyle(color: Colors.grey))
              : null,
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                expandedIds.add(theme.id!);
              } else {
                expandedIds.remove(theme.id);
              }
            });
          },
          children: _buildThemeTree(theme.id!),
        );
      } else {
        return ListTile(
          leading: IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.blueAccent),
            onPressed: () => _showGrammarDialog(theme.grammarFilePath),
          ),
          title: Text(theme.themeName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: showTranslations
              ? Text(theme.themeNameTranslation,
                  style: const TextStyle(color: Colors.grey))
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            onPressed: () => _startSingleThemeLearning(theme),
          ),
          onTap: () => _showGrammarDialog(theme.grammarFilePath),
        );
      }
    }).toList();
  }

  void _showGrammarDialog(String grammarPath) async {
    final content = await dbHelper.loadGrammarHtml(grammarPath);
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

  void _startSingleThemeLearning(ThemeClass theme) {
    SettingsAndState.getInstance().chosenThemes = [theme.themeNameTranslation];
    Navigator.pushNamed(
      context,
      learningPageRoute,
      arguments: {
        'theme': theme,
        'mode': LearningMode.studyThemes,
      },
    );
  }
}
