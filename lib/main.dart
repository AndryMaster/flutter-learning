import 'package:flutter/material.dart';
import 's.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: S.locale,
      supportedLocales: S.supportedLocales,
      localizationsDelegates: S.localizationDelegates,

      title: 'My App',
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text(S.of(context).appTitle)),
            body: Center(
              child: Text(S.of(context)
                  .pushCount(DateTime.now(), 2, PronounStyle.informal),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PronounStyle {
  static const formal = 'formal';
  static const informal = 'informal';
}
