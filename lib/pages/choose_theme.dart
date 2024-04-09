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
  TextEditingController _filterController = TextEditingController();
  final List<String> listOfThemes =
      CollectionProvider.getInstance().getListOfThemesNames();
  List<String> chosenThemes = [];
  List<String> filteredThemes = [];

  @override
  void initState() {
    super.initState();
    filteredThemes.addAll(listOfThemes);
    _filterController.addListener(() {
      if (_filterController.text.isEmpty) {
        setState(() {
          filteredThemes.clear();
          filteredThemes.addAll(listOfThemes);
        });
      } else {
        setState(() {
          filteredThemes = listOfThemes
              .where((theme) => theme.toLowerCase().contains(_filterController.text.toLowerCase()))
              .toList();
        });
      }
    });
  }

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
      body: Column(
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
              itemCount: filteredThemes.length,
              itemBuilder: (context, index) {
                final themeName = filteredThemes[index];
                final isChecked = chosenThemes.contains(themeName);

                return CheckboxListTile(
                  title: Text(themeName),
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        chosenThemes.add(themeName);
                      } else {
                        chosenThemes.remove(themeName);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
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
                if (!chosenThemes.isEmpty) {
                  CollectionProvider.getInstance().chosenThemes = chosenThemes;
                  Navigator.pushNamed(context, learningPageRoute);
                }
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
    _filterController.dispose();
    super.dispose();
  }
}
