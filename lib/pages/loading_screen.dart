import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/pages/start_page.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    await Future.delayed(Duration(milliseconds: 500)); // Для UI

    try {
      dbHelper = DatabaseHelper();
      bool isInitialized = await dbHelper.isInitialized();

      if (!isInitialized) {
        await dbHelper.loadInitialData();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StartPage()),
      );
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text('Ошибка при загрузке: $message'),
        actions: [
          TextButton(
            child: const Text('Ок'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Загрузка данных...'),
          ],
        ),
      ),
    );
  }
}
