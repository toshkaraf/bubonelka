import 'dart:io';
import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/pages/theme_page.dart';
import 'package:flutter/material.dart';

class ThemesListPage extends StatefulWidget {
  @override
  State<ThemesListPage> createState() => _ThemesListPageState();
}

class _ThemesListPageState extends State<ThemesListPage> {
  SettingsAndState settingsAndState = SettingsAndState.getInstance();
  CollectionProvider collectionProvider = CollectionProvider.getInstance();

  final TextEditingController _themeTranslationNameController =
      TextEditingController();
  final TextEditingController _themeNameController = TextEditingController();
  final TextEditingController _filterController = TextEditingController(); // Add filter controller

  List<String> listOfThemesTranslations =
      CollectionProvider.getInstance().themesMap.keys.toList();

  bool _isNewThemeTranslationNameFieldFocused = false;
  bool _isNewThemeNameFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() {
      setState(() {
        listOfThemesTranslations = CollectionProvider.getInstance()
            .themesMap
            .keys
            .where((theme) => theme
                .toLowerCase()
                .contains(_filterController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фразы по темам'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Фильтр по названию темы',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listOfThemesTranslations.length,
              itemBuilder: (context, index) {
                String themeNameTranslation = listOfThemesTranslations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThemePage(
                          themeNameTranslation: themeNameTranslation,
                        ),
                      ),
                    ).then((result) {
                      if (result == null) {
                        setState(() {});
                      }
                    });
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          themeNameTranslation,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Navigate to help page
                                Navigator.pushNamed(context, '/help');
                              },
                              icon: Icon(
                                Icons.book,
                                color: Colors.grey,
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      'Удалить тему',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      // Show confirmation dialog
                                      _showDeleteConfirmationDialog(
                                          themeNameTranslation);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "проработано ${collectionProvider.themesMap[themeNameTranslation]!.numberOfRepetition} раз",
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddThemeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddThemeDialog(BuildContext context) {
    _themeTranslationNameController.text = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Center(child: Text('Новая тема:')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15.0),
              TextField(
                controller: _themeTranslationNameController,
                decoration: InputDecoration(
                  hintText: _isNewThemeTranslationNameFieldFocused
                      ? ''
                      : 'Название темы',
                ),
                onChanged: (value) {
                  setState(() {
                    _isNewThemeTranslationNameFieldFocused = true;
                  });
                },
              ),
              const SizedBox(height: 30.0),
              TextField(
                controller: _themeNameController,
                decoration: InputDecoration(
                  hintText: _isNewThemeNameFieldFocused
                      ? ''
                      : 'Titel auf Deutsch',
                ),
                onChanged: (value) {
                  setState(() {
                    _isNewThemeNameFieldFocused = true;
                  });
                },
              ),
              const SizedBox(height: 30.0),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      if (_themeTranslationNameController.text.isEmpty) {
                        _showNoThemeNameDialog();
                      } else {
                        setState(() {
                          try {
                            collectionProvider.addNewTheme(
                                _themeTranslationNameController.text,
                                _themeNameController.text);
                            listOfThemesTranslations =
                                collectionProvider.themesMap.keys.toList();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Словарь с таким именем уже существует",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    Colors.red, // Цвет Snackbar для ошибки
                              ),
                            );
                          }
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Создать',
                        style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(height: 8.0),
                  TextButton.icon(
                    onPressed: () async {
                      if (_themeTranslationNameController.text.isEmpty) {
                        _showNoThemeNameDialog();
                      } else {
                        // _loadThemeFromFile();
                        // setState(() {
                        //   settingsAndState.addNewThemeName(
                        //       _themeTranslationNameController.text);
                        // });
                        // Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.file_upload, color: Colors.blue),
                    label: const Text('Из файла',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                _showHelpDialog();
              },
              icon:
                  const Icon(Icons.help_outline, size: 30, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String themeNameTranslation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('УДАЛЕНИЕ ТЕМЫ'),
          content: const Text('Вы уверены, что хотите удалить тему?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отменить'),
            ),
            TextButton(
              onPressed: () {
                collectionProvider.deleteTheme(themeNameTranslation);
                setState(() {
                  listOfThemesTranslations =
                      collectionProvider.themesMap.keys.toList();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Подтвердить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ).then((_) {
      // Refresh the state after dialog is closed
      setState(() {});
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Справка'),
          content: Text(
            'Тут вы можете учить новые слова. Нажмите на слова для изучения '
            'или на кнопку "Выбери слова для изучения", чтобы выбрать слова '
            'для изучения из доступных словарей. Затем нажмите на карту, чтобы начать.',
          ),
        );
      },
    );
  }

  void _showNoThemeNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text(
            'Введите название темы',
          ),
        );
      },
    );
  }
}
