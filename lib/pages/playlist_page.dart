// import 'package:flutter/material.dart';
// import 'package:bubonelka/classes/collection_provider.dart';
// import 'package:bubonelka/pages/theme_page.dart';

// class PlaylistPage extends StatefulWidget {
//   final String playlistName;

//   PlaylistPage({required this.playlistName});

//   @override
//   _PlaylistPageState createState() => _PlaylistPageState();
// }

// class _PlaylistPageState extends State<PlaylistPage> {
//   final CollectionProvider collectionProvider =
//       CollectionProvider.getInstance();
//   late List<String> listOfThemesTranslations;

//   @override
//   void initState() {
//     super.initState();
//     listOfThemesTranslations =
//         collectionProvider.mapOfPlaylists[widget.playlistName] ?? [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.playlistName),
//       ),
//       body: ListView.builder(
//         itemCount: listOfThemesTranslations.length,
//         itemBuilder: (context, index) {
//           final String themeNameTranslation = listOfThemesTranslations[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ThemePage(
//                     themeNameTranslation: themeNameTranslation,
//                   ),
//                 ),
//               ).then((result) {
//                 if (result == null) {
//                   // Refresh the state if necessary
//                   setState(() {});
//                 }
//               });
//             },
//             child: Column(
//               children: [
//                 ListTile(
//                   title: Text(
//                     themeNameTranslation,
//                     style: const TextStyle(
//                       fontSize: 16.0,
//                       color: Colors.black,
//                     ),
//                   ),
//                   trailing: IconButton(
//                     onPressed: () {
//                       _showDeleteConfirmationDialog(
//                           context, themeNameTranslation);
//                     },
//                     icon: Icon(
//                       Icons.delete,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 const Divider(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showDeleteConfirmationDialog(
//       BuildContext context, String themeNameTranslation) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('УДАЛЕНИЕ ТЕМЫ'),
//           content: const Text('Вы уверены, что хотите удалить тему?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Отменить'),
//             ),
//             TextButton(
//               onPressed: () {
//                 collectionProvider.deleteThemeOutOfPlaylist(
//                     widget.playlistName, themeNameTranslation);
//                 setState(() {
//                   listOfThemesTranslations =
//                       collectionProvider.mapOfPlaylists[widget.playlistName] ??
//                           [];
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Подтвердить',
//                   style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       // Refresh the state after dialog is closed
//       // setState(() {});
//     });
//   }
// }
