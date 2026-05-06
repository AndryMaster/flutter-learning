import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'l10n/generated/app_localizations.dart';

class S {
  static const locale = Locale('ru');

  static const supportedLocales = [Locale('en'), Locale('ru')];

  static const localizationDelegates = <LocalizationsDelegate>[
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ];

  // supportedLocales: AppLocalizations.supportedLocales,
  // localizationsDelegates: AppLocalizations.localizationsDelegates,

  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context);
}
