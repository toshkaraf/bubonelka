import 'package:bubonelka/pages/edit_phrasecard_page.dart';
import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/const_parameters.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubonelka'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: () {
              Navigator.pushNamed(context, themeListPageRoute);
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Добавьте действие для вызова справки
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedButton(title: 'Избранное', rout: favoritePhrasesPage),
            SizedBox(height: 20),
            RoundedButton(title: 'Рекомендуемое', rout: themeListPageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Выбрать тему', rout: chooseThemePageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Выбрать плейлист', rout: themeListPageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Настройки', rout: themeListPageRoute),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: true, // Call a function to determine visibility
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPhraseCardPage(
                  widgetName: createPhrasePageName,
                  phraseCard: neutralPhraseCard,
                  themeNameTranslation: SettingsAndState.getInstance().currentThemeName,
                ),
              ),
            );
          },
          label: Text('Добавить фразу'),
          icon: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

