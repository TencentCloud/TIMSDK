// ignore_for_file: unused_field, duplicate_ignore

/*
 * Generated file. Do not edit.
 *
 * Locales: 2
 * Strings: 316 (158.0 per locale)
 *
 * Built on 2022-04-14 at 02:52 UTC
 */

import 'package:flutter/widgets.dart';

const AppLocale _baseLocale = AppLocale.en;
AppLocale _currLocale = _baseLocale;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale {
  en, // 'en' (base locale, fallback)
  zh, // 'zh'
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn _t = _currLocale.translations;
_StringsEn get t => _t;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
  Translations._(); // no constructor

  static _StringsEn of(BuildContext context) {
    final inheritedWidget =
        context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
    if (inheritedWidget == null) {
      throw 'Please wrap your app with "TranslationProvider".';
    }
    return inheritedWidget.translations;
  }
}

class LocaleSettings {
  LocaleSettings._(); // no constructor

  /// Uses locale of the device, fallbacks to base locale.
  /// Returns the locale which has been set.
  static AppLocale useDeviceLocale() {
    final locale = AppLocaleUtils.findDeviceLocale();
    return setLocale(locale);
  }

  /// Sets locale
  /// Returns the locale which has been set.
  static AppLocale setLocale(AppLocale locale) {
    _currLocale = locale;
    _t = _currLocale.translations;

    if (WidgetsBinding.instance != null) {
      // force rebuild if TranslationProvider is used
      _translationProviderKey.currentState?.setLocale(_currLocale);
    }

    return _currLocale;
  }

  /// Sets locale using string tag (e.g. en_US, de-DE, fr)
  /// Fallbacks to base locale.
  /// Returns the locale which has been set.
  static AppLocale setLocaleRaw(String rawLocale) {
    final locale = AppLocaleUtils.parse(rawLocale);
    return setLocale(locale);
  }

  /// Gets current locale.
  static AppLocale get currentLocale {
    return _currLocale;
  }

  /// Gets base locale.
  static AppLocale get baseLocale {
    return _baseLocale;
  }

  /// Gets supported locales in string format.
  static List<String> get supportedLocalesRaw {
    return AppLocale.values.map((locale) => locale.languageTag).toList();
  }

  /// Gets supported locales (as Locale objects) with base locale sorted first.
  static List<Locale> get supportedLocales {
    return AppLocale.values.map((locale) => locale.flutterLocale).toList();
  }
}

/// Provides utility functions without any side effects.
class AppLocaleUtils {
  AppLocaleUtils._(); // no constructor

  /// Returns the locale of the device as the enum type.
  /// Fallbacks to base locale.
  static AppLocale findDeviceLocale() {
    final String? deviceLocale =
        WidgetsBinding.instance?.window.locale.toLanguageTag();
    if (deviceLocale != null) {
      final typedLocale = _selectLocale(deviceLocale);
      if (typedLocale != null) {
        return typedLocale;
      }
    }
    return _baseLocale;
  }

  /// Returns the enum type of the raw locale.
  /// Fallbacks to base locale.
  static AppLocale parse(String rawLocale) {
    return _selectLocale(rawLocale) ?? _baseLocale;
  }
}

// context enums

// interfaces generated as mixins

// translation instances

late _StringsEn _translationsEn = _StringsEn.build();
late _StringsZh _translationsZh = _StringsZh.build();

// extensions for AppLocale

extension AppLocaleExtensions on AppLocale {
  /// Gets the translation instance managed by this library.
  /// [TranslationProvider] is using this instance.
  /// The plural resolvers are set via [LocaleSettings].
  _StringsEn get translations {
    switch (this) {
      case AppLocale.en:
        return _translationsEn;
      case AppLocale.zh:
        return _translationsZh;
    }
  }

  /// Gets a new translation instance.
  /// [LocaleSettings] has no effect here.
  /// Suitable for dependency injection and unit tests.
  ///
  /// Usage:
  /// final t = AppLocale.en.build(); // build
  /// String a = t.my.path; // access
  _StringsEn build() {
    switch (this) {
      case AppLocale.en:
        return _StringsEn.build();
      case AppLocale.zh:
        return _StringsZh.build();
    }
  }

  String get languageTag {
    switch (this) {
      case AppLocale.en:
        return 'en';
      case AppLocale.zh:
        return 'zh';
    }
  }

  Locale get flutterLocale {
    switch (this) {
      case AppLocale.en:
        return const Locale.fromSubtags(languageCode: 'en');
      case AppLocale.zh:
        return const Locale.fromSubtags(languageCode: 'zh');
    }
  }
}

extension StringAppLocaleExtensions on String {
  AppLocale? toAppLocale() {
    switch (this) {
      case 'en':
        return AppLocale.en;
      case 'zh':
        return AppLocale.zh;
      default:
        return null;
    }
  }
}

// wrappers

GlobalKey<_TranslationProviderState> _translationProviderKey =
    GlobalKey<_TranslationProviderState>();

class TranslationProvider extends StatefulWidget {
  TranslationProvider({required this.child})
      : super(key: _translationProviderKey);

  final Widget child;

  @override
  _TranslationProviderState createState() => _TranslationProviderState();

  static _InheritedLocaleData of(BuildContext context) {
    final inheritedWidget =
        context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
    if (inheritedWidget == null) {
      throw 'Please wrap your app with "TranslationProvider".';
    }
    return inheritedWidget;
  }
}

class _TranslationProviderState extends State<TranslationProvider> {
  AppLocale locale = _currLocale;

  void setLocale(AppLocale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedLocaleData(
      locale: locale,
      child: widget.child,
    );
  }
}

class _InheritedLocaleData extends InheritedWidget {
  final AppLocale locale;
  Locale get flutterLocale => locale.flutterLocale; // shortcut
  final _StringsEn translations; // store translations to avoid switch call

