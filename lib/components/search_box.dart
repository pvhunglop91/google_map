import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
  });

  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.orange),
      borderRadius: BorderRadius.circular(16.0),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
          top: 16.0, bottom: MediaQuery.of(context).viewInsets.bottom + 16.0),
      color: Colors.pink[50],
      child: Container(
        // height: 52.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0.0, 3.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 1),
            border: outlineInputBorder,
            focusedBorder: outlineInputBorder,
            enabledBorder: outlineInputBorder,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon:
                const Icon(Icons.search, size: 30.0, color: Colors.orange),
            prefixIconConstraints: const BoxConstraints(minWidth: 46.0),
          ),
        ),
      ),
    );
  }
}
