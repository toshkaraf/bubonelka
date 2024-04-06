import 'package:flutter/material.dart';

class LearningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubonelka'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            color: Colors.black, // Установите цвет иконки
            onPressed: () {
              // Добавьте действие для вызова справки
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TransparentIconButton(icon: Icons.book, onPressed: () {}),
              TransparentIconButton(icon: Icons.speed, onPressed: () {}),
              TransparentIconButton(icon: Icons.pause, onPressed: () {}),
              TransparentIconButton(icon: Icons.star, onPressed: () {}),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoundedIconButton(icon: Icons.skip_previous, onPressed: () {}),
                RoundedIconButton(icon: Icons.play_arrow, onPressed: () {}),
                RoundedIconButton(icon: Icons.skip_next, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransparentIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const TransparentIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.black, // Установите цвет иконки
      iconSize: 35,
      onPressed: onPressed,
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.black, // Установите цвет иконки
        onPressed: onPressed,
      ),
    );
  }
}

