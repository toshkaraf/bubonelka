// import 'package:bubonelka/rutes.dart';
// import 'package:flutter/material.dart';
// import 'package:bubonelka/classes/theme.dart';
// import 'package:bubonelka/utilites/database_helper.dart';
// class ChooseThemePage extends StatefulWidget {
//   final int parentId;
//   final String? parentTitle;

//   const ChooseThemePage({super.key, this.parentId = 0, this.parentTitle});

//   @override
//   State<ChooseThemePage> createState() => _ChooseThemePageState();
// }

// class _ChooseThemePageState extends State<ChooseThemePage> {
//   List<ThemeClass> themes = [];
//   List<ThemeClass> filteredThemes = [];
//   final TextEditingController _filterController = TextEditingController();
//   final DatabaseHelper dbHelper = DatabaseHelper();
//   final Set<int> selectedThemeIds = {};
//   bool filterA1A2 = true;
//   bool filterB1B2 = true;
//   bool showTranslations = true;
//   bool showGrammarIcons = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadThemes();
//     _filterController.addListener(_applyFilter);
//   }

//   Future<void> _loadThemes() async {
//     final result = await dbHelper.getThemesByParentId(widget.parentId);
//     setState(() {
//       themes = result;
//       filteredThemes = result;
//     });
//   }

//   void _applyFilter() async {
//     final query = _filterController.text.toLowerCase();
//     final allThemes = await dbHelper.getAllThemes();

//     final matches = allThemes.where((t) {
//       final matchesQuery = t.themeNameTranslation.toLowerCase().contains(query) ||
//           t.themeName.toLowerCase().contains(query);
//       final matchesLevel = (filterA1A2 && t.levels.any((l) => l.startsWith('A')))
//           || (filterB1B2 && t.levels.any((l) => l.startsWith('B')));
//       return matchesQuery && matchesLevel;
//     }).toList();

//     setState(() {
//       filteredThemes = query.isEmpty ? themes : matches;
//     });
//   }

//   void _showGrammarDialog(String grammarPath) async {
//     final content = await dbHelper.loadGrammarHtml(grammarPath);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Грамматическая справка'),
//         content: SingleChildScrollView(child: Text(content)),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть'))],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Hero(
//           tag: 'hero_new',
//           child: Text(widget.parentTitle ?? 'Темы'),
//         ),
//         leading: widget.parentId != 0
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () => Navigator.pop(context),
//               )
//             : null,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: TextField(
//               controller: _filterController,
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 labelText: 'Фильтр по названию темы',
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Wrap(
//               spacing: 16,
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Checkbox(
//                       value: filterA1A2,
//                       onChanged: (val) {
//                         setState(() {
//                           filterA1A2 = val!;
//                           _applyFilter();
//                         });
//                       },
//                     ),
//                     const Text('A1-A2'),
//                   ],
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Checkbox(
//                       value: filterB1B2,
//                       onChanged: (val) {
//                         setState(() {
//                           filterB1B2 = val!;
//                           _applyFilter();
//                         });
//                       },
//                     ),
//                     const Text('B1-B2'),
//                   ],
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Checkbox(
//                       value: showTranslations,
//                       onChanged: (val) {
//                         setState(() {
//                           showTranslations = val!;
//                         });
//                       },
//                     ),
//                     const Text('Перевод'),
//                   ],
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Checkbox(
//                       value: showGrammarIcons,
//                       onChanged: (val) {
//                         setState(() {
//                           showGrammarIcons = val!;
//                         });
//                       },
//                     ),
//                     const Text('Грамматика'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: filteredThemes.isEmpty
//                 ? const Center(child: Text('Список пуст'))
//                 : ListView.builder(
//                     itemCount: filteredThemes.length,
//                     itemBuilder: (context, index) {
//                       final theme = filteredThemes[index];
//                       final isFolder = theme.fileName.isEmpty;

//                       return ListTile(
//                         leading: isFolder
//                             ? const Icon(Icons.folder, color: Colors.amber)
//                             : Checkbox(
//                                 value: selectedThemeIds.contains(theme.id),
//                                 onChanged: (val) {
//                                   setState(() {
//                                     if (val == true) {
//                                       selectedThemeIds.add(theme.id!);
//                                     } else {
//                                       selectedThemeIds.remove(theme.id);
//                                     }
//                                   });
//                                 },
//                               ),
//                         title: Text(
//                           theme.themeName,
//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         subtitle: showTranslations
//                             ? Text(
//                                 theme.themeNameTranslation,
//                                 style: const TextStyle(color: Colors.grey, fontSize: 12),
//                               )
//                             : null,
//                         trailing: !isFolder && showGrammarIcons
//                             ? IconButton(
//                                 icon: const Icon(Icons.book, color: Colors.blueAccent),
//                                 onPressed: () => _showGrammarDialog(theme.grammarFilePath),
//                               )
//                             : null,
//                         onTap: () {
//                           if (isFolder) {
//                             Navigator.push(
//                               context,
//                               PageRouteBuilder(
//                                 pageBuilder: (context, animation, secondaryAnimation) => ChooseThemePage(
//                                   parentId: theme.id!,
//                                   parentTitle: theme.themeNameTranslation,
//                                 ),
//                                 transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                   const begin = Offset(1.0, 0.0);
//                                   const end = Offset.zero;
//                                   const curve = Curves.easeInOut;
//                                   final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//                                   return SlideTransition(position: animation.drive(tween), child: child);
//                                 },
//                               ),
//                             );
//                           }
//                         },
//                       );
//                     },
//                   ),
//           )
//         ],
//       ),
//       floatingActionButton: selectedThemeIds.isNotEmpty
//           ? Hero(
//               tag: 'start_learning_hero',
//               child: FloatingActionButton.extended(
//                 onPressed: () {
//                   SettingsAndState.getInstance().chosenThemes =
//                       filteredThemes.where((t) => selectedThemeIds.contains(t.id)).map((t) => t.themeNameTranslation).toList();
//                   Navigator.pushNamed(context, learningPageRoute);
//                 },
//                 icon: const Icon(Icons.play_arrow),
//                 label: const Text('Изучать выбранное'),
//               ),
//             )
//           : null,
//     );
//   }

//   void _showDeleteDialog(ThemeClass theme) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Удалить тему?'),
//         content: Text('Вы действительно хотите удалить тему "${theme.themeNameTranslation}"?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
//           TextButton(
//             onPressed: () async {
//               final dbClient = await dbHelper.database;
//               await dbClient.delete('themes', where: 'id = ?', whereArgs: [theme.id]);
//               Navigator.pop(ctx);
//               _loadThemes();
//             },
//             child: const Text('Удалить', style: TextStyle(color: Colors.red)),
//           )
//         ],
//       ),
//     );
//   }
// }
