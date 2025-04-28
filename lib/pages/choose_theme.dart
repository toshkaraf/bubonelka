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
  final Set<int> selectedThemeIds = {}; 

  bool filterA1A2 = true;
  bool filterB1B2 = true;
  bool showTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
    _filterController.addListener(_applyFilterAndExpand);
  }

  Future<void> _loadThemes() async {
    List<ThemeClass> result = await dbHelper.getThemesByParentId(widget.parentId);
    result.sort((a, b) => a.position.compareTo(b.position));
    setState(() {
      allThemes = result;
    });
  }

  void _applyFilterAndExpand() async {
    expandedIds.clear();
    setState(() {});
  }

  bool _matchesFilter(ThemeClass theme) {
    final query = _filterController.text.toLowerCase();
    final matchesQuery = theme.themeName.toLowerCase().contains(query) ||
        theme.themeNameTranslation.toLowerCase().contains(query);
    final matchesLevel = (filterA1A2 && theme.levels.any((l) => l.startsWith('A')))
        || (filterB1B2 && theme.levels.any((l) => l.startsWith('B')));
    return matchesQuery && matchesLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: 'hero_new', child: Text(widget.parentTitle ?? 'Темы')),
        leading: widget.parentId != 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)) : null,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildFilterOptions(),
          Expanded(child: _buildThemeTree(allThemes)),
        ],
      ),
      floatingActionButton: selectedThemeIds.isNotEmpty
          ? Hero(
              tag: 'start_learning_hero',
              child: FloatingActionButton.extended(
                onPressed: _startLearning,
                label: const Text('Начать изучение'),
                icon: const Icon(Icons.play_arrow),
              ),
            )
          : null,
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
                onChanged: (val) {
                  setState(() {
                    filterA1A2 = val!;
                  });
                },
              ),
              const Text('A1-A2'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: filterB1B2,
                onChanged: (val) {
                  setState(() {
                    filterB1B2 = val!;
                  });
                },
              ),
              const Text('B1-B2'),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: showTranslations,
                onChanged: (val) {
                  setState(() {
                    showTranslations = val!;
                  });
                },
              ),
              const Text('Перевод'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTree(List<ThemeClass> themes) {
    final filtered = themes.where(_matchesFilter).toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return ListView(
      children: filtered.map((theme) => FutureBuilder<bool>(
        future: dbHelper.hasSubthemes(theme.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          final isFolder = snapshot.data ?? false;
          return isFolder ? _buildFolder(theme) : _buildThemeTile(theme);
        },
      )).toList(),
    );
  }

    Widget _buildFolder(ThemeClass theme) {
    final bool shouldExpandAutomatically = _shouldExpand(theme);
    final isExpanded = expandedIds.contains(theme.id) || shouldExpandAutomatically;
    if (shouldExpandAutomatically) expandedIds.add(theme.id!);

    return ExpansionTile(
      leading: Icon(isExpanded ? Icons.folder_open : Icons.folder, color: Colors.amber),
      title: Text(theme.themeName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: showTranslations ? Text(theme.themeNameTranslation, style: const TextStyle(color: Colors.grey)) : null,
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
      children: [
        FutureBuilder<List<ThemeClass>>(
          future: dbHelper.getThemesByParentId(theme.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final children = (snapshot.data ?? [])
                .where((e) {
                  if (_filterController.text.isEmpty && filterA1A2 && filterB1B2) {
                    return true;
                  }
                  return _matchesFilter(e);
                })
                .toList()
                ..sort((a, b) => a.position.compareTo(b.position));
            return Column(
              children: children.map((e) => FutureBuilder<bool>(
                future: dbHelper.hasSubthemes(e.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  final isSubFolder = snapshot.data ?? false;
                  return isSubFolder ? _buildFolder(e) : _buildThemeTile(e);
                },
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  bool _shouldExpand(ThemeClass theme) {
    final query = _filterController.text.toLowerCase();
    if (query.isEmpty) return false;
    return theme.themeName.toLowerCase().contains(query) ||
           theme.themeNameTranslation.toLowerCase().contains(query);
  }

  Widget _buildThemeTile(ThemeClass theme) {
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.menu_book, color: Colors.blueAccent),
        onPressed: () => _showGrammarDialog(theme.grammarFilePath),
      ),
      title: Text(theme.themeName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: showTranslations ? Text(theme.themeNameTranslation, style: const TextStyle(color: Colors.grey)) : null,
      trailing: Checkbox(
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
      ),
    );
  }

  void _showGrammarDialog(String grammarPath) async {
    final content = await dbHelper.loadGrammarHtml(grammarPath);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Грамматическая справка'),
        content: SingleChildScrollView(child: Text(content)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть'))],
      ),
    );
  }

  void _startLearning() {
    final selectedThemes = selectedThemeIds.map((id) =>
      allThemes.firstWhere((theme) => theme.id == id, orElse: () => ThemeClass(themeNameTranslation: '', themeName: '', fileName: '', numberOfRepetition: 0, parentId: 0)).themeNameTranslation).toList();

    SettingsAndState.getInstance().chosenThemes = selectedThemes;
    Navigator.pushNamed(context, learningPageRoute);
  }
}
