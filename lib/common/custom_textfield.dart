import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realplayadmin/Constraints/constraints.dart';

class customTextField extends StatelessWidget {
  final TextEditingController? textController;
  final String hintText;
  final Function(String)? onChange;
  final bool changeBorderColor;

  const customTextField({
    super.key,
    this.textController,
    required this.hintText,
    this.onChange,
    this.changeBorderColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            offset: const Offset(12, 26),
            blurRadius: 50,
            spreadRadius: 0,
            color: backgroundColor.withOpacity(.1)),
      ]),
      child: TextField(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w400,
          decorationThickness: 0,
        ),
        controller: textController,
        onChanged: onChange,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: changeBorderColor ? backgroundColor : Colors.white,
                width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: changeBorderColor ? backgroundColor : Colors.white,
                width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }
}
