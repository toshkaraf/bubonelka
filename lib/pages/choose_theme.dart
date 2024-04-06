import 'package:bubonelka/classes/collection_provider.dart';
import 'package:flutter/material.dart';

class ChooseThemePage extends StatefulWidget {
  ChooseThemePage();

  @override
  _ChooseThemePageState createState() => _ChooseThemePageState();
}

class _ChooseThemePageState extends State<ChooseThemePage> {
  TextEditingController _playlistNameController = TextEditingController();
  final List<String> listOfThemes =
      CollectionProvider.getInstance().getListOfThemesNames();
  final Map<String, List<String>> chosenThemes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбери темы'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Добавьте действие для вызова справки
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: listOfThemes.length,
        itemBuilder: (context, index) {
          final themeName = listOfThemes[index];
          final isChecked = chosenThemes.containsKey(themeName);

          return CheckboxListTile(
            title: Text(themeName),
            value: isChecked,
            onChanged: (value) {
              setState(() {
                if (value!) {
                  chosenThemes[themeName] = [];
                } else {
                  chosenThemes.remove(themeName);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _showCreatePlaylistDialog(context),
            label: Text('Создать плейлист'),
            icon: Icon(Icons.playlist_add),
          ),
          SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, 'learningPageRoute');
            },
            label: Text('Начать занятие'),
            icon: Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Придумайте название плейлиста'),
          content: TextField(
            controller: _playlistNameController,
            decoration: InputDecoration(hintText: 'Мой плейлист 1'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отменить'),
            ),
            ElevatedButton(
              onPressed: () {
                final playlistName = _playlistNameController.text;
                if (playlistName.isNotEmpty) {
                  chosenThemes[playlistName] = chosenThemes.keys.toList();
                  Navigator.pop(context);
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }
}
