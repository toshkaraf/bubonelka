import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final String rout;

  const RoundedButton({Key? key, required this.title, required this.rout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, rout);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Цвет кнопки
          padding: EdgeInsets.symmetric(vertical: 15), // Поля кнопки
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
