import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @tabbarOverview.
  ///
  /// In en, this message translates to:
  /// **'overview'**
  String get tabbarOverview;

  /// No description provided for @tabbarSettings.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get tabbarSettings;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get themeDark;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'my wallet'**
  String get dashboardTitle;

  /// No description provided for @dashboradCreateBank.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get dashboradCreateBank;

  /// No description provided for @dashboardBalanceInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Balance'**
  String get dashboardBalanceInputTitle;

  /// No description provided for @dashboardBalanceInputTotalHint.
  ///
  /// In en, this message translates to:
  /// **'Enter total balance'**
  String get dashboardBalanceInputTotalHint;

  /// No description provided for @dashboardBalanceInputCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get dashboardBalanceInputCategoryName;

  /// No description provided for @dashboardBalanceInputAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dashboardBalanceInputAmount;

  /// No description provided for @dashboardBalanceInputAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get dashboardBalanceInputAddCategory;

  /// No description provided for @dashboardBalanceInputConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dashboardBalanceInputConfirm;

  /// No description provided for @dashboardBalanceInputRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get dashboardBalanceInputRequired;

  /// No description provided for @dashboardBalanceInputInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get dashboardBalanceInputInvalidAmount;

  /// No description provided for @dashboardSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get dashboardSpendTitle;

  /// No description provided for @dashboardSpendHint.
  ///
  /// In en, this message translates to:
  /// **'How much did you spend'**
  String get dashboardSpendHint;

  /// No description provided for @dashboardSpendRemark.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get dashboardSpendRemark;

  /// No description provided for @dashboardEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get dashboardEarnTitle;

  /// No description provided for @dashboardEarnHint.
  ///
  /// In en, this message translates to:
  /// **'How much did you earn'**
  String get dashboardEarnHint;

  /// No description provided for @dashboardUnallocated.
  ///
  /// In en, this message translates to:
  /// **'Unallocated'**
  String get dashboardUnallocated;

  /// No description provided for @dashboardManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Split Balance'**
  String get dashboardManageCategories;

  /// No description provided for @dashboardModifyBalance.
  ///
  /// In en, this message translates to:
  /// **'Modify balance'**
  String get dashboardModifyBalance;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
