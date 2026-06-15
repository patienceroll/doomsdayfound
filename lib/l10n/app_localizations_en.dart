// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabbarOverview => 'overview';

  @override
  String get tabbarSettings => 'settings';

  @override
  String get themeSystem => 'system';

  @override
  String get themeLight => 'light';

  @override
  String get themeDark => 'dark';

  @override
  String get dashboardTitle => 'my wallet';

  @override
  String get dashboradCreateBank => 'Create wallet';

  @override
  String get dashboardBalanceInputTitle => 'Enter Balance';

  @override
  String get dashboardBalanceInputModeTotal => 'Total';

  @override
  String get dashboardBalanceInputModeCategory => 'By Category';

  @override
  String get dashboardBalanceInputTotalHint => 'Enter total balance';

  @override
  String get dashboardBalanceInputCategoryName => 'Category';

  @override
  String get dashboardBalanceInputAmount => 'Amount';

  @override
  String get dashboardBalanceInputAddCategory => 'Add category';

  @override
  String get dashboardBalanceInputTotal => 'Total';

  @override
  String get dashboardBalanceInputConfirm => 'Confirm';

  @override
  String get dashboardBalanceInputRequired => 'Required';

  @override
  String get dashboardBalanceInputInvalidAmount => 'Invalid amount';

  @override
  String get dashboardSpendTitle => 'Expense';

  @override
  String get dashboardSpendHint => 'How much did you spend';

  @override
  String get dashboardSpendRemark => 'Note';

  @override
  String get dashboardEarnTitle => 'Income';

  @override
  String get dashboardEarnHint => 'How much did you earn';

  @override
  String get dashboardModifyBalance => 'Modify balance';
}
