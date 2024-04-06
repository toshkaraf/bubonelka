import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/widgets/rounded_button.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubonelka'),
        actions: [
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
            RoundedButton(title: 'Избранное', rout: chooseThemePageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Рекомендуемое', rout: themeListPageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Выбрать тему', rout: themeListPageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Выбрать плейлист', rout: themeListPageRoute),
            SizedBox(height: 20),
            RoundedButton(title: 'Настройки', rout: themeListPageRoute),
          ],
        ),
      ),
    );
  }
}