  _InheritedLocaleData({required this.locale, required Widget child})
      : translations = locale.translations,
        super(child: child);

  @override
  bool updateShouldNotify(_InheritedLocaleData oldWidget) {
    return oldWidget.locale != locale;
  }
}

// pluralization feature not used

// helpers

final _localeRegex =
    RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');
AppLocale? _selectLocale(String localeRaw) {
  final match = _localeRegex.firstMatch(localeRaw);
  AppLocale? selected;
  if (match != null) {
    final language = match.group(1);
    final country = match.group(5);

    // match exactly
    selected = AppLocale.values.cast<AppLocale?>().firstWhere(
        (supported) => supported?.languageTag == localeRaw.replaceAll('_', '-'),
        orElse: () => null);

    if (selected == null && language != null) {
      // match language
      selected = AppLocale.values.cast<AppLocale?>().firstWhere(
          (supported) => supported?.languageTag.startsWith(language) == true,
          orElse: () => null);
    }

    if (selected == null && country != null) {
      // match country
      selected = AppLocale.values.cast<AppLocale?>().firstWhere(
          (supported) => supported?.languageTag.contains(country) == true,
          orElse: () => null);
    }
  }
  return selected;
}

// translations

// Path: <root>
class _StringsEn {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsEn.build();

  /// Access flat map
  dynamic operator [](String key) => _flatMap[key];

  // Internal flat map initialized lazily
  late final Map<String, dynamic> _flatMap = _buildFlatMap();

  // ignore: unused_field
  late final _StringsEn _root = this;

