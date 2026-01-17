import 'dart:convert';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Nigehbaan',
      'welcomeBack': 'Welcome back,',
      'safetyStatus': 'Safety Status',
      'protected': 'Protected',
      'locationDisabled': 'Location Disabled',
      'enableLocation': 'Enable Location',
      'quickActions': 'Quick Actions',
      'safetyMap': 'Safety Map',
      'sos': 'SOS',
      'reports': 'Reports',
      'contacts': 'Contacts',
      'emergencyContacts': 'Emergency Contacts',
      'manage': 'Manage',
      'noContacts': 'No emergency contacts added yet',
      'safetyTips': 'Safety Tips',
      'tip1': 'Always share your location with trusted contacts',
      'tip2': 'Stay in well-lit areas when traveling at night',
      'tip3': 'Keep emergency contacts updated',
      'settings': 'Settings',
      'privacyPolicy': 'Privacy Policy',
      'termsConditions': 'Terms & Conditions',
      'logout': 'Logout',
    },
    'zh': {
      'appTitle': 'Nigehbaan',
      'welcomeBack': '欢迎回来，',
      'safetyStatus': '安​​全状态',
      'protected': '受保护',
      'locationDisabled': '位置已禁用',
      'enableLocation': '启用位置',
      'quickActions': '快速操作',
      'safetyMap': '安全地图',
      'sos': '求救',
      'reports': '报告',
      'contacts': '联系人',
      'emergencyContacts': '紧急联系人',
      'manage': '管理',
      'noContacts': '尚未添加紧急联系人',
      'safetyTips': '安全提示',
      'tip1': '始终与信任的联系人共享您的位置',
      'tip2': '夜间出行请停留在光线充足的地方',
      'tip3': '保持紧急联系人更新',
      'settings': '设置',
      'privacyPolicy': '隐私政策',
      'termsConditions': '条款和条件',
      'logout': '登出',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcomeBack']!;
  String get safetyStatus => _localizedValues[locale.languageCode]!['safetyStatus']!;
  String get protected => _localizedValues[locale.languageCode]!['protected']!;
  String get locationDisabled => _localizedValues[locale.languageCode]!['locationDisabled']!;
  String get enableLocation => _localizedValues[locale.languageCode]!['enableLocation']!;
  String get quickActions => _localizedValues[locale.languageCode]!['quickActions']!;
  String get safetyMap => _localizedValues[locale.languageCode]!['safetyMap']!;
  String get sos => _localizedValues[locale.languageCode]!['sos']!;
  String get reports => _localizedValues[locale.languageCode]!['reports']!;
  String get contacts => _localizedValues[locale.languageCode]!['contacts']!;
  String get emergencyContacts => _localizedValues[locale.languageCode]!['emergencyContacts']!;
  String get manage => _localizedValues[locale.languageCode]!['manage']!;
  String get noContacts => _localizedValues[locale.languageCode]!['noContacts']!;
  String get safetyTips => _localizedValues[locale.languageCode]!['safetyTips']!;
  String get tip1 => _localizedValues[locale.languageCode]!['tip1']!;
  String get tip2 => _localizedValues[locale.languageCode]!['tip2']!;
  String get tip3 => _localizedValues[locale.languageCode]!['tip3']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get termsConditions => _localizedValues[locale.languageCode]!['termsConditions']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
