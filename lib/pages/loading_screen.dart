
import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/pages/start_page.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late CollectionProvider collectionProvider;

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  // Метод для загрузки данных и перехода на MainPage
  Future<void> _loadDataAndNavigate() async {
    // Здесь можно добавить задержку, чтобы показать экран загрузки в течение некоторого времени
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Загрузка настроек
      // await SettingsAndStateManager().loadSettings();

      // Загрузка данных CollectionProvider
      collectionProvider = CollectionProvider.getInstance();

      try {
        collectionProvider.initializeCollectionProvider(noPath);
      } on Exception catch (e) {
        // Обработка исключения
        print('$e');
        // Выводите сообщение в снекбар или другой способ уведомления
        _showSnackBar('$e');
      } catch (error) {
        // Обработка ошибок
        print('Error: $error');
      }

      // После загрузки данных перейдите на главный экран MainPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    } catch (error) {
      // Если возникла ошибка, выведите ее на экран
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text('Произошла ошибка при загрузке данных: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ок'),
            ),
          ],
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ваш логотип или изображение здесь
            // Image.asset(worm1_picture),
            // Индикатор загрузки
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue)), // Здесь можно указать нужный цвет
          ],
        ),
      ),
    );
  }
}