  // Translations
  String get k_03f15qk => 'Blocklist';
  String get k_0uc5cnb =>
      'Beta test in progress. Channel creation is not supported now.';
  String get k_003nevv => 'Cancel';
  String get k_003rzap => 'OK';
  String get k_0s5ey0o => 'TRTC';
  String get k_03gpl3d => 'Hello';
  String get k_0352fjr =>
      'Failed to enter the channel due to network disconnection';
  String get k_0d7n018 => 'End topic';
  String get k_0d826hk => 'Pin topic to top';
  String get k_15wcgna => 'Ended successfully';
  String get k_15wo7xu => 'Pinned to top successfully';
  String get k_002s934 => 'Topic';
  String get k_18g3zdo => 'Cloud Communication · IM';
  String get k_1m8vyp0 => 'New contacts';
  String get k_0elz70e => 'Group chats';
  String get k_18tb4mo => 'No contact';
  String get k_18nuh87 => 'Contact us';
  String get k_1uf134v =>
      'To provide feedback or suggestions, join our QQ group at 788910197.';
  String get k_0xlhhrn => 'Online time: 10 AM to 8 PM, Mon through Fri';
  String get k_17fmlyf => 'Clear chat';
  String get k_0dhesoz => 'Unpin from top';
  String get k_002sk7x => 'Pin to top';
  String get k_0gmpgcg => 'No conversation';
  String get k_002tu9r => 'Performance';
  String get k_1tmcw5c => 'Complete your topic title';
  String get k_1cnmslk => 'A tag must be selected';
  String get k_0z3ytji => 'Topic created successfully';
  String get k_1a8vem3 => 'Creator exception';
  String get k_0eskkr1 => 'Select a discussion forum';
  String get k_0d7plb5 => 'Create topic';
  String get k_144t0ho => '---- Related discussions ----';
  String get k_0pnz619 => 'Enter the topic title';
  String get k_136v279 => '+ Tag (add at least one tag)';
  String get k_04hjhvp => 'Discussion forum parameter exception';
  String get k_002r79h => 'All';
  String get k_03ejkb6 => 'Joined';
  String get k_172tngw => 'Topic (disconnected)';
  String get k_0rnmfc4 => 'No topic in the discussion forum';
  String get k_1pq0ybn => 'You haven\'t joined any topic yet';
  String get k_0bh95w0 =>
      'Failed to join the topic due to network disconnection';
  String get k_002twmj => 'Group chat';
  String get k_09kalj0 => 'Clear chat history';
  String get k_18qjstb => 'Transfer group owner';
  String get k_14j5iul => 'Delete and exit';
  String get k_0jtutmw =>
      'You will not be able to receive messages from this group chat after you exit';
  String get k_08k00l9 => 'Loading…';
  String get k_197r4f7 => 'IM service connected successfully';
  String get k_1s5xnir => 'Failed to initialize the IM SDK';
  String get k_15bxnkw => 'Network connection lost';
  String get k_002r09z => 'Channel';
  String get k_003nvk2 => 'Message';
  String get k_1jwxwgt => 'Connecting…';
  String get k_03gm52d => 'Contacts';
  String get k_003k7dc => 'Me';
  String get k_14yh35u => 'Log in to IM';
  String get k_0st7i3e =>
      'Try IM features such as group chat and audio/video call';
  String get k_0cr1atw => 'Chinese mainland';
  String get k_0jsvmjm => 'Enter your mobile number';
  String get k_1lg8qh2 => 'Incorrect mobile number format';
  String get k_03jia4z => 'No network connection';
  String get k_007jqt2 => 'Verification code sent successfully';
  String get k_1t2zg6h => 'Image verification failed';
  String get k_1a55aib => 'Verification code exception';
  String get k_16r3sej => 'Country/Region';
  String get k_15hlgzr => 'Select your country code';
  String get k_1bnmt3h => 'Please search in English';
  String get k_003kv3v => 'Search';
  String get k_03fei8z => 'Mobile number';
  String get k_03aj66h => 'Verification code';
  String get k_1m9jtmw => 'Enter the verification code';
  String get k_0y1wbxk => 'Send';
  String get k_0orhtx0 => 'Privacy Agreement';
  String get k_00041m1 => 'and';
  String get k_0opnzp6 => 'User Agreement';
  String get k_161ecly => 'Network unavailable';
  String get k_11uz2i8 => 'Reconnect network';
  String get k_1vhzltr => 'Tencent Cloud IM';
  String get k_0j433ys => 'Tencent Cloud TRTC';
  String get k_12u8g8l => 'Disclaimer';
  String get k_1p0j8i3 =>
      'Instant Messaging (IM) is a test product provided by Tencent Cloud. It is for trying out features, but not for commercial use. To follow regulatory requirements of the authority, audio and video-based interactions performed via IM will be recorded and archived throughout the whole process. It is strictly prohibited to disseminate via IM any pornographic, abusive, violent, political and other noncompliant content.';
  String get k_0k7qoht => 'Accept all friend requests';
  String get k_0gyhkp5 => 'Require approval for friend requests';
  String get k_121ruco => 'Reject all friend requests';
  String get k_003kfai => 'Unknown';
  String get k_1kvyskd => 'Modification failed due to network disconnection';
  String get k_1wmkneq => 'Require approval';
  String get k_1eitsd0 => 'About Tencent Cloud IM';
  String get k_1919d6m => 'Privacy Policy';
  String get k_16kts8h => 'Log out';
  String get k_129scag => 'Friend deleted successfully';
  String get k_094phq4 => 'Failed to add the friend';
  String get k_13spdki => 'Send message';
  String get k_0h22snw => 'Audio call';
  String get k_0h20hg5 => 'Video call';
  String get k_1666isy => 'Delete friend';
  String get k_0r8fi93 => 'Friend added successfully';
  String get k_02qw14e => 'Friend request sent';
  String get k_0n3md5x => 'The current user is on the blocklist';
  String get k_14c600t => 'Modify remarks';
  String get k_1f811a4 => 'Allows only digits, letters and underscores';
  String get k_11z7ml4 => 'Profile';
  String get k_0003y9x => 'None';
  String get k_1679vrd => 'Add as friend';
  String get k_03ibg5h => 'Mon';
  String get k_03i7hu1 => 'Tue';
  String get k_03iaiks => 'Wed';
  String get k_03el9pa => 'Thu';
  String get k_03i7ok1 => 'Fri';
  String get k_03efxyg => 'Sat';
  String get k_03ibfd2 => 'Sun';
  String get k_003ltgm => 'Location';
  String get k_04dqh36 => 'No new contact';
  String get k_0mnxjg7 =>
      'Welcome to Tencent Cloud Instant Messaging (IM). To protect the security of your personal information, we have updated the Privacy Policy, mainly improving the specific content and purpose for user information collection and adding the use of third-party SDKs.';
  String get k_1545beg => 'Please tap ';
  String get k_11x8pvm =>
      'and read them carefully. If you agree to the content, tap "Accept and continue" to start using our product and service.';
  String get k_17nw8gq => 'Accept and continue';
  String get k_1nynslj => 'Reject and quit';
  String get k_1j91bvz => 'Let TUIKit pick a profile photo for you?';
  String get k_0wqhgor => 'Personal information collection list';
  String get k_12rfxml => 'Third-party information sharing list';
  String get k_131g7q4 => 'Deregister account';
  String get k_03fel2u => 'Version';
  String get k_1ajt0b1 => 'Failed to get the current location';
  String get k_0lhm9xq => 'Search initiated successfully';
  String get k_0fdeled => 'Failed to initiate the search';
  String get k_1yh0a50 => 'mapDidLoad - The map has been loaded';
  String get k_16758qw => 'Add friend';
  String get k_0elt0kw => 'Add group chat';
  String get k_0s3p3ji => 'No blocklist';
  String k_02slfpm({required Object errorMessage}) => 'Error: $errorMessage';
  String get k_1m8zuj4 => 'Select contact';
  String k_0vwtop2({required Object getMsg}) => 'Message obtained: $getMsg';
  String k_0upijvs({required Object message}) =>
      'Failed to get the discussion forum list: $message';
  String k_0v5hlay({required Object message}) =>
      'Failed to create the topic: $message';
  String get k_0em28sp => 'No group chat';
  String k_0owk5ss({required Object failedReason}) =>
      'Login failed: $failedReason';
  String get k_0glj9us => 'Initiate conversation';
  String get k_1631kyh => 'Create work group';
  String get k_1644yii => 'Create public group';
  String get k_1fxfx04 => 'Create meeting group';
  String get k_1cnkqc9 => 'Create audio-video group';
  String k_1mw45lz({required Object errorReason}) =>
      'Login failed: $errorReason';
  String get k_0epvs61 => 'Change skin';
  String get k_002ri2g => 'Log in';
  String k_1o7lf2y({required Object errorMessage}) =>
      'Server error: $errorMessage';
  String k_118l7sq({required Object requestErrorMessage}) =>
      'Request error: $requestErrorMessage';
  String get k_003nfx9 => 'Deep';
  String get k_003rvjp => 'Light';
  String get k_003rtht => 'Bright';
  String get k_003qxiw => 'Fantasy';
  String k_0s5zoi3({required Object option1}) => 'Error: $option1';
  String k_0i8egqa({required Object option8}) => 'Message obtained: $option8';
  String k_0pokyns({required Object option8}) =>
      'Failed to get the discussion forum list: $option8';
  String k_1y03m8a({required Object option8}) =>
      'Failed to create the topic: $option8';
  String k_1v6uh9c({required Object option8}) => 'Login failed: $option8';
  String k_0t5a9hl({required Object option1}) => 'Login failed: $option1';
  String k_0k3uv02({required Object option8}) => 'Server error: $option8';
  String k_1g9o3kz({required Object option8}) => 'Request error: $option8';
}

// Path: <root>
class _StringsZh implements _StringsEn {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsZh.build();

  /// Access flat map
  @override
  dynamic operator [](String key) => _flatMap[key];

