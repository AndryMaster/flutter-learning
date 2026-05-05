import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(home: MyCustomForm()));
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  @override
  Widget build(BuildContext context) {
    final numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
    final lengthFormatter = LengthLimitingTextInputFormatter(3);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [numberFormatter, lengthFormatter],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'cvv',
            ),
          ),
        ),
      ),
    );
  }
}
