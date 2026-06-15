// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tabbarOverview => '总览';

  @override
  String get tabbarSettings => '设置';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get dashboardTitle => '我的存款';

  @override
  String get dashboradCreateBank => '创建余额钱包';

  @override
  String get dashboardBalanceInputTitle => '录入余额';

  @override
  String get dashboardBalanceInputModeTotal => '总余额';

  @override
  String get dashboardBalanceInputModeCategory => '分类录入';

  @override
  String get dashboardBalanceInputTotalHint => '请输入总余额';

  @override
  String get dashboardBalanceInputCategoryName => '类目名称';

  @override
  String get dashboardBalanceInputAmount => '金额';

  @override
  String get dashboardBalanceInputAddCategory => '添加类目';

  @override
  String get dashboardBalanceInputTotal => '合计';

  @override
  String get dashboardBalanceInputConfirm => '确认';

  @override
  String get dashboardBalanceInputRequired => '请填写此项';

  @override
  String get dashboardBalanceInputInvalidAmount => '请输入有效金额';

  @override
  String get dashboardSpendTitle => '花钱了';

  @override
  String get dashboardSpendHint => '花了多少钱';

  @override
  String get dashboardSpendRemark => '备注';

  @override
  String get dashboardModifyBalance => '修改余额';
}
