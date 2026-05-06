// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Flutter i18n Демо';

  @override
  String pushCount(DateTime date, int count, String style) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    String _temp0 = intl.Intl.selectLogic(style, {
      'formal': 'Вы заработали',
      'informal': 'Ты заработал',
      'other': 'Вы заработали',
    });
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count печенек',
      many: '$count печенек',
      few: '$count печеньки',
      one: '$count печеньку',
      zero: 'ни одной печеньки',
    );
    return '$_temp0 $_temp1 ($dateString)';
  }
}
