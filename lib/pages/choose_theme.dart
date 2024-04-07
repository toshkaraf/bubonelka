import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/rutes.dart';
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
  List<String> chosenThemes = [];

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
          final isChecked = chosenThemes.contains(themeName);

          return CheckboxListTile(
            title: Text(themeName),
            value: isChecked,
            onChanged: (value) {
              setState(() {
                if (value!) {
                  chosenThemes
                      .add(themeName); // Добавляем themeName в chosenThemes
                } else {
                  chosenThemes
                      .remove(themeName); // Удаляем themeName из chosenThemes
                }
              });
            },
          );
        },
      ),
      floatingActionButton: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _showCreatePlaylistDialog(context),
              label: Text('Создать плейлист'),
              icon: Icon(Icons.playlist_add),
              heroTag: 'create_playlist_hero',
            ),
            SizedBox(height: 16),
            FloatingActionButton.extended(
              onPressed: () {
                CollectionProvider.getInstance().chosenThemes = chosenThemes;
                Navigator.pushNamed(context, learningPageRoute);
              },
              label: Text('Начать занятие'),
              icon: Icon(Icons.play_arrow),
              heroTag: 'start_learning_hero',
            ),
          ],
        ),
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
                _playlistNameController.clear();
                if (playlistName.isNotEmpty) {
                  CollectionProvider.getInstance().playlists = chosenThemes;
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