  // Internal flat map initialized lazily
  @override
  late final Map<String, dynamic> _flatMap = _buildFlatMap();

  // ignore: unused_field
  @override
  late final _StringsZh _root = this;

  // Translations
  @override
  String get k_16758qw => '添加好友';
  @override
  String get k_0elt0kw => '添加群聊';
  @override
  String get k_03f15qk => '黑名单';
  @override
  String get k_0s3p3ji => '暂无黑名单';
  @override
  String get k_0uc5cnb => '我们还在内测中，暂不支持创建频道。';
  @override
  String get k_003rzap => '确定';
  @override
  String get k_003nevv => '取消';
  @override
  String get k_0s5ey0o => '实时音视频 TRTC';
  @override
  String get k_03gpl3d => '大家好';
  @override
  String get k_0352fjr => '无网络连接，进入频道失败';
  @override
  String get k_0d7n018 => '结束话题';
  @override
  String get k_0d826hk => '置顶话题';
  @override
  String get k_15wcgna => '结束成功';
  @override
  String get k_15wo7xu => '置顶成功';
  @override
  String k_02slfpm({required Object errorMessage}) => '发生错误 $errorMessage';
  @override
  String get k_003ltgm => '位置';
  @override
  String get k_0h22snw => '语音通话';
  @override
  String get k_0h20hg5 => '视频通话';
  @override
  String get k_002s934 => '话题';
  @override
  String get k_18g3zdo => '云通信·IM';
  @override
  String get k_1m8vyp0 => '新的联系人';
  @override
  String get k_0elz70e => '我的群聊';
  @override
  String get k_18tb4mo => '无联系人';
  @override
  String get k_18nuh87 => '联系我们';
  @override
  String get k_1uf134v => '反馈及建议可以加入QQ群：788910197';
  @override
  String get k_0xlhhrn => '在线时间，周一到周五，早上10点 - 晚上8点';
  @override
  String get k_17fmlyf => '清除聊天';
  @override
  String get k_0dhesoz => '取消置顶';
  @override
  String get k_002sk7x => '置顶';
  @override
  String get k_003kv3v => '搜索';
  @override
  String get k_0gmpgcg => '暂无会话';
  @override
  String get k_1m8zuj4 => '选择联系人';
  @override
  String get k_002tu9r => '性能';
  @override
  String k_0vwtop2({required Object getMsg}) => '获取到的消息:$getMsg';
  @override
  String k_0upijvs({required Object message}) => '获取讨论区列表失败 $message';
  @override
  String get k_1tmcw5c => '请完善话题标题';
  @override
  String get k_1cnmslk => '必须选择一个标签';
  @override
  String k_0v5hlay({required Object message}) => '创建话题失败 $message';
  @override
  String get k_0z3ytji => '创建话题成功';
  @override
  String get k_1a8vem3 => '创建者异常';
  @override
  String get k_0eskkr1 => '选择讨论区';
  @override
  String get k_0d7plb5 => '创建话题';
  @override
  String get k_144t0ho => '---- 相关讨论 ----';
  @override
  String get k_0pnz619 => '填写话题标题';
  @override
  String get k_136v279 => '+标签（至少添加一个）';
  @override
  String get k_04hjhvp => '讨论区参数异常';
  @override
  String get k_002r79h => '全部';
  @override
  String get k_03ejkb6 => '已加入';
  @override
  String get k_172tngw => '话题（未连接）';
  @override
  String get k_0rnmfc4 => '该讨论区下暂无话题';
  @override
  String get k_1pq0ybn => '暂未加入任何话题';
  @override
  String get k_0bh95w0 => '无网络连接，进入话题失败';
  @override
  String get k_002twmj => '群聊';
  @override
  String get k_0em28sp => '暂无群聊';
  @override
  String get k_09kalj0 => '清空聊天记录';
  @override
  String get k_18qjstb => '转让群主';
  @override
  String get k_14j5iul => '删除并退出';
  @override
  String get k_0jtutmw => '退出后不会接收到此群聊消息';
  @override
  String get k_04dqh36 => '暂无新联系人';
  @override
  String get k_08k00l9 => '正在加载...';
  @override
  String get k_197r4f7 => '即时通信服务连接成功';
  @override
  String get k_1s5xnir => '即时通信 SDK初始化失败';
  @override
  String k_0owk5ss({required Object failedReason}) => '登录失败 $failedReason';
  @override
  String get k_15bxnkw => '网络连接丢失';
  @override
  String get k_0glj9us => '发起会话';
  @override
  String get k_1631kyh => '创建工作群';
  @override
  String get k_1644yii => '创建社交群';
  @override
  String get k_1fxfx04 => '创建会议群';
  @override
  String get k_1cnkqc9 => '创建直播群';
  @override
  String get k_002r09z => '频道';
  @override
  String get k_003nvk2 => '消息';
  @override
  String get k_1jwxwgt => '连接中...';
  @override
  String get k_03gm52d => '通讯录';
  @override
  String get k_003k7dc => '我的';
  @override
  String get k_14yh35u => '登录·即时通信';
  @override
  String get k_0st7i3e => '体验群组聊天，音视频对话等IM功能';
  @override
  String get k_0cr1atw => '中国大陆';
  @override
  String get k_0mnxjg7 =>
      '欢迎使用腾讯云即时通信 IM，为保护您的个人信息安全，我们更新了《隐私政策》，主要完善了收集用户信息的具体内容和目的、增加了第三方SDK使用等方面的内容。';
  @override
  String get k_1545beg => '请您点击';
  @override
  String get k_0opnzp6 => '《用户协议》';
  @override
  String get k_00041m1 => '和';
  @override
  String get k_0orhtx0 => '《隐私协议》';
  @override
  String get k_11x8pvm => '并仔细阅读，如您同意以上内容，请点击“同意并继续”，开始使用我们的产品与服务！';
  @override
  String get k_17nw8gq => '同意并继续';
  @override
  String get k_1nynslj => '不同意并退出';
  @override
  String get k_0jsvmjm => '请输入手机号';
  @override
  String get k_1lg8qh2 => '手机号格式错误';
  @override
  String get k_03jia4z => '无网络连接';
  @override
  String get k_007jqt2 => '验证码发送成功';
  @override
  String get k_1a55aib => '验证码异常';
  @override
  String k_1mw45lz({required Object errorReason}) => '登录失败$errorReason';
  @override
  String get k_16r3sej => '国家/地区';
  @override
  String get k_15hlgzr => '选择你的国家区号';
  @override
  String get k_1bnmt3h => '请使用英文搜索';
  @override
  String get k_03fei8z => '手机号';
  @override
  String get k_03aj66h => '验证码';
  @override
  String get k_1m9jtmw => '请输入验证码';
  @override
  String get k_0y1wbxk => '获取验证码';
  @override
  String get k_002ri2g => '登陆';
  @override
  String get k_161ecly => '当前无网络';
  @override
  String get k_11uz2i8 => '重试网络';
  @override
  String get k_1vhzltr => '腾讯云即时通信IM';
  @override
  String get k_0j433ys => '腾讯云TRTC';
  @override
  String get k_0epvs61 => '更换皮肤';
  @override
  String get k_12u8g8l => '免责声明';
  @override
  String get k_1p0j8i3 =>
      'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。';
  @override
  String get k_0k7qoht => '同意任何用户加好友';
  @override
  String get k_0gyhkp5 => '需要验证';
  @override
  String get k_121ruco => '拒绝任何人加好友';
  @override
  String get k_003kfai => '未知';
  @override
  String get k_1kvyskd => '无网络连接，无法修改';
  @override
  String get k_1j91bvz => 'TUIKIT 为你选择一个头像?';
  @override
  String get k_1wmkneq => '加我为好友时需要验证';
  @override
  String get k_1eitsd0 => '关于腾讯云·通信';
  @override
  String get k_1919d6m => '隐私条例';
  @override
  String get k_0wqhgor => '个人信息收集清单';
  @override
  String get k_12rfxml => '第三方信息共享清单';
  @override
  String get k_131g7q4 => '注销账户';
  @override
  String get k_03fel2u => '版本号';
  @override
  String get k_16kts8h => '退出登录';
  @override
  String get k_129scag => '好友删除成功';
  @override
  String get k_094phq4 => '好友添加失败';
  @override
  String get k_13spdki => '发送消息';
  @override
  String get k_1666isy => '清除好友';
  @override
  String get k_0r8fi93 => '好友添加成功';
  @override
  String get k_02qw14e => '好友申请已发出';
  @override
  String get k_0n3md5x => '当前用户在黑名单';
  @override
  String get k_14c600t => '修改备注';
  @override
  String get k_1f811a4 => '支持数字、英文、下划线';
  @override
  String get k_11z7ml4 => '详细资料';
  @override
  String get k_0003y9x => '无';
  @override
  String get k_1679vrd => '加为好友';
  @override
  String get k_1ajt0b1 => '获取当前位置失败';
  @override
  String get k_0lhm9xq => '发起检索成功';
  @override
  String get k_0fdeled => '发起检索失败';
  @override
  String get k_1yh0a50 => 'mapDidLoad-地图加载完成';
  @override
  String get k_1t2zg6h => '图片验证码校验失败';
  @override
  String get k_03ibg5h => '星期一';
  @override
  String get k_03i7hu1 => '星期二';
  @override
  String get k_03iaiks => '星期三';
  @override
  String get k_03el9pa => '星期四';
  @override
  String get k_03i7ok1 => '星期五';
  @override
  String get k_03efxyg => '星期六';
  @override
  String get k_03ibfd2 => '星期七';
  @override
  String k_1o7lf2y({required Object errorMessage}) => '服务器错误：$errorMessage';
  @override
  String k_118l7sq({required Object requestErrorMessage}) =>
      '请求错误：$requestErrorMessage';
  @override
  String get k_003nfx9 => '深沉';
  @override
  String get k_003rvjp => '轻快';
  @override
  String get k_003rtht => '明媚';
  @override
  String get k_003qxiw => '梦幻';
  @override
  String k_0s5zoi3({required Object option1}) => '发生错误 $option1';
  @override
  String k_0i8egqa({required Object option8}) => '获取到的消息:$option8';
  @override
  String k_0pokyns({required Object option8}) => '获取讨论区列表失败 $option8';
  @override
  String k_1y03m8a({required Object option8}) => '创建话题失败 $option8';
  @override
  String k_1v6uh9c({required Object option8}) => '登录失败 $option8';
  @override
  String k_0t5a9hl({required Object option1}) => '登录失败$option1';
  @override
  String k_0k3uv02({required Object option8}) => '服务器错误：$option8';
  @override
  String k_1g9o3kz({required Object option8}) => '请求错误：$option8';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
  Map<String, dynamic> _buildFlatMap() {
    return {
      'k_03f15qk': 'Blocklist',
      'k_0uc5cnb':
          'Beta test in progress. Channel creation is not supported now.',
      'k_003nevv': 'Cancel',
      'k_003rzap': 'OK',
      'k_0s5ey0o': 'TRTC',
      'k_03gpl3d': 'Hello',
      'k_0352fjr': 'Failed to enter the channel due to network disconnection',
      'k_0d7n018': 'End topic',
      'k_0d826hk': 'Pin topic to top',
      'k_15wcgna': 'Ended successfully',
      'k_15wo7xu': 'Pinned to top successfully',
      'k_002s934': 'Topic',
      'k_18g3zdo': 'Cloud Communication · IM',
      'k_1m8vyp0': 'New contacts',
      'k_0elz70e': 'Group chats',
      'k_18tb4mo': 'No contact',
      'k_18nuh87': 'Contact us',
      'k_1uf134v':
          'To provide feedback or suggestions, join our QQ group at 788910197.',
      'k_0xlhhrn': 'Online time: 10 AM to 8 PM, Mon through Fri',
      'k_17fmlyf': 'Clear chat',
      'k_0dhesoz': 'Unpin from top',
      'k_002sk7x': 'Pin to top',
      'k_0gmpgcg': 'No conversation',
      'k_002tu9r': 'Performance',
      'k_1tmcw5c': 'Complete your topic title',
      'k_1cnmslk': 'A tag must be selected',
      'k_0z3ytji': 'Topic created successfully',
      'k_1a8vem3': 'Creator exception',
      'k_0eskkr1': 'Select a discussion forum',
      'k_0d7plb5': 'Create topic',
      'k_144t0ho': '---- Related discussions ----',
      'k_0pnz619': 'Enter the topic title',
      'k_136v279': '+ Tag (add at least one tag)',
      'k_04hjhvp': 'Discussion forum parameter exception',
      'k_002r79h': 'All',
      'k_03ejkb6': 'Joined',
      'k_172tngw': 'Topic (disconnected)',
      'k_0rnmfc4': 'No topic in the discussion forum',
      'k_1pq0ybn': 'You haven\'t joined any topic yet',
      'k_0bh95w0': 'Failed to join the topic due to network disconnection',
      'k_002twmj': 'Group chat',
      'k_09kalj0': 'Clear chat history',
      'k_18qjstb': 'Transfer group owner',
      'k_14j5iul': 'Delete and exit',
      'k_0jtutmw':
          'You will not be able to receive messages from this group chat after you exit',
      'k_08k00l9': 'Loading…',
      'k_197r4f7': 'IM service connected successfully',
      'k_1s5xnir': 'Failed to initialize the IM SDK',
      'k_15bxnkw': 'Network connection lost',
      'k_002r09z': 'Channel',
      'k_003nvk2': 'Message',
      'k_1jwxwgt': 'Connecting…',
      'k_03gm52d': 'Contacts',
      'k_003k7dc': 'Me',
      'k_14yh35u': 'Log in to IM',
      'k_0st7i3e': 'Try IM features such as group chat and audio/video call',
      'k_0cr1atw': 'Chinese mainland',
      'k_0jsvmjm': 'Enter your mobile number',
      'k_1lg8qh2': 'Incorrect mobile number format',
      'k_03jia4z': 'No network connection',
      'k_007jqt2': 'Verification code sent successfully',
      'k_1t2zg6h': 'Image verification failed',
      'k_1a55aib': 'Verification code exception',
      'k_16r3sej': 'Country/Region',
      'k_15hlgzr': 'Select your country code',
      'k_1bnmt3h': 'Please search in English',
      'k_003kv3v': 'Search',
      'k_03fei8z': 'Mobile number',
      'k_03aj66h': 'Verification code',
      'k_1m9jtmw': 'Enter the verification code',
      'k_0y1wbxk': 'Send',
      'k_0orhtx0': 'Privacy Agreement',
      'k_00041m1': 'and',
      'k_0opnzp6': 'User Agreement',
      'k_161ecly': 'Network unavailable',
      'k_11uz2i8': 'Reconnect network',
      'k_1vhzltr': 'Tencent Cloud IM',
      'k_0j433ys': 'Tencent Cloud TRTC',
      'k_12u8g8l': 'Disclaimer',
      'k_1p0j8i3':
          'Instant Messaging (IM) is a test product provided by Tencent Cloud. It is for trying out features, but not for commercial use. To follow regulatory requirements of the authority, audio and video-based interactions performed via IM will be recorded and archived throughout the whole process. It is strictly prohibited to disseminate via IM any pornographic, abusive, violent, political and other noncompliant content.',
      'k_0k7qoht': 'Accept all friend requests',
      'k_0gyhkp5': 'Require approval for friend requests',
      'k_121ruco': 'Reject all friend requests',
      'k_003kfai': 'Unknown',
      'k_1kvyskd': 'Modification failed due to network disconnection',
      'k_1wmkneq': 'Require approval',
      'k_1eitsd0': 'About Tencent Cloud IM',
      'k_1919d6m': 'Privacy Policy',
      'k_16kts8h': 'Log out',
      'k_129scag': 'Friend deleted successfully',
      'k_094phq4': 'Failed to add the friend',
      'k_13spdki': 'Send message',
      'k_0h22snw': 'Audio call',
      'k_0h20hg5': 'Video call',
      'k_1666isy': 'Delete friend',
      'k_0r8fi93': 'Friend added successfully',
      'k_02qw14e': 'Friend request sent',
      'k_0n3md5x': 'The current user is on the blocklist',
      'k_14c600t': 'Modify remarks',
      'k_1f811a4': 'Allows only digits, letters and underscores',
      'k_11z7ml4': 'Profile',
      'k_0003y9x': 'None',
      'k_1679vrd': 'Add as friend',
      'k_03ibg5h': 'Mon',
      'k_03i7hu1': 'Tue',
      'k_03iaiks': 'Wed',
      'k_03el9pa': 'Thu',
      'k_03i7ok1': 'Fri',
      'k_03efxyg': 'Sat',
      'k_03ibfd2': 'Sun',
      'k_003ltgm': 'Location',
      'k_04dqh36': 'No new contact',
      'k_0mnxjg7':
          'Welcome to Tencent Cloud Instant Messaging (IM). To protect the security of your personal information, we have updated the Privacy Policy, mainly improving the specific content and purpose for user information collection and adding the use of third-party SDKs.',
      'k_1545beg': 'Please tap ',
      'k_11x8pvm':
          'and read them carefully. If you agree to the content, tap "Accept and continue" to start using our product and service.',
      'k_17nw8gq': 'Accept and continue',
      'k_1nynslj': 'Reject and quit',
      'k_1j91bvz': 'Let TUIKit pick a profile photo for you?',
      'k_0wqhgor': 'Personal information collection list',
      'k_12rfxml': 'Third-party information sharing list',
      'k_131g7q4': 'Deregister account',
      'k_03fel2u': 'Version',
      'k_1ajt0b1': 'Failed to get the current location',
      'k_0lhm9xq': 'Search initiated successfully',
      'k_0fdeled': 'Failed to initiate the search',
      'k_1yh0a50': 'mapDidLoad - The map has been loaded',
      'k_16758qw': 'Add friend',
      'k_0elt0kw': 'Add group chat',
      'k_0s3p3ji': 'No blocklist',
      'k_02slfpm': ({required Object errorMessage}) => 'Error: $errorMessage',
      'k_1m8zuj4': 'Select contact',
      'k_0vwtop2': ({required Object getMsg}) => 'Message obtained: $getMsg',
      'k_0upijvs': ({required Object message}) =>
          'Failed to get the discussion forum list: $message',
      'k_0v5hlay': ({required Object message}) =>
          'Failed to create the topic: $message',
      'k_0em28sp': 'No group chat',
      'k_0owk5ss': ({required Object failedReason}) =>
          'Login failed: $failedReason',
      'k_0glj9us': 'Initiate conversation',
      'k_1631kyh': 'Create work group',
      'k_1644yii': 'Create public group',
      'k_1fxfx04': 'Create meeting group',
      'k_1cnkqc9': 'Create audio-video group',
      'k_1mw45lz': ({required Object errorReason}) =>
          'Login failed: $errorReason',
      'k_0epvs61': 'Change skin',
      'k_002ri2g': 'Log in',
      'k_1o7lf2y': ({required Object errorMessage}) =>
          'Server error: $errorMessage',
      'k_118l7sq': ({required Object requestErrorMessage}) =>
          'Request error: $requestErrorMessage',
      'k_003nfx9': 'Deep',
      'k_003rvjp': 'Light',
      'k_003rtht': 'Bright',
      'k_003qxiw': 'Fantasy',
      'k_0s5zoi3': ({required Object option1}) => 'Error: $option1',
      'k_0i8egqa': ({required Object option8}) => 'Message obtained: $option8',
      'k_0pokyns': ({required Object option8}) =>
          'Failed to get the discussion forum list: $option8',
      'k_1y03m8a': ({required Object option8}) =>
          'Failed to create the topic: $option8',
      'k_1v6uh9c': ({required Object option8}) => 'Login failed: $option8',
      'k_0t5a9hl': ({required Object option1}) => 'Login failed: $option1',
      'k_0k3uv02': ({required Object option8}) => 'Server error: $option8',
      'k_1g9o3kz': ({required Object option8}) => 'Request error: $option8',
    };
  }
}

