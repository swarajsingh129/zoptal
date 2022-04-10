import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RTextfield extends StatelessWidget {
  final String title;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final String data;

  RTextfield({
    Key? key,
    required this.title,
    required this.onChanged,
    required this.icon,
    required this.data,
  }) : super(key: key);

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (data != "") {
      controller.text = data;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: MediaQuery.of(context).size.height / 22,
        width: MediaQuery.of(context).size.width * 0.9 - 5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4)),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            icon: Icon(
              icon,
              color: Colors.grey,
            ),
            border: InputBorder.none,
            hintText: title,
          ),
        ),
      ),
    );
  }
}
