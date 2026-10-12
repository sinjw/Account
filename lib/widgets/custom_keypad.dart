import 'package:flutter/material.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  const CustomKeypad({super.key, required this.onKeyPressed});

  Widget buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),

        child: SizedBox(
          height: 110,

          child: ElevatedButton(
            onPressed: () {
              onKeyPressed(text);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            child: Text(
              text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,

      color: const Color.fromARGB(255, 228, 228, 228),

      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [buildButton("1"), buildButton("2"), buildButton("3")],
            ),
          ),
          Expanded(
            child: Row(
              children: [buildButton("4"), buildButton("5"), buildButton("6")],
            ),
          ),
          Expanded(
            child: Row(
              children: [buildButton("7"), buildButton("8"), buildButton("9")],
            ),
          ),
          Expanded(
            child: Row(
              children: [buildButton("00"), buildButton("0"), buildButton("←")],
            ),
          ),
        ],
      ),
    );
  }
}
