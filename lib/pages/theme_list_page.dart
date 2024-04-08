import 'dart:io';
import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/pages/theme_page.dart';
import 'package:flutter/material.dart';

class ThemesListPage extends StatefulWidget {
  @override
  State<ThemesListPage> createState() => _ThemesListPageState();
}

class _ThemesListPageState extends State<ThemesListPage> {
  SettingsAndState settingsAndState = SettingsAndState.getInstance();
  CollectionProvider collectionProvider = CollectionProvider.getInstance();

  final TextEditingController _dictionaryNameController =
      TextEditingController();

  List<String> listOfThemes = CollectionProvider.getInstance().themesMap.keys.toList();

  bool _isNewDictionaryNameFieldFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Грамматика и фраз по темам'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'прогресс %',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listOfThemes.length,
              itemBuilder: (context, index) {
                String themeName = listOfThemes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ThemePage(
                                  themeNameTranslation: themeName,
                                ))).then((result) {
                      if (result == null) {
                        setState(() {});
                      }
                    });
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          themeName,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16.0,
                        ),
                        subtitle: Text("статистика",
                          // "${settingsAndState.dictionariesInfo[themeName]![DictionaryStatistic.repeating] ?? 0}/"
                          // "${settingsAndState.dictionariesInfo[themeName]![DictionaryStatistic.tested] ?? 0}/"
                          // "${settingsAndState.dictionariesInfo[themeName]![DictionaryStatistic.totalNumber] ?? 0}",
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
          _showAddDictionaryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDictionaryDialog(BuildContext context) {
    _dictionaryNameController.text = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Center(child: Text('Название темы:')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15.0),
              TextField(
                controller: _dictionaryNameController,
                decoration: InputDecoration(
                  hintText:
                      _isNewDictionaryNameFieldFocused ? '' : 'Новая тема',
                ),
                onChanged: (value) {
                  setState(() {
                    _isNewDictionaryNameFieldFocused = true;
                  });
                },
              ),
              const SizedBox(height: 30.0),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      if (_dictionaryNameController.text.isEmpty) {
                        _showNoDictionaryNameDialog();
                      } else {
                        setState(() {
                          try {
                            // settingsAndState.addNewDictionaryName(
                            //     _dictionaryNameController.text);
                            // collectionProvider.createNewDictionary(
                            //     _dictionaryNameController.text, {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Словарь с таки именем у нас уже есть",
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
                      if (_dictionaryNameController.text.isEmpty) {
                        _showNoDictionaryNameDialog();
                      } else {
                        // _loadDictionaryFromFile();
                        // setState(() {
                        //   settingsAndState.addNewDictionaryName(
                        //       _dictionaryNameController.text);
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

  // void _loadDictionaryFromFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['csv', 'txt'],
  //   );

  //   if (result != null) {
  //     File file = File(result.files.single.path!);
  //     String themeName = _dictionaryNameController.text;

  //     try {
  //       await CsvUserFileLoader.readFlashCardsFromFile(themeName, file);
  //       _showLoadingSnackbar(context);
  //     } catch (e) {
  //       _showErrorDialog;
  //     }
  //   }
  // }

  // void _showLoadingSnackbar(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Row(
  //         children: [
  //           CircularProgressIndicator(),
  //           SizedBox(width: 16),
  //           Text('Загружаем данные...'),
  //         ],
  //       ),
  //       duration: Duration(seconds: 1), // Длительность снекбара
  //     ),
  //   );
  // }

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

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text(
            'Ошибка при загрузке и обработке файла!',
          ),
        );
      },
    );
  }

  void _showNoDictionaryNameDialog() {
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
