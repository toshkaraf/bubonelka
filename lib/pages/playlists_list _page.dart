import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/pages/playlist_page.dart';
import 'package:bubonelka/rutes.dart';
import 'package:flutter/material.dart';

class PlaylistsListPage extends StatefulWidget {
  @override
  State<PlaylistsListPage> createState() => _PlaylistsListPageState();
}

class _PlaylistsListPageState extends State<PlaylistsListPage> {
  SettingsAndState settingsAndState = SettingsAndState.getInstance();
  CollectionProvider collectionProvider = CollectionProvider.getInstance();

  final TextEditingController _filterController = TextEditingController();

  List<String> listOfplaylistss =
      CollectionProvider.getInstance().playlistsMap.keys.toList();

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() {
      setState(() {
        listOfplaylistss = CollectionProvider.getInstance()
            .playlistsMap
            .keys
            .where((playlist) => playlist
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
        title: const Text('Плейлисты'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Фильтр по названию',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listOfplaylistss.length,
              itemBuilder: (context, index) {
                String playlistName = listOfplaylistss[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistPage(
                          playlistName: playlistName,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          playlistName,
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
                                CollectionProvider.getInstance()
                                    .setChosenThemesFromPlaylist(playlistName);
                                Navigator.pushNamed(context, learningPageRoute);
                              },
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.grey,
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    title: Text(
                                      'Удалить плейлист',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      // Show confirmation dialog
                                      _showDeleteConfirmationDialog(
                                          playlistName);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  void _showDeleteConfirmationDialog(String playlistName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('УДАЛЕНИЕ ПЛЕЙЛИСТА'),
          content: const Text('Вы уверены, что хотите удалить плейлист?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отменить'),
            ),
            TextButton(
              onPressed: () {
                collectionProvider.deleteplaylist(playlistName);
                setState(() {
                  listOfplaylistss =
                      collectionProvider.playlistsMap.keys.toList();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Подтвердить',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ).then((_) {
      // Refresh the state after dialog is closed
      setState(() {});
    });
  }
}