extension on _StringsZh {
  Map<String, dynamic> _buildFlatMap() {
    return {
      'k_16758qw': '添加好友',
      'k_0elt0kw': '添加群聊',
      'k_03f15qk': '黑名单',
      'k_0s3p3ji': '暂无黑名单',
      'k_0uc5cnb': '我们还在内测中，暂不支持创建频道。',
      'k_003rzap': '确定',
      'k_003nevv': '取消',
      'k_0s5ey0o': '实时音视频 TRTC',
      'k_03gpl3d': '大家好',
      'k_0352fjr': '无网络连接，进入频道失败',
      'k_0d7n018': '结束话题',
      'k_0d826hk': '置顶话题',
      'k_15wcgna': '结束成功',
      'k_15wo7xu': '置顶成功',
      'k_02slfpm': ({required Object errorMessage}) => '发生错误 $errorMessage',
      'k_003ltgm': '位置',
      'k_0h22snw': '语音通话',
      'k_0h20hg5': '视频通话',
      'k_002s934': '话题',
      'k_18g3zdo': '云通信·IM',
      'k_1m8vyp0': '新的联系人',
      'k_0elz70e': '我的群聊',
      'k_18tb4mo': '无联系人',
      'k_18nuh87': '联系我们',
      'k_1uf134v': '反馈及建议可以加入QQ群：788910197',
      'k_0xlhhrn': '在线时间，周一到周五，早上10点 - 晚上8点',
      'k_17fmlyf': '清除聊天',
      'k_0dhesoz': '取消置顶',
      'k_002sk7x': '置顶',
      'k_003kv3v': '搜索',
      'k_0gmpgcg': '暂无会话',
      'k_1m8zuj4': '选择联系人',
      'k_002tu9r': '性能',
      'k_0vwtop2': ({required Object getMsg}) => '获取到的消息:$getMsg',
      'k_0upijvs': ({required Object message}) => '获取讨论区列表失败 $message',
      'k_1tmcw5c': '请完善话题标题',
      'k_1cnmslk': '必须选择一个标签',
      'k_0v5hlay': ({required Object message}) => '创建话题失败 $message',
      'k_0z3ytji': '创建话题成功',
      'k_1a8vem3': '创建者异常',
      'k_0eskkr1': '选择讨论区',
      'k_0d7plb5': '创建话题',
      'k_144t0ho': '---- 相关讨论 ----',
      'k_0pnz619': '填写话题标题',
      'k_136v279': '+标签（至少添加一个）',
      'k_04hjhvp': '讨论区参数异常',
      'k_002r79h': '全部',
      'k_03ejkb6': '已加入',
      'k_172tngw': '话题（未连接）',
      'k_0rnmfc4': '该讨论区下暂无话题',
      'k_1pq0ybn': '暂未加入任何话题',
      'k_0bh95w0': '无网络连接，进入话题失败',
      'k_002twmj': '群聊',
      'k_0em28sp': '暂无群聊',
      'k_09kalj0': '清空聊天记录',
      'k_18qjstb': '转让群主',
      'k_14j5iul': '删除并退出',
      'k_0jtutmw': '退出后不会接收到此群聊消息',
      'k_04dqh36': '暂无新联系人',
      'k_08k00l9': '正在加载...',
      'k_197r4f7': '即时通信服务连接成功',
      'k_1s5xnir': '即时通信 SDK初始化失败',
      'k_0owk5ss': ({required Object failedReason}) => '登录失败 $failedReason',
      'k_15bxnkw': '网络连接丢失',
      'k_0glj9us': '发起会话',
      'k_1631kyh': '创建工作群',
      'k_1644yii': '创建社交群',
      'k_1fxfx04': '创建会议群',
      'k_1cnkqc9': '创建直播群',
      'k_002r09z': '频道',
      'k_003nvk2': '消息',
      'k_1jwxwgt': '连接中...',
      'k_03gm52d': '通讯录',
      'k_003k7dc': '我的',
      'k_14yh35u': '登录·即时通信',
      'k_0st7i3e': '体验群组聊天，音视频对话等IM功能',
      'k_0cr1atw': '中国大陆',
      'k_0mnxjg7':
          '欢迎使用腾讯云即时通信 IM，为保护您的个人信息安全，我们更新了《隐私政策》，主要完善了收集用户信息的具体内容和目的、增加了第三方SDK使用等方面的内容。',
      'k_1545beg': '请您点击',
      'k_0opnzp6': '《用户协议》',
      'k_00041m1': '和',
      'k_0orhtx0': '《隐私协议》',
      'k_11x8pvm': '并仔细阅读，如您同意以上内容，请点击“同意并继续”，开始使用我们的产品与服务！',
      'k_17nw8gq': '同意并继续',
      'k_1nynslj': '不同意并退出',
      'k_0jsvmjm': '请输入手机号',
      'k_1lg8qh2': '手机号格式错误',
      'k_03jia4z': '无网络连接',
      'k_007jqt2': '验证码发送成功',
      'k_1a55aib': '验证码异常',
      'k_1mw45lz': ({required Object errorReason}) => '登录失败$errorReason',
      'k_16r3sej': '国家/地区',
      'k_15hlgzr': '选择你的国家区号',
      'k_1bnmt3h': '请使用英文搜索',
      'k_03fei8z': '手机号',
      'k_03aj66h': '验证码',
      'k_1m9jtmw': '请输入验证码',
      'k_0y1wbxk': '获取验证码',
      'k_002ri2g': '登陆',
      'k_161ecly': '当前无网络',
      'k_11uz2i8': '重试网络',
      'k_1vhzltr': '腾讯云即时通信IM',
      'k_0j433ys': '腾讯云TRTC',
      'k_0epvs61': '更换皮肤',
      'k_12u8g8l': '免责声明',
      'k_1p0j8i3':
          'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
      'k_0k7qoht': '同意任何用户加好友',
      'k_0gyhkp5': '需要验证',
      'k_121ruco': '拒绝任何人加好友',
      'k_003kfai': '未知',
      'k_1kvyskd': '无网络连接，无法修改',
      'k_1j91bvz': 'TUIKIT 为你选择一个头像?',
      'k_1wmkneq': '加我为好友时需要验证',
      'k_1eitsd0': '关于腾讯云·通信',
      'k_1919d6m': '隐私条例',
      'k_0wqhgor': '个人信息收集清单',
      'k_12rfxml': '第三方信息共享清单',
      'k_131g7q4': '注销账户',
      'k_03fel2u': '版本号',
      'k_16kts8h': '退出登录',
      'k_129scag': '好友删除成功',
      'k_094phq4': '好友添加失败',
      'k_13spdki': '发送消息',
      'k_1666isy': '清除好友',
      'k_0r8fi93': '好友添加成功',
      'k_02qw14e': '好友申请已发出',
      'k_0n3md5x': '当前用户在黑名单',
      'k_14c600t': '修改备注',
      'k_1f811a4': '支持数字、英文、下划线',
      'k_11z7ml4': '详细资料',
      'k_0003y9x': '无',
      'k_1679vrd': '加为好友',
      'k_1ajt0b1': '获取当前位置失败',
      'k_0lhm9xq': '发起检索成功',
      'k_0fdeled': '发起检索失败',
      'k_1yh0a50': 'mapDidLoad-地图加载完成',
      'k_1t2zg6h': '图片验证码校验失败',
      'k_03ibg5h': '星期一',
      'k_03i7hu1': '星期二',
      'k_03iaiks': '星期三',
      'k_03el9pa': '星期四',
      'k_03i7ok1': '星期五',
      'k_03efxyg': '星期六',
      'k_03ibfd2': '星期七',
      'k_1o7lf2y': ({required Object errorMessage}) => '服务器错误：$errorMessage',
      'k_118l7sq': ({required Object requestErrorMessage}) =>
          '请求错误：$requestErrorMessage',
      'k_003nfx9': '深沉',
      'k_003rvjp': '轻快',
      'k_003rtht': '明媚',
      'k_003qxiw': '梦幻',
      'k_0s5zoi3': ({required Object option1}) => '发生错误 $option1',
      'k_0i8egqa': ({required Object option8}) => '获取到的消息:$option8',
      'k_0pokyns': ({required Object option8}) => '获取讨论区列表失败 $option8',
      'k_1y03m8a': ({required Object option8}) => '创建话题失败 $option8',
      'k_1v6uh9c': ({required Object option8}) => '登录失败 $option8',
      'k_0t5a9hl': ({required Object option1}) => '登录失败$option1',
      'k_0k3uv02': ({required Object option8}) => '服务器错误：$option8',
      'k_1g9o3kz': ({required Object option8}) => '请求错误：$option8',
    };
  }
}
