// ignore_for_file: annotate_overrides

/*
 * Generated file. Do not edit.
 *
 * Locales: 2
 * Strings: 562 (281.0 per locale)
 *
 * Built on 2022-05-30 at 07:41 UTC
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
  String get k_1fdhj9g => 'This version does not support the message';
  String get k_06pujtm => 'Accept all friend requests';
  String get k_0gyhkp5 => 'Require approval for friend requests';
  String get k_121ruco => 'Reject all friend requests';
  String get k_05nspni => 'Custom field';
  String get k_03fchyy => 'Group profile photo';
  String get k_03i9mfe => 'Group introduction';
  String get k_03agq58 => 'Group name';
  String get k_039xqny => 'Group notification';
  String get k_003tr0a => 'Group owner';
  String get k_002wddw => 'Mute';
  String get k_0got6f7 => 'Unmute';
  String get k_1uaqed6 => '["Custom"]';
  String get k_0z2z7rx => '["Voice"]';
  String get k_0y39ngu => '["Emoji"]';
  String get k_0y1a2my => '["Image"]';
  String get k_0z4fib8 => '["Video"]';
  String get k_0y24mcg => '["Location"]';
  String get k_0pewpd1 => '["Chat history"]';
  String get k_13s8d9p => 'Unknown message';
  String get k_003qkx2 => 'Calendar';
  String get k_003n2pz => 'Camera';
  String get k_03idjo0 => 'Contact';
  String get k_003ltgm => 'Location';
  String get k_02k3k86 => 'Mic';
  String get k_003pm7l => 'Album';
  String get k_15ao57x => 'Album write';
  String get k_164m3jd => 'Local storage';
  String get k_03r6qyx => 'We need your approval to get information.';
  String get k_02noktt => 'Reject';
  String get k_00043x4 => 'Agree';
  String get k_003qzac => 'Yesterday';
  String get k_003r39d => '2 days ago';
  String get k_03fqp9o => 'Sun';
  String get k_03ibg5h => 'Mon';
  String get k_03i7hu1 => 'Tue';
  String get k_03iaiks => 'Wed';
  String get k_03el9pa => 'Thu';
  String get k_03i7ok1 => 'Fri';
  String get k_03efxyg => 'Sat';
  String get k_003q7ba => 'Afternoon';
  String get k_003q7bb => 'Morning';
  String get k_003pu3h => 'Now';
  String get k_002rflt => 'Delete';
  String get k_1don84v => 'Failed to locate the original message';
  String get k_003q5fi => 'Copy';
  String get k_003prq0 => 'Forward';
  String get k_002r1h2 => 'Multiple-choice';
  String get k_003j708 => 'Reference';
  String get k_003pqpr => 'Recall';
  String get k_03ezhho => 'Copied';
  String get k_11ctfsz => 'Not implemented';
  String get k_1hbjg5g => '["Group system message"]';
  String get k_03tvswb => '["Unknown message"]';
  String get k_155cj23 => 'You\'ve recalled a message.';
  String get k_0gapun3 => 'Edit it again';
  String get k_0003z7x => 'You';
  String get k_002wfe4 => 'Read';
  String get k_002wjlg => 'Unread';
  String get k_003nevv => 'Cancel';
  String get k_001nmhu => 'Open with another app';
  String get k_105682d => 'Failed to load the image';
  String get k_0pytyeu => 'Image saved successfully';
  String get k_0akceel => 'Failed to save the image';
  String get k_003rk1s => 'Save';
  String get k_04a0awq => '["Voice message"]';
  String get k_105c3y3 => 'Failed to load the video';
  String get k_176rzr7 => 'Chat history';
  String get k_002r305 => 'Send';
  String get k_003n8b0 => 'Shoot';
  String get k_003tnp0 => 'File';
  String get k_0ylosxn => 'Custom message';
  String get k_0jhdhtp => 'Sending failed. The video cannot exceed 100 MB.';
  String get k_0am7r68 => 'Slide up to cancel';
  String get k_13dsw4l => 'Release to cancel';
  String get k_15jl6qw => 'Too short';
  String get k_0gx7vl6 => 'Press and hold to talk';
  String get k_15dlafd => 'One-by-one forward';
  String get k_15dryxy => 'Combine and forward';
  String get k_1eyhieh =>
      'Are you sure you want to delete the selected message?';
  String get k_118prbn => 'Search globally';
  String get k_003kv3v => 'Search';
  String get k_17fmlyf => 'Clear chat';
  String get k_0dhesoz => 'Unpin from top';
  String get k_002sk7x => 'Pin to top';
  String get k_003ll77 => 'Draft';
  String get k_003kfai => 'Unknown';
  String get k_13dq4an => 'Automatic approval';
  String get k_0l13cde => 'Admin approval';
  String get k_11y8c6a => 'Disallow group joining';
  String get k_1kvyskd => 'Modification failed due to network disconnection';
  String get k_16payqf => 'Group joining mode';
  String get k_0vzvn8r => 'Modify group name';
  String get k_003rzap => 'OK';
  String get k_038lh6u => 'Group management';
  String get k_0k5wyiy => 'Set admin';
  String get k_0goiuwk => 'Mute all';
  String get k_1g889xx =>
      'If you mute all, only the group owner and admin can speak.';
  String get k_0wlrefq => 'Add group members to mute';
  String get k_0goox5g => 'Mute';
  String get k_08daijh => 'Admin role canceled successfully';
  String get k_0k5u935 => 'Add admin';
  String get k_003ngex => 'Complete';
  String get k_03enyx5 => 'Group member';
  String get k_03erpei => 'Admin';
  String get k_0qi9tno => 'Group owner and admin';
  String get k_0uj7208 =>
      'Failed to view the group members due to network disconnection';
  String get k_0ef2a12 => 'Modify my nickname in group';
  String get k_1aajych =>
      '2–20 characters, including digits, letters, and underscores';
  String get k_137pab5 => 'My nickname in group';
  String get k_0ivim6d => 'No group notice';
  String get k_03eq6cn => 'Group notice';
  String get k_002vxya => 'Modify';
  String get k_03gu05e => 'Chat room';
  String get k_03b4f3p => 'Meeting group';
  String get k_03avj1p => 'Public group';
  String get k_03asq2g => 'Work group';
  String get k_03b3hbi => 'Unknown group';
  String get k_03es1ox => 'Group type';
  String get k_003mz1i => 'Agree';
  String get k_003lpre => 'Reject';
  String get k_003qk66 => 'Profile photo';
  String get k_003lhvk => 'Nickname';
  String get k_003ps50 => 'Account';
  String get k_15lx52z => 'Status';
  String get k_003qgkp => 'Gender';
  String get k_003m6hr => 'Date of birth';
  String get k_0003v6a => 'Male';
  String get k_00043x2 => 'Female';
  String get k_03bcjkv => 'Not set';
  String get k_11s0gdz => 'Modify nickname';
  String get k_0p3j4sd => 'Allows only letters, digits, and underscores';
  String get k_15lyvdt => 'Modify status';
  String get k_0vylzjp => 'None';
  String get k_1hs7ese => 'Modify it later';
  String get k_03exjk7 => 'Remarks';
  String get k_0s3skfd => 'Add to blocklist';
  String get k_17fpl3y => 'Pin chat to top';
  String get k_0p3b31s => 'Modify remarks';
  String get k_0003y9x => 'None';
  String get k_11zgnfs => 'Profile';
  String get k_1tez2xl => 'No status';
  String get k_0vjj2kp => 'Group chat history';
  String get k_003n2rp => 'Select';
  String get k_1m9exwh => 'Recent contacts';
  String get k_119nwqr => 'The input cannot be empty';
  String get k_0pzwbmg => 'Video saved successfully';
  String get k_0aktupv => 'Failed to save the video';
  String get k_1yemzyd => 'Received a message';
  String get k_13sajrj => 'Emoji message';
  String get k_13sjeb7 => 'File message';
  String get k_0yd2ft8 => 'Group notification';
  String get k_13s7mxn => 'Image message';
  String get k_13satlt => 'Location message';
  String get k_00bbtsx => 'Combined message';
  String get k_13sqwu4 => 'Voice message';
  String get k_13sqjjp => 'Video message';
  String k_03iqsh4({required Object s}) => ' $s to ';
  String k_191t5n4({required Object opUserNickName}) =>
      '$opUserNickName changed ';
  String k_1pg6aoj({required Object opUserNickName}) =>
      '$opUserNickName quit group chat';
  String k_1f6zt3v({required Object invitedMemberString}) =>
      'Invite $invitedMemberString to the group';
  String k_0y7zd07({required Object invitedMemberString}) =>
      'Remove $invitedMemberString from the group';
  String k_1d5mshh({required Object joinedMemberString}) =>
      'User $joinedMemberString joined the group';
  String k_0yenqf0({required Object userName}) => '$userName was';
  String k_0spotql({required Object adminMember}) =>
      'Set $adminMember as admin';
  String k_0pg5zzj({required Object operationType}) =>
      'System message: $operationType';
  String k_1c7z88n({required Object fileName}) => '[File] $fileName';
  String get k_1c3us5n => 'The current group does not support @all';
  String get k_11k579v => 'Invalid statements detected';
  String k_0qba4ns({required Object yoursItem}) =>
      ' attempted to access your $yoursItem';
  String k_0oozw9x({required Object diffMinutes}) => '$diffMinutes minutes ago';
  String k_13hzn00({required Object yesterday}) => '$yesterday, yesterday';
  String get k_0n9pyxz => 'The user does not exist';
  String get k_1bjwemh => 'Search by user ID';
  String k_02owlq8({required Object userID}) => 'My user ID: $userID';
  String k_1wu8h4x({required Object showName}) => 'Me: $showName';
  String get k_16758qw => 'Add friend';
  String k_1shx4d9({required Object selfSignature}) => 'Status: $selfSignature';
  String get k_0i553x0 => 'Enter verification information';
  String get k_031ocwx => 'Enter remarks and list';
  String get k_003ojje => 'Remarks';
  String get k_003lsav => 'List';
  String get k_167bdvq => 'My friends';
  String get k_156b4ut => 'Friend request sent';
  String k_1loix7s({required Object groupType}) => 'Group type: $groupType';
  String get k_1lqbsib => 'The group chat does not exist';
  String get k_03h153m => 'Search by group ID';
  String get k_0oxak3r => 'Group request sent';
  String k_1uh417q({required Object displayName}) =>
      '$displayName recalled a message';
  String get k_1aszp2k => 'Are you sure you want to send the message again?';
  String get k_0h1ygf8 => 'Call initiated';
  String get k_0h169j0 => 'Call canceled';
  String get k_0h13jjk => 'Call accepted';
  String get k_0h19hfx => 'Call rejected';
  String get k_0obi9lh => 'No answer';
  String k_0ohzb9l({required Object callTime}) => 'Call duration: $callTime';
  String k_0y9u662({required Object appName}) =>
      '$appName currently does not support this file type. You can use another app to open and preview the file.';
  String get k_1ht1b80 => 'Receiving';
  String get k_0d5z4m5 => 'Select reminder receiver';
  String get k_1665ltg => 'Initiate call';
  String get k_003kthh => 'Photo';
  String get k_119ucng => 'The image cannot be empty';
  String k_0w9x8gw({required Object successPath}) =>
      'Selected successfully: $successPath';
  String k_1np495n({required Object messageString}) =>
      '$messageString[Someone@me]';
  String k_1m797yi({required Object messageString}) => '$messageString[@all]';
  String get k_1uaov41 => 'Search for chat content';
  String k_0bxm97s({required Object adminNum}) => 'Admin ($adminNum/10)';
  String k_0jayw3z({required Object groupMemberNum}) =>
      'Group members ($groupMemberNum members)';
  String get k_0h1svv1 => 'Delete group member';
  String get k_0h1g636 => 'Add group member';
  String k_01yfa4o({required Object memberCount}) => '$memberCount members';
  String get k_0hpukyx => 'View more group members';
  String get k_0qtsar0 => 'Mute notifications';
  String k_03xd79d({required Object signature}) => 'Status: $signature';
  String get k_1m9dftc => 'All contacts';
  String get k_0em4gyz => 'All group chats';
  String get k_002twmj => 'Group chat';
  String get k_09kga0d => 'More chat history';
  String k_1ui5lzi({required Object count}) => '$count messages are found';
  String get k_09khmso => 'Related chat records';
  String k_1kevf4k({required Object receiver}) => 'Chat history with $receiver';
  String get k_03ignw6 => 'All';
  String get k_03icaxo => 'Custom';
  String k_1969986({required Object callingLastMsgShow}) =>
      '[Voice Call]：$callingLastMsgShow';
  String k_1960dlr({required Object callingLastMsgShow}) =>
      '[Video Call]：$callingLastMsgShow';
  String k_1qbg9xc({required Object option8}) => '$option8 to ';
  String k_1wq5ubm({required Object option7}) => '$option7 changed ';
  String k_0y5pu80({required Object option6}) => '$option6 quit group chat';
  String k_0nl7cmd({required Object option5}) => 'Invite $option5 to the group';
  String k_1ju5iqw({required Object option4}) =>
      'Remove $option4 from the group';
  String k_1ovt677({required Object option3}) =>
      'User $option3 joined the group';
  String k_0k05b8b({required Object option2}) => '$option2 was ';
  String k_0wm4xeb({required Object option2}) => 'System message: $option2';
  String k_0nbq9v3({required Object option2}) => 'Call duration: $option2';
  String k_0i1kf53({required Object option2}) => '[File] $option2';
  String k_1gnnby6({required Object option2}) =>
      ' attempted to access your $option2';
  String k_1wh4atg({required Object option2}) => '$option2 minutes ago';
  String k_07sh7g1({required Object option2}) => '$option2, yesterday';
  String k_1pj8xzh({required Object option2}) => 'My user ID: $option2';
  String k_0py1evo({required Object option2}) => 'Status: $option2';
  String k_1kvj4i2({required Object option2}) => '$option2 recalled a message';
  String k_1v0lbpp({required Object option2}) =>
      '$option2 currently does not support this file type. You can use another app to open and preview the file.';
  String k_0torwfz({required Object option2}) =>
      'Selected successfully: $option2';
  String k_0i1bjah({required Object option1}) => '$option1 recalled a message';
  String k_1qzxh9q({required Object option3}) => 'Call duration: $option3';
  String k_0wrgmom({required Object option1}) => '[Voice Call]：$option1';
  String k_06ix2f0({required Object option2}) => '[Video Call]：$option2';
  String k_08o3z5w({required Object option1}) => '[File] $option1';
  String k_0ezbepg({required Object option2}) => '$option2[Someone@me]';
  String k_1ccnht1({required Object option2}) => '$option2[@all]';
  String k_1k3arsw({required Object option2}) => 'Admin ($option2/10)';
  String k_1d4golg({required Object option1}) =>
      'Group members ($option1 members)';
  String k_1bg69nt({required Object option1}) => '$option1 members';
  String k_00gjqxj({required Object option1}) => 'Status: $option1';
  String k_0c29cxr({required Object option1}) => '$option1 messages are found';
  String k_1twk5rz({required Object option1}) => 'Chat history with $option1';
  String get k_18o68ro => 'Allow ';
  String get k_1onpf8u =>
      ' to access your camera to take photos, record videos, and make video calls.';
  String get k_17irga5 =>
      ' to access your microphone to send voice messages, record videos, and make voice/video calls.';
  String get k_0572kc4 => ' to access your photos to send images and videos.';
  String get k_0slykws => ' to access your album to save images and videos.';
  String get k_119pkcd =>
      ' to access your files to view, select and send files in a chat.';
  String get k_03c49qt => 'Authorize now';
  String get k_0nt2uyg => 'Back to the bottom';
  String k_04l16at({required Object option1}) => '$option1 new messages';
  String get k_13p3w93 => 'Someone @ me';
  String get k_18w5uk6 => '@ all';
  String get k_0jmujgh => 'You are receiving other files';
  String get k_12s5ept => 'Message deta ils';
  String k_0mxa4f4({required Object option1}) => '$option1 read';
  String k_061tue3({required Object option2}) => '$option2 unread';
  String k_1vn4xq1({required Object adminMember}) =>
      'remove $adminMember from admin';
  String get k_0e35hsw =>
      'Please allow us to use your camera to capture photos and videos sending to your friends and make video calls.';
  String get k_0dj6yr7 =>
      'Please allow us to use your microphone for sending voice message, make video/audio calls.';
  String get k_003qnsl => 'Save';
  String get k_0s3rtpw =>
      'Please allow us to access the media and files on your devices, in order to select and send to your friend, or save from them';
  String k_0tezv85({required Object option2}) =>
      ' Would like to access $option2';
  String get k_002rety => ' permission. ';
  String get k_0gqewd3 => 'Later';
  String get k_03eq4s1 => 'Authorize Now';
  String get k_18qjstb => 'Transfer Group';
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
  late final Map<String, dynamic> _flatMap = _buildFlatMap();

  // ignore: unused_field
  @override
  late final _StringsZh _root = this;

  // Translations
  @override
  String get k_1yemzyd => '收到一条消息';
  @override
  String get k_0ylosxn => '自定义消息';
  @override
  String get k_13sajrj => '表情消息';
  @override
  String get k_13sjeb7 => '文件消息';
  @override
  String get k_0yd2ft8 => '群提示消息';
  @override
  String get k_13s7mxn => '图片消息';
  @override
  String get k_13satlt => '位置消息';
  @override
  String get k_00bbtsx => '合并转发消息';
  @override
  String get k_13sqwu4 => '语音消息';
  @override
  String get k_13sqjjp => '视频消息';
  @override
  String get k_1fdhj9g => '该版本不支持此消息';
  @override
  String get k_06pujtm => '同意任何用户添加好友';
  @override
  String get k_0gyhkp5 => '需要验证';
  @override
  String get k_121ruco => '拒绝任何人加好友';
  @override
  String get k_05nspni => '自定义字段';
  @override
  String get k_03fchyy => '群头像';
  @override
  String get k_03i9mfe => '群简介';
  @override
  String get k_03agq58 => '群名称';
  @override
  String get k_039xqny => '群通知';
  @override
  String get k_003tr0a => '群主';
  @override
  String k_03iqsh4({required Object s}) => '$s为 ';
  @override
  String k_191t5n4({required Object opUserNickName}) => '$opUserNickName修改';
  @override
  String k_1pg6aoj({required Object opUserNickName}) => '$opUserNickName退出群聊';
  @override
  String k_1f6zt3v({required Object invitedMemberString}) =>
      '邀请$invitedMemberString加入群组';
  @override
  String k_0y7zd07({required Object invitedMemberString}) =>
      '将$invitedMemberString踢出群组';
  @override
  String get k_03c49qt => '去授权';
  @override
  String k_1d5mshh({required Object joinedMemberString}) =>
      '用户$joinedMemberString加入了群聊';
  @override
  String get k_002wddw => '禁言';
  @override
  String get k_0got6f7 => '解除禁言';
  @override
  String k_0yenqf0({required Object userName}) => '$userName 被';
  @override
  String k_0spotql({required Object adminMember}) => '将 $adminMember 设置为管理员';
  @override
  String k_0pg5zzj({required Object operationType}) => '系统消息 $operationType';
  @override
  String k_0ohzb9l({required Object callTime}) => '通话时间：$callTime';
  @override
  String get k_1uaqed6 => '[自定义]';
  @override
  String get k_0z2z7rx => '[语音]';
  @override
  String get k_0y39ngu => '[表情]';
  @override
  String k_1c7z88n({required Object fileName}) => '[文件] $fileName';
  @override
  String get k_0y1a2my => '[图片]';
  @override
  String get k_0z4fib8 => '[视频]';
  @override
  String get k_0y24mcg => '[位置]';
  @override
  String get k_0pewpd1 => '[聊天记录]';
  @override
  String get k_13s8d9p => '未知消息';
  @override
  String get k_1c3us5n => '当前群组不支持@全体成员';
  @override
  String get k_11k579v => '发言中有非法语句';
  @override
  String get k_003qkx2 => '日历';
  @override
  String get k_003n2pz => '相机';
  @override
  String get k_03idjo0 => '联系人';
  @override
  String get k_003ltgm => '位置';
  @override
  String get k_02k3k86 => '麦克风';
  @override
  String get k_003pm7l => '相册';
  @override
  String get k_15ao57x => '相册写入';
  @override
  String get k_164m3jd => '本地存储';
  @override
  String k_0qba4ns({required Object yoursItem}) => '想访问您的$yoursItem';
  @override
  String get k_03r6qyx => '我们需要您的同意才能获取信息';
  @override
  String get k_02noktt => '不允许';
  @override
  String get k_00043x4 => '好';
  @override
  String get k_003qzac => '昨天';
  @override
  String get k_003r39d => '前天';
  @override
  String get k_03fqp9o => '星期天';
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
  String k_0oozw9x({required Object diffMinutes}) => '$diffMinutes 分钟前';
  @override
  String get k_003q7ba => '下午';
  @override
  String get k_003q7bb => '上午';
  @override
  String get k_003pu3h => '现在';
  @override
  String k_13hzn00({required Object yesterday}) => '昨天 $yesterday';
  @override
  String get k_0n9pyxz => '用户不存在';
  @override
  String get k_1bjwemh => '搜索用户 ID';
  @override
  String get k_003kv3v => '搜索';
  @override
  String k_02owlq8({required Object userID}) => '我的用户ID: $userID';
  @override
  String k_1wu8h4x({required Object showName}) => '我是: $showName';
  @override
  String get k_16758qw => '添加好友';
  @override
  String k_1shx4d9({required Object selfSignature}) => '个性签名: $selfSignature';
  @override
  String get k_0i553x0 => '填写验证信息';
  @override
  String get k_031ocwx => '请填写备注和分组';
  @override
  String get k_003ojje => '备注';
  @override
  String get k_003lsav => '分组';
  @override
  String get k_167bdvq => '我的好友';
  @override
  String get k_156b4ut => '好友申请已发送';
  @override
  String get k_002r305 => '发送';
  @override
  String get k_03gu05e => '聊天室';
  @override
  String get k_03b4f3p => '会议群';
  @override
  String get k_03avj1p => '公开群';
  @override
  String get k_03asq2g => '工作群';
  @override
  String get k_03b3hbi => '未知群';
  @override
  String k_1loix7s({required Object groupType}) => '群类型: $groupType';
  @override
  String get k_1lqbsib => '该群聊不存在';
  @override
  String get k_03h153m => '搜索群ID';
  @override
  String get k_0oxak3r => '群申请已发送';
  @override
  String get k_002rflt => '删除';
  @override
  String get k_1don84v => '无法定位到原消息';
  @override
  String get k_003q5fi => '复制';
  @override
  String get k_003prq0 => '转发';
  @override
  String get k_002r1h2 => '多选';
  @override
  String get k_003j708 => '引用';
  @override
  String get k_003pqpr => '撤回';
  @override
  String get k_03ezhho => '已复制';
  @override
  String get k_11ctfsz => '暂未实现';
  @override
  String get k_1hbjg5g => '[群系统消息]';
  @override
  String get k_03tvswb => '[未知消息]';
  @override
  String get k_155cj23 => '您撤回了一条消息，';
  @override
  String get k_0gapun3 => '重新编辑';
  @override
  String k_1uh417q({required Object displayName}) => '$displayName撤回了一条消息';
  @override
  String get k_1aszp2k => '您确定要重发这条消息么？';
  @override
  String get k_003rzap => '确定';
  @override
  String get k_003nevv => '取消';
  @override
  String get k_0003z7x => '您';
  @override
  String get k_002wfe4 => '已读';
  @override
  String get k_002wjlg => '未读';
  @override
  String get k_0h1ygf8 => '发起通话';
  @override
  String get k_0h169j0 => '取消通话';
  @override
  String get k_0h13jjk => '接受通话';
  @override
  String get k_0h19hfx => '拒绝通话';
  @override
  String get k_0obi9lh => '超时未接听';
  @override
  String k_0y9u662({required Object appName}) =>
      '“$appName”暂不可以打开此类文件，你可以使用其他应用打开并预览';
  @override
  String get k_001nmhu => '用其他应用打开';
  @override
  String get k_1ht1b80 => '正在接收中';
  @override
  String get k_105682d => '图片加载失败';
  @override
  String get k_0pytyeu => '图片保存成功';
  @override
  String get k_0akceel => '图片保存失败';
  @override
  String get k_003rk1s => '保存';
  @override
  String get k_04a0awq => '[语音消息]';
  @override
  String get k_105c3y3 => '视频加载失败';
  @override
  String get k_176rzr7 => '聊天记录';
  @override
  String get k_0d5z4m5 => '选择提醒人';
  @override
  String get k_003ngex => '完成';
  @override
  String get k_1665ltg => '发起呼叫';
  @override
  String get k_003n8b0 => '拍摄';
  @override
  String get k_003kthh => '照片';
  @override
  String get k_003tnp0 => '文件';
  @override
  String get k_0jhdhtp => '发送失败,视频不能大于100MB';
  @override
  String get k_119ucng => '图片不能为空';
  @override
  String k_0w9x8gw({required Object successPath}) => '选择成功$successPath';
  @override
  String get k_13dsw4l => '松开取消';
  @override
  String get k_0am7r68 => '手指上滑，取消发送';
  @override
  String get k_15jl6qw => '说话时间太短!';
  @override
  String get k_0gx7vl6 => '按住说话';
  @override
  String get k_15dlafd => '逐条转发';
  @override
  String get k_15dryxy => '合并转发';
  @override
  String get k_1eyhieh => '确定删除已选消息';
  @override
  String get k_17fmlyf => '清除聊天';
  @override
  String get k_0dhesoz => '取消置顶';
  @override
  String get k_002sk7x => '置顶';
  @override
  String get k_003ll77 => '草稿';
  @override
  String get k_03icaxo => '自定义';
  @override
  String k_1969986({required Object callingLastMsgShow}) =>
      '[语音通话]：$callingLastMsgShow';
  @override
  String k_1960dlr({required Object callingLastMsgShow}) =>
      '[视频通话]：$callingLastMsgShow';
  @override
  String k_1np495n({required Object messageString}) => '$messageString[有人@我]';
  @override
  String k_1m797yi({required Object messageString}) => '$messageString[@所有人]';
  @override
  String get k_1uaov41 => '查找聊天内容';
  @override
  String get k_003kfai => '未知';
  @override
  String get k_13dq4an => '自动审批';
  @override
  String get k_0l13cde => '管理员审批';
  @override
  String get k_11y8c6a => '禁止加群';
  @override
  String get k_1kvyskd => '无网络连接，无法修改';
  @override
  String get k_16payqf => '加群方式';
  @override
  String get k_0vzvn8r => '修改群名称';
  @override
  String get k_038lh6u => '群管理';
  @override
  String get k_0k5wyiy => '设置管理员';
  @override
  String get k_0goiuwk => '全员禁言';
  @override
  String get k_1g889xx => '全员禁言开启后，只允许群主和管理员发言。';
  @override
  String get k_0wlrefq => '添加需要禁言的群成员';
  @override
  String get k_0goox5g => '设置禁言';
  @override
  String get k_08daijh => '成功取消管理员身份';
  @override
  String k_0bxm97s({required Object adminNum}) => '管理员 ($adminNum/10)';
  @override
  String get k_0k5u935 => '添加管理员';
  @override
  String get k_03enyx5 => '群成员';
  @override
  String k_0jayw3z({required Object groupMemberNum}) => '群成员($groupMemberNum人)';
  @override
  String get k_0h1svv1 => '删除群成员';
  @override
  String get k_0h1g636 => '添加群成员';
  @override
  String get k_0uj7208 => '无网络连接，无法查看群成员';
  @override
  String k_01yfa4o({required Object memberCount}) => '$memberCount人';
  @override
  String get k_0hpukyx => '查看更多群成员';
  @override
  String get k_0qtsar0 => '消息免打扰';
  @override
  String get k_0ef2a12 => '修改我的群昵称';
  @override
  String get k_1aajych => '仅限中文、字母、数字和下划线，2-20个字';
  @override
  String get k_137pab5 => '我的群昵称';
  @override
  String get k_0ivim6d => '暂无群公告';
  @override
  String get k_03eq6cn => '群公告';
  @override
  String get k_002vxya => '编辑';
  @override
  String get k_17fpl3y => '置顶聊天';
  @override
  String get k_03es1ox => '群类型';
  @override
  String get k_003mz1i => '同意';
  @override
  String get k_003lpre => '拒绝';
  @override
  String get k_003qk66 => '头像';
  @override
  String get k_003lhvk => '昵称';
  @override
  String get k_003ps50 => '账号';
  @override
  String get k_15lx52z => '个性签名';
  @override
  String get k_003qgkp => '性别';
  @override
  String get k_003m6hr => '生日';
  @override
  String get k_0003v6a => '男';
  @override
  String get k_00043x2 => '女';
  @override
  String get k_03bcjkv => '未设置';
  @override
  String get k_11s0gdz => '修改昵称';
  @override
  String get k_0p3j4sd => '仅限中字、字母、数字和下划线';
  @override
  String get k_15lyvdt => '修改签名';
  @override
  String get k_0vylzjp => '这个人很懒，什么也没写';
  @override
  String get k_1hs7ese => '等上线再改这个';
  @override
  String get k_03exjk7 => '备注名';
  @override
  String get k_0s3skfd => '加入黑名单';
  @override
  String get k_0p3b31s => '修改备注名';
  @override
  String get k_0003y9x => '无';
  @override
  String get k_11zgnfs => '个人资料';
  @override
  String k_03xd79d({required Object signature}) => '个性签名: $signature';
  @override
  String get k_1tez2xl => '暂无个性签名';
  @override
  String get k_118prbn => '全局搜索';
  @override
  String get k_1m9dftc => '全部联系人';
  @override
  String get k_0em4gyz => '全部群聊';
  @override
  String get k_002twmj => '群聊';
  @override
  String get k_09kga0d => '更多聊天记录';
  @override
  String k_1ui5lzi({required Object count}) => '$count条相关聊天记录';
  @override
  String get k_09khmso => '相关聊天记录';
  @override
  String k_1kevf4k({required Object receiver}) => '与$receiver的聊天记录';
  @override
  String get k_0vjj2kp => '群聊的聊天记录';
  @override
  String get k_003n2rp => '选择';
  @override
  String get k_03ignw6 => '所有人';
  @override
  String get k_03erpei => '管理员';
  @override
  String get k_0qi9tno => '群主、管理员';
  @override
  String get k_1m9exwh => '最近联系人';
  @override
  String get k_119nwqr => '输入不能为空';
  @override
  String get k_0pzwbmg => '视频保存成功';
  @override
  String get k_0aktupv => '视频保存失败';
  @override
  String k_1qbg9xc({required Object option8}) => '$option8为 ';
  @override
  String k_1wq5ubm({required Object option7}) => '$option7修改';
  @override
  String k_0y5pu80({required Object option6}) => '$option6退出群聊';
  @override
  String k_0nl7cmd({required Object option5}) => '邀请$option5加入群组';
  @override
  String k_1ju5iqw({required Object option4}) => '将$option4踢出群组';
  @override
  String k_1ovt677({required Object option3}) => '用户$option3加入了群聊';
  @override
  String k_0k05b8b({required Object option2}) => '$option2 被';
  @override
  String k_0wm4xeb({required Object option2}) => '系统消息 $option2';
  @override
  String k_0nbq9v3({required Object option2}) => '通话时间：$option2';
  @override
  String k_0i1kf53({required Object option2}) => '[文件] $option2';
  @override
  String k_1gnnby6({required Object option2}) => '想访问您的$option2';
  @override
  String k_1wh4atg({required Object option2}) => '$option2 分钟前';
  @override
  String k_07sh7g1({required Object option2}) => '昨天 $option2';
  @override
  String k_1pj8xzh({required Object option2}) => '我的用户ID: $option2';
  @override
  String k_0py1evo({required Object option2}) => '个性签名: $option2';
  @override
  String k_1kvj4i2({required Object option2}) => '$option2撤回了一条消息';
  @override
  String k_1v0lbpp({required Object option2}) =>
      '“$option2”暂不可以打开此类文件，你可以使用其他应用打开并预览';
  @override
  String k_0torwfz({required Object option2}) => '选择成功$option2';
  @override
  String k_0i1bjah({required Object option1}) => '$option1撤回了一条消息';
  @override
  String k_1qzxh9q({required Object option3}) => '通话时间：$option3';
  @override
  String k_0wrgmom({required Object option1}) => '[语音通话]：$option1';
  @override
  String k_06ix2f0({required Object option2}) => '[视频通话]：$option2';
  @override
  String k_08o3z5w({required Object option1}) => '[文件] $option1';
  @override
  String k_0ezbepg({required Object option2}) => '$option2[有人@我]';
  @override
  String k_1ccnht1({required Object option2}) => '$option2[@所有人]';
  @override
  String k_1k3arsw({required Object option2}) => '管理员 ($option2/10)';
  @override
  String k_1d4golg({required Object option1}) => '群成员($option1人)';
  @override
  String k_1bg69nt({required Object option1}) => '$option1人';
  @override
  String k_00gjqxj({required Object option1}) => '个性签名: $option1';
  @override
  String k_0c29cxr({required Object option1}) => '$option1条相关聊天记录';
  @override
  String k_1twk5rz({required Object option1}) => '与$option1的聊天记录';
  @override
  String k_1vn4xq1({required Object adminMember}) => '将 $adminMember 取消管理员';
  @override
  String get k_0e35hsw => '为方便您将所拍摄的照片或视频发送给朋友，以及进行视频通话，请允许我们访问摄像头进行拍摄照片和视频。';
  @override
  String get k_0dj6yr7 => '为方便您发送语音消息、拍摄视频以及音视频通话，请允许我们使用麦克风进行录音。';
  @override
  String get k_003qnsl => '存储';
  @override
  String get k_0s3rtpw =>
      '为方便您查看和选择相册里的图片视频发送给朋友，以及保存内容到设备，请允许我们访问您设备上的照片、媒体内容。';
  @override
  String k_0tezv85({required Object option2}) => ' 申请获取$option2';
  @override
  String get k_002rety => '权限';
  @override
  String get k_18o68ro => '需要授予';
  @override
  String get k_1onpf8u => ' 相机权限，以正常使用拍摄图片视频、视频通话等功能。';
  @override
  String get k_17irga5 => ' 麦克风权限，以正常使用发送语音消息、拍摄视频、音视频通话等功能。';
  @override
  String get k_0572kc4 => ' 访问照片权限，以正常使用发送图片、视频等功能。';
  @override
  String get k_0slykws => ' 访问相册写入权限，以正常使用存储图片、视频等功能。';
  @override
  String get k_119pkcd => ' 文件读写权限，以正常使用在聊天功能中的图片查看、选择能力和发送文件的能力。';
  @override
  String get k_0gqewd3 => '以后再说';
  @override
  String get k_03eq4s1 => '去开启';
  @override
  String get k_0nt2uyg => '回到最新位置';
  @override
  String k_04l16at({required Object option1}) => '$option1条新消息';
  @override
  String get k_13p3w93 => '有人@我';
  @override
  String get k_18w5uk6 => '@所有人';
  @override
  String get k_0jmujgh => '其他文件正在接收中';
  @override
  String get k_12s5ept => '消息详情';
  @override
  String k_0mxa4f4({required Object option1}) => '$option1人已读';
  @override
  String k_061tue3({required Object option2}) => '$option2人未读';
  @override
  String get k_18qjstb => '转让群主';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
  Map<String, dynamic> _buildFlatMap() {
    return {
      'k_1fdhj9g': 'This version does not support the message',
      'k_06pujtm': 'Accept all friend requests',
      'k_0gyhkp5': 'Require approval for friend requests',
      'k_121ruco': 'Reject all friend requests',
      'k_05nspni': 'Custom field',
      'k_03fchyy': 'Group profile photo',
      'k_03i9mfe': 'Group introduction',
      'k_03agq58': 'Group name',
      'k_039xqny': 'Group notification',
      'k_003tr0a': 'Group owner',
      'k_002wddw': 'Mute',
      'k_0got6f7': 'Unmute',
      'k_1uaqed6': '["Custom"]',
      'k_0z2z7rx': '["Voice"]',
      'k_0y39ngu': '["Emoji"]',
      'k_0y1a2my': '["Image"]',
      'k_0z4fib8': '["Video"]',
      'k_0y24mcg': '["Location"]',
      'k_0pewpd1': '["Chat history"]',
      'k_13s8d9p': 'Unknown message',
      'k_003qkx2': 'Calendar',
      'k_003n2pz': 'Camera',
      'k_03idjo0': 'Contact',
      'k_003ltgm': 'Location',
      'k_02k3k86': 'Mic',
      'k_003pm7l': 'Album',
      'k_15ao57x': 'Album write',
      'k_164m3jd': 'Local storage',
      'k_03r6qyx': 'We need your approval to get information.',
      'k_02noktt': 'Reject',
      'k_00043x4': 'Agree',
      'k_003qzac': 'Yesterday',
      'k_003r39d': '2 days ago',
      'k_03fqp9o': 'Sun',
      'k_03ibg5h': 'Mon',
      'k_03i7hu1': 'Tue',
      'k_03iaiks': 'Wed',
      'k_03el9pa': 'Thu',
      'k_03i7ok1': 'Fri',
      'k_03efxyg': 'Sat',
      'k_003q7ba': 'Afternoon',
      'k_003q7bb': 'Morning',
      'k_003pu3h': 'Now',
      'k_002rflt': 'Delete',
      'k_1don84v': 'Failed to locate the original message',
      'k_003q5fi': 'Copy',
      'k_003prq0': 'Forward',
      'k_002r1h2': 'Multiple-choice',
      'k_003j708': 'Reference',
      'k_003pqpr': 'Recall',
      'k_03ezhho': 'Copied',
      'k_11ctfsz': 'Not implemented',
      'k_1hbjg5g': '["Group system message"]',
      'k_03tvswb': '["Unknown message"]',
      'k_155cj23': 'You\'ve recalled a message.',
      'k_0gapun3': 'Edit it again',
      'k_0003z7x': 'You',
      'k_002wfe4': 'Read',
      'k_002wjlg': 'Unread',
      'k_003nevv': 'Cancel',
      'k_001nmhu': 'Open with another app',
      'k_105682d': 'Failed to load the image',
      'k_0pytyeu': 'Image saved successfully',
      'k_0akceel': 'Failed to save the image',
      'k_003rk1s': 'Save',
      'k_04a0awq': '["Voice message"]',
      'k_105c3y3': 'Failed to load the video',
      'k_176rzr7': 'Chat history',
      'k_002r305': 'Send',
      'k_003n8b0': 'Shoot',
      'k_003tnp0': 'File',
      'k_0ylosxn': 'Custom message',
      'k_0jhdhtp': 'Sending failed. The video cannot exceed 100 MB.',
      'k_0am7r68': 'Slide up to cancel',
      'k_13dsw4l': 'Release to cancel',
      'k_15jl6qw': 'Too short',
      'k_0gx7vl6': 'Press and hold to talk',
      'k_15dlafd': 'One-by-one forward',
      'k_15dryxy': 'Combine and forward',
      'k_1eyhieh': 'Are you sure you want to delete the selected message?',
      'k_118prbn': 'Search globally',
      'k_003kv3v': 'Search',
      'k_17fmlyf': 'Clear chat',
      'k_0dhesoz': 'Unpin from top',
      'k_002sk7x': 'Pin to top',
      'k_003ll77': 'Draft',
      'k_003kfai': 'Unknown',
      'k_13dq4an': 'Automatic approval',
      'k_0l13cde': 'Admin approval',
      'k_11y8c6a': 'Disallow group joining',
      'k_1kvyskd': 'Modification failed due to network disconnection',
      'k_16payqf': 'Group joining mode',
      'k_0vzvn8r': 'Modify group name',
      'k_003rzap': 'OK',
      'k_038lh6u': 'Group management',
      'k_0k5wyiy': 'Set admin',
      'k_0goiuwk': 'Mute all',
      'k_1g889xx': 'If you mute all, only the group owner and admin can speak.',
      'k_0wlrefq': 'Add group members to mute',
      'k_0goox5g': 'Mute',
      'k_08daijh': 'Admin role canceled successfully',
      'k_0k5u935': 'Add admin',
      'k_003ngex': 'Complete',
      'k_03enyx5': 'Group member',
      'k_03erpei': 'Admin',
      'k_0qi9tno': 'Group owner and admin',
      'k_0uj7208':
          'Failed to view the group members due to network disconnection',
      'k_0ef2a12': 'Modify my nickname in group',
      'k_1aajych':
          '2–20 characters, including digits, letters, and underscores',
      'k_137pab5': 'My nickname in group',
      'k_0ivim6d': 'No group notice',
      'k_03eq6cn': 'Group notice',
      'k_002vxya': 'Modify',
      'k_03gu05e': 'Chat room',
      'k_03b4f3p': 'Meeting group',
      'k_03avj1p': 'Public group',
      'k_03asq2g': 'Work group',
      'k_03b3hbi': 'Unknown group',
      'k_03es1ox': 'Group type',
      'k_003mz1i': 'Agree',
      'k_003lpre': 'Reject',
      'k_003qk66': 'Profile photo',
      'k_003lhvk': 'Nickname',
      'k_003ps50': 'Account',
      'k_15lx52z': 'Status',
      'k_003qgkp': 'Gender',
      'k_003m6hr': 'Date of birth',
      'k_0003v6a': 'Male',
      'k_00043x2': 'Female',
      'k_03bcjkv': 'Not set',
      'k_11s0gdz': 'Modify nickname',
      'k_0p3j4sd': 'Allows only letters, digits, and underscores',
      'k_15lyvdt': 'Modify status',
      'k_0vylzjp': 'None',
      'k_1hs7ese': 'Modify it later',
      'k_03exjk7': 'Remarks',
      'k_0s3skfd': 'Add to blocklist',
      'k_17fpl3y': 'Pin chat to top',
      'k_0p3b31s': 'Modify remarks',
      'k_0003y9x': 'None',
      'k_11zgnfs': 'Profile',
      'k_1tez2xl': 'No status',
      'k_0vjj2kp': 'Group chat history',
      'k_003n2rp': 'Select',
      'k_1m9exwh': 'Recent contacts',
      'k_119nwqr': 'The input cannot be empty',
      'k_0pzwbmg': 'Video saved successfully',
      'k_0aktupv': 'Failed to save the video',
      'k_1yemzyd': 'Received a message',
      'k_13sajrj': 'Emoji message',
      'k_13sjeb7': 'File message',
      'k_0yd2ft8': 'Group notification',
      'k_13s7mxn': 'Image message',
      'k_13satlt': 'Location message',
      'k_00bbtsx': 'Combined message',
      'k_13sqwu4': 'Voice message',
      'k_13sqjjp': 'Video message',
      'k_03iqsh4': ({required Object s}) => ' $s to ',
      'k_191t5n4': ({required Object opUserNickName}) =>
          '$opUserNickName changed ',
      'k_1pg6aoj': ({required Object opUserNickName}) =>
          '$opUserNickName quit group chat',
      'k_1f6zt3v': ({required Object invitedMemberString}) =>
          'Invite $invitedMemberString to the group',
      'k_0y7zd07': ({required Object invitedMemberString}) =>
          'Remove $invitedMemberString from the group',
      'k_1d5mshh': ({required Object joinedMemberString}) =>
          'User $joinedMemberString joined the group',
      'k_0yenqf0': ({required Object userName}) => '$userName was',
      'k_0spotql': ({required Object adminMember}) =>
          'Set $adminMember as admin',
      'k_0pg5zzj': ({required Object operationType}) =>
          'System message: $operationType',
      'k_1c7z88n': ({required Object fileName}) => '[File] $fileName',
      'k_1c3us5n': 'The current group does not support @all',
      'k_11k579v': 'Invalid statements detected',
      'k_0qba4ns': ({required Object yoursItem}) =>
          ' attempted to access your $yoursItem',
      'k_0oozw9x': ({required Object diffMinutes}) =>
          '$diffMinutes minutes ago',
      'k_13hzn00': ({required Object yesterday}) => '$yesterday, yesterday',
      'k_0n9pyxz': 'The user does not exist',
      'k_1bjwemh': 'Search by user ID',
      'k_02owlq8': ({required Object userID}) => 'My user ID: $userID',
      'k_1wu8h4x': ({required Object showName}) => 'Me: $showName',
      'k_16758qw': 'Add friend',
      'k_1shx4d9': ({required Object selfSignature}) =>
          'Status: $selfSignature',
      'k_0i553x0': 'Enter verification information',
      'k_031ocwx': 'Enter remarks and list',
      'k_003ojje': 'Remarks',
      'k_003lsav': 'List',
      'k_167bdvq': 'My friends',
      'k_156b4ut': 'Friend request sent',
      'k_1loix7s': ({required Object groupType}) => 'Group type: $groupType',
      'k_1lqbsib': 'The group chat does not exist',
      'k_03h153m': 'Search by group ID',
      'k_0oxak3r': 'Group request sent',
      'k_1uh417q': ({required Object displayName}) =>
          '$displayName recalled a message',
      'k_1aszp2k': 'Are you sure you want to send the message again?',
      'k_0h1ygf8': 'Call initiated',
      'k_0h169j0': 'Call canceled',
      'k_0h13jjk': 'Call accepted',
      'k_0h19hfx': 'Call rejected',
      'k_0obi9lh': 'No answer',
      'k_0ohzb9l': ({required Object callTime}) => 'Call duration: $callTime',
      'k_0y9u662': ({required Object appName}) =>
          '$appName currently does not support this file type. You can use another app to open and preview the file.',
      'k_1ht1b80': 'Receiving',
      'k_0d5z4m5': 'Select reminder receiver',
      'k_1665ltg': 'Initiate call',
      'k_003kthh': 'Photo',
      'k_119ucng': 'The image cannot be empty',
      'k_0w9x8gw': ({required Object successPath}) =>
          'Selected successfully: $successPath',
      'k_1np495n': ({required Object messageString}) =>
          '$messageString[Someone@me]',
      'k_1m797yi': ({required Object messageString}) => '$messageString[@all]',
      'k_1uaov41': 'Search for chat content',
      'k_0bxm97s': ({required Object adminNum}) => 'Admin ($adminNum/10)',
      'k_0jayw3z': ({required Object groupMemberNum}) =>
          'Group members ($groupMemberNum members)',
      'k_0h1svv1': 'Delete group member',
      'k_0h1g636': 'Add group member',
      'k_01yfa4o': ({required Object memberCount}) => '$memberCount members',
      'k_0hpukyx': 'View more group members',
      'k_0qtsar0': 'Mute notifications',
      'k_03xd79d': ({required Object signature}) => 'Status: $signature',
      'k_1m9dftc': 'All contacts',
      'k_0em4gyz': 'All group chats',
      'k_002twmj': 'Group chat',
      'k_09kga0d': 'More chat history',
      'k_1ui5lzi': ({required Object count}) => '$count messages are found',
      'k_09khmso': 'Related chat records',
      'k_1kevf4k': ({required Object receiver}) =>
          'Chat history with $receiver',
      'k_03ignw6': 'All',
      'k_03icaxo': 'Custom',
      'k_1969986': ({required Object callingLastMsgShow}) =>
          '[Voice Call]：$callingLastMsgShow',
      'k_1960dlr': ({required Object callingLastMsgShow}) =>
          '[Video Call]：$callingLastMsgShow',
      'k_1qbg9xc': ({required Object option8}) => '$option8 to ',
      'k_1wq5ubm': ({required Object option7}) => '$option7 changed ',
      'k_0y5pu80': ({required Object option6}) => '$option6 quit group chat',
      'k_0nl7cmd': ({required Object option5}) =>
          'Invite $option5 to the group',
      'k_1ju5iqw': ({required Object option4}) =>
          'Remove $option4 from the group',
      'k_1ovt677': ({required Object option3}) =>
          'User $option3 joined the group',
      'k_0k05b8b': ({required Object option2}) => '$option2 was ',
      'k_0wm4xeb': ({required Object option2}) => 'System message: $option2',
      'k_0nbq9v3': ({required Object option2}) => 'Call duration: $option2',
      'k_0i1kf53': ({required Object option2}) => '[File] $option2',
      'k_1gnnby6': ({required Object option2}) =>
          ' attempted to access your $option2',
      'k_1wh4atg': ({required Object option2}) => '$option2 minutes ago',
      'k_07sh7g1': ({required Object option2}) => '$option2, yesterday',
      'k_1pj8xzh': ({required Object option2}) => 'My user ID: $option2',
      'k_0py1evo': ({required Object option2}) => 'Status: $option2',
      'k_1kvj4i2': ({required Object option2}) => '$option2 recalled a message',
      'k_1v0lbpp': ({required Object option2}) =>
          '$option2 currently does not support this file type. You can use another app to open and preview the file.',
      'k_0torwfz': ({required Object option2}) =>
          'Selected successfully: $option2',
      'k_0i1bjah': ({required Object option1}) => '$option1 recalled a message',
      'k_1qzxh9q': ({required Object option3}) => 'Call duration: $option3',
      'k_0wrgmom': ({required Object option1}) => '[Voice Call]：$option1',
      'k_06ix2f0': ({required Object option2}) => '[Video Call]：$option2',
      'k_08o3z5w': ({required Object option1}) => '[File] $option1',
      'k_0ezbepg': ({required Object option2}) => '$option2[Someone@me]',
      'k_1ccnht1': ({required Object option2}) => '$option2[@all]',
      'k_1k3arsw': ({required Object option2}) => 'Admin ($option2/10)',
      'k_1d4golg': ({required Object option1}) =>
          'Group members ($option1 members)',
      'k_1bg69nt': ({required Object option1}) => '$option1 members',
      'k_00gjqxj': ({required Object option1}) => 'Status: $option1',
      'k_0c29cxr': ({required Object option1}) => '$option1 messages are found',
      'k_1twk5rz': ({required Object option1}) => 'Chat history with $option1',
      'k_18o68ro': 'Allow ',
      'k_1onpf8u':
          ' to access your camera to take photos, record videos, and make video calls.',
      'k_17irga5':
          ' to access your microphone to send voice messages, record videos, and make voice/video calls.',
      'k_0572kc4': ' to access your photos to send images and videos.',
      'k_0slykws': ' to access your album to save images and videos.',
      'k_119pkcd':
          ' to access your files to view, select and send files in a chat.',
      'k_03c49qt': 'Authorize now',
      'k_0nt2uyg': 'Back to the bottom',
      'k_04l16at': ({required Object option1}) => '$option1 new messages',
      'k_13p3w93': 'Someone @ me',
      'k_18w5uk6': '@ all',
      'k_0jmujgh': 'You are receiving other files',
      'k_12s5ept': 'Message deta ils',
      'k_0mxa4f4': ({required Object option1}) => '$option1 read',
      'k_061tue3': ({required Object option2}) => '$option2 unread',
      'k_1vn4xq1': ({required Object adminMember}) =>
          'remove $adminMember from admin',
      'k_0e35hsw':
          'Please allow us to use your camera to capture photos and videos sending to your friends and make video calls.',
      'k_0dj6yr7':
          'Please allow us to use your microphone for sending voice message, make video/audio calls.',
      'k_003qnsl': 'Save',
      'k_0s3rtpw':
          'Please allow us to access the media and files on your devices, in order to select and send to your friend, or save from them',
      'k_0tezv85': ({required Object option2}) =>
          ' Would like to access $option2',
      'k_002rety': ' permission. ',
      'k_0gqewd3': 'Later',
      'k_03eq4s1': 'Authorize Now',
      'k_18qjstb': 'Transfer Group',
    };
  }
}

extension on _StringsZh {
  Map<String, dynamic> _buildFlatMap() {
    return {
      'k_1yemzyd': '收到一条消息',
      'k_0ylosxn': '自定义消息',
      'k_13sajrj': '表情消息',
      'k_13sjeb7': '文件消息',
      'k_0yd2ft8': '群提示消息',
      'k_13s7mxn': '图片消息',
      'k_13satlt': '位置消息',
      'k_00bbtsx': '合并转发消息',
      'k_13sqwu4': '语音消息',
      'k_13sqjjp': '视频消息',
      'k_1fdhj9g': '该版本不支持此消息',
      'k_06pujtm': '同意任何用户添加好友',
      'k_0gyhkp5': '需要验证',
      'k_121ruco': '拒绝任何人加好友',
      'k_05nspni': '自定义字段',
      'k_03fchyy': '群头像',
      'k_03i9mfe': '群简介',
      'k_03agq58': '群名称',
      'k_039xqny': '群通知',
      'k_003tr0a': '群主',
      'k_03iqsh4': ({required Object s}) => '$s为 ',
      'k_191t5n4': ({required Object opUserNickName}) => '$opUserNickName修改',
      'k_1pg6aoj': ({required Object opUserNickName}) => '$opUserNickName退出群聊',
      'k_1f6zt3v': ({required Object invitedMemberString}) =>
          '邀请$invitedMemberString加入群组',
      'k_0y7zd07': ({required Object invitedMemberString}) =>
          '将$invitedMemberString踢出群组',
      'k_03c49qt': '去授权',
      'k_1d5mshh': ({required Object joinedMemberString}) =>
          '用户$joinedMemberString加入了群聊',
      'k_002wddw': '禁言',
      'k_0got6f7': '解除禁言',
      'k_0yenqf0': ({required Object userName}) => '$userName 被',
      'k_0spotql': ({required Object adminMember}) => '将 $adminMember 设置为管理员',
      'k_0pg5zzj': ({required Object operationType}) => '系统消息 $operationType',
      'k_0ohzb9l': ({required Object callTime}) => '通话时间：$callTime',
      'k_1uaqed6': '[自定义]',
      'k_0z2z7rx': '[语音]',
      'k_0y39ngu': '[表情]',
      'k_1c7z88n': ({required Object fileName}) => '[文件] $fileName',
      'k_0y1a2my': '[图片]',
      'k_0z4fib8': '[视频]',
      'k_0y24mcg': '[位置]',
      'k_0pewpd1': '[聊天记录]',
      'k_13s8d9p': '未知消息',
      'k_1c3us5n': '当前群组不支持@全体成员',
      'k_11k579v': '发言中有非法语句',
      'k_003qkx2': '日历',
      'k_003n2pz': '相机',
      'k_03idjo0': '联系人',
      'k_003ltgm': '位置',
      'k_02k3k86': '麦克风',
      'k_003pm7l': '相册',
      'k_15ao57x': '相册写入',
      'k_164m3jd': '本地存储',
      'k_0qba4ns': ({required Object yoursItem}) => '想访问您的$yoursItem',
      'k_03r6qyx': '我们需要您的同意才能获取信息',
      'k_02noktt': '不允许',
      'k_00043x4': '好',
      'k_003qzac': '昨天',
      'k_003r39d': '前天',
      'k_03fqp9o': '星期天',
      'k_03ibg5h': '星期一',
      'k_03i7hu1': '星期二',
      'k_03iaiks': '星期三',
      'k_03el9pa': '星期四',
      'k_03i7ok1': '星期五',
      'k_03efxyg': '星期六',
      'k_0oozw9x': ({required Object diffMinutes}) => '$diffMinutes 分钟前',
      'k_003q7ba': '下午',
      'k_003q7bb': '上午',
      'k_003pu3h': '现在',
      'k_13hzn00': ({required Object yesterday}) => '昨天 $yesterday',
      'k_0n9pyxz': '用户不存在',
      'k_1bjwemh': '搜索用户 ID',
      'k_003kv3v': '搜索',
      'k_02owlq8': ({required Object userID}) => '我的用户ID: $userID',
      'k_1wu8h4x': ({required Object showName}) => '我是: $showName',
      'k_16758qw': '添加好友',
      'k_1shx4d9': ({required Object selfSignature}) => '个性签名: $selfSignature',
      'k_0i553x0': '填写验证信息',
      'k_031ocwx': '请填写备注和分组',
      'k_003ojje': '备注',
      'k_003lsav': '分组',
      'k_167bdvq': '我的好友',
      'k_156b4ut': '好友申请已发送',
      'k_002r305': '发送',
      'k_03gu05e': '聊天室',
      'k_03b4f3p': '会议群',
      'k_03avj1p': '公开群',
      'k_03asq2g': '工作群',
      'k_03b3hbi': '未知群',
      'k_1loix7s': ({required Object groupType}) => '群类型: $groupType',
      'k_1lqbsib': '该群聊不存在',
      'k_03h153m': '搜索群ID',
      'k_0oxak3r': '群申请已发送',
      'k_002rflt': '删除',
      'k_1don84v': '无法定位到原消息',
      'k_003q5fi': '复制',
      'k_003prq0': '转发',
      'k_002r1h2': '多选',
      'k_003j708': '引用',
      'k_003pqpr': '撤回',
      'k_03ezhho': '已复制',
      'k_11ctfsz': '暂未实现',
      'k_1hbjg5g': '[群系统消息]',
      'k_03tvswb': '[未知消息]',
      'k_155cj23': '您撤回了一条消息，',
      'k_0gapun3': '重新编辑',
      'k_1uh417q': ({required Object displayName}) => '$displayName撤回了一条消息',
      'k_1aszp2k': '您确定要重发这条消息么？',
      'k_003rzap': '确定',
      'k_003nevv': '取消',
      'k_0003z7x': '您',
      'k_002wfe4': '已读',
      'k_002wjlg': '未读',
      'k_0h1ygf8': '发起通话',
      'k_0h169j0': '取消通话',
      'k_0h13jjk': '接受通话',
      'k_0h19hfx': '拒绝通话',
      'k_0obi9lh': '超时未接听',
      'k_0y9u662': ({required Object appName}) =>
          '“$appName”暂不可以打开此类文件，你可以使用其他应用打开并预览',
      'k_001nmhu': '用其他应用打开',
      'k_1ht1b80': '正在接收中',
      'k_105682d': '图片加载失败',
      'k_0pytyeu': '图片保存成功',
      'k_0akceel': '图片保存失败',
      'k_003rk1s': '保存',
      'k_04a0awq': '[语音消息]',
      'k_105c3y3': '视频加载失败',
      'k_176rzr7': '聊天记录',
      'k_0d5z4m5': '选择提醒人',
      'k_003ngex': '完成',
      'k_1665ltg': '发起呼叫',
      'k_003n8b0': '拍摄',
      'k_003kthh': '照片',
      'k_003tnp0': '文件',
      'k_0jhdhtp': '发送失败,视频不能大于100MB',
      'k_119ucng': '图片不能为空',
      'k_0w9x8gw': ({required Object successPath}) => '选择成功$successPath',
      'k_13dsw4l': '松开取消',
      'k_0am7r68': '手指上滑，取消发送',
      'k_15jl6qw': '说话时间太短!',
      'k_0gx7vl6': '按住说话',
      'k_15dlafd': '逐条转发',
      'k_15dryxy': '合并转发',
      'k_1eyhieh': '确定删除已选消息',
      'k_17fmlyf': '清除聊天',
      'k_0dhesoz': '取消置顶',
      'k_002sk7x': '置顶',
      'k_003ll77': '草稿',
      'k_03icaxo': '自定义',
      'k_1969986': ({required Object callingLastMsgShow}) =>
          '[语音通话]：$callingLastMsgShow',
      'k_1960dlr': ({required Object callingLastMsgShow}) =>
          '[视频通话]：$callingLastMsgShow',
      'k_1np495n': ({required Object messageString}) => '$messageString[有人@我]',
      'k_1m797yi': ({required Object messageString}) => '$messageString[@所有人]',
      'k_1uaov41': '查找聊天内容',
      'k_003kfai': '未知',
      'k_13dq4an': '自动审批',
      'k_0l13cde': '管理员审批',
      'k_11y8c6a': '禁止加群',
      'k_1kvyskd': '无网络连接，无法修改',
      'k_16payqf': '加群方式',
      'k_0vzvn8r': '修改群名称',
      'k_038lh6u': '群管理',
      'k_0k5wyiy': '设置管理员',
      'k_0goiuwk': '全员禁言',
      'k_1g889xx': '全员禁言开启后，只允许群主和管理员发言。',
      'k_0wlrefq': '添加需要禁言的群成员',
      'k_0goox5g': '设置禁言',
      'k_08daijh': '成功取消管理员身份',
      'k_0bxm97s': ({required Object adminNum}) => '管理员 ($adminNum/10)',
      'k_0k5u935': '添加管理员',
      'k_03enyx5': '群成员',
      'k_0jayw3z': ({required Object groupMemberNum}) =>
          '群成员($groupMemberNum人)',
      'k_0h1svv1': '删除群成员',
      'k_0h1g636': '添加群成员',
      'k_0uj7208': '无网络连接，无法查看群成员',
      'k_01yfa4o': ({required Object memberCount}) => '$memberCount人',
      'k_0hpukyx': '查看更多群成员',
      'k_0qtsar0': '消息免打扰',
      'k_0ef2a12': '修改我的群昵称',
      'k_1aajych': '仅限中文、字母、数字和下划线，2-20个字',
      'k_137pab5': '我的群昵称',
      'k_0ivim6d': '暂无群公告',
      'k_03eq6cn': '群公告',
      'k_002vxya': '编辑',
      'k_17fpl3y': '置顶聊天',
      'k_03es1ox': '群类型',
      'k_003mz1i': '同意',
      'k_003lpre': '拒绝',
      'k_003qk66': '头像',
      'k_003lhvk': '昵称',
      'k_003ps50': '账号',
      'k_15lx52z': '个性签名',
      'k_003qgkp': '性别',
      'k_003m6hr': '生日',
      'k_0003v6a': '男',
      'k_00043x2': '女',
      'k_03bcjkv': '未设置',
      'k_11s0gdz': '修改昵称',
      'k_0p3j4sd': '仅限中字、字母、数字和下划线',
      'k_15lyvdt': '修改签名',
      'k_0vylzjp': '这个人很懒，什么也没写',
      'k_1hs7ese': '等上线再改这个',
      'k_03exjk7': '备注名',
      'k_0s3skfd': '加入黑名单',
      'k_0p3b31s': '修改备注名',
      'k_0003y9x': '无',
      'k_11zgnfs': '个人资料',
      'k_03xd79d': ({required Object signature}) => '个性签名: $signature',
      'k_1tez2xl': '暂无个性签名',
      'k_118prbn': '全局搜索',
      'k_1m9dftc': '全部联系人',
      'k_0em4gyz': '全部群聊',
      'k_002twmj': '群聊',
      'k_09kga0d': '更多聊天记录',
      'k_1ui5lzi': ({required Object count}) => '$count条相关聊天记录',
      'k_09khmso': '相关聊天记录',
      'k_1kevf4k': ({required Object receiver}) => '与$receiver的聊天记录',
      'k_0vjj2kp': '群聊的聊天记录',
      'k_003n2rp': '选择',
      'k_03ignw6': '所有人',
      'k_03erpei': '管理员',
      'k_0qi9tno': '群主、管理员',
      'k_1m9exwh': '最近联系人',
      'k_119nwqr': '输入不能为空',
      'k_0pzwbmg': '视频保存成功',
      'k_0aktupv': '视频保存失败',
      'k_1qbg9xc': ({required Object option8}) => '$option8为 ',
      'k_1wq5ubm': ({required Object option7}) => '$option7修改',
      'k_0y5pu80': ({required Object option6}) => '$option6退出群聊',
      'k_0nl7cmd': ({required Object option5}) => '邀请$option5加入群组',
      'k_1ju5iqw': ({required Object option4}) => '将$option4踢出群组',
      'k_1ovt677': ({required Object option3}) => '用户$option3加入了群聊',
      'k_0k05b8b': ({required Object option2}) => '$option2 被',
      'k_0wm4xeb': ({required Object option2}) => '系统消息 $option2',
      'k_0nbq9v3': ({required Object option2}) => '通话时间：$option2',
      'k_0i1kf53': ({required Object option2}) => '[文件] $option2',
      'k_1gnnby6': ({required Object option2}) => '想访问您的$option2',
      'k_1wh4atg': ({required Object option2}) => '$option2 分钟前',
      'k_07sh7g1': ({required Object option2}) => '昨天 $option2',
      'k_1pj8xzh': ({required Object option2}) => '我的用户ID: $option2',
      'k_0py1evo': ({required Object option2}) => '个性签名: $option2',
      'k_1kvj4i2': ({required Object option2}) => '$option2撤回了一条消息',
      'k_1v0lbpp': ({required Object option2}) =>
          '“$option2”暂不可以打开此类文件，你可以使用其他应用打开并预览',
      'k_0torwfz': ({required Object option2}) => '选择成功$option2',
      'k_0i1bjah': ({required Object option1}) => '$option1撤回了一条消息',
      'k_1qzxh9q': ({required Object option3}) => '通话时间：$option3',
      'k_0wrgmom': ({required Object option1}) => '[语音通话]：$option1',
      'k_06ix2f0': ({required Object option2}) => '[视频通话]：$option2',
      'k_08o3z5w': ({required Object option1}) => '[文件] $option1',
      'k_0ezbepg': ({required Object option2}) => '$option2[有人@我]',
      'k_1ccnht1': ({required Object option2}) => '$option2[@所有人]',
      'k_1k3arsw': ({required Object option2}) => '管理员 ($option2/10)',
      'k_1d4golg': ({required Object option1}) => '群成员($option1人)',
      'k_1bg69nt': ({required Object option1}) => '$option1人',
      'k_00gjqxj': ({required Object option1}) => '个性签名: $option1',
      'k_0c29cxr': ({required Object option1}) => '$option1条相关聊天记录',
      'k_1twk5rz': ({required Object option1}) => '与$option1的聊天记录',
      'k_1vn4xq1': ({required Object adminMember}) => '将 $adminMember 取消管理员',
      'k_0e35hsw': '为方便您将所拍摄的照片或视频发送给朋友，以及进行视频通话，请允许我们访问摄像头进行拍摄照片和视频。',
      'k_0dj6yr7': '为方便您发送语音消息、拍摄视频以及音视频通话，请允许我们使用麦克风进行录音。',
      'k_003qnsl': '存储',
      'k_0s3rtpw': '为方便您查看和选择相册里的图片视频发送给朋友，以及保存内容到设备，请允许我们访问您设备上的照片、媒体内容。',
      'k_0tezv85': ({required Object option2}) => ' 申请获取$option2',
      'k_002rety': '权限',
      'k_18o68ro': '需要授予',
      'k_1onpf8u': ' 相机权限，以正常使用拍摄图片视频、视频通话等功能。',
      'k_17irga5': ' 麦克风权限，以正常使用发送语音消息、拍摄视频、音视频通话等功能。',
      'k_0572kc4': ' 访问照片权限，以正常使用发送图片、视频等功能。',
      'k_0slykws': ' 访问相册写入权限，以正常使用存储图片、视频等功能。',
      'k_119pkcd': ' 文件读写权限，以正常使用在聊天功能中的图片查看、选择能力和发送文件的能力。',
      'k_0gqewd3': '以后再说',
      'k_03eq4s1': '去开启',
      'k_0nt2uyg': '回到最新位置',
      'k_04l16at': ({required Object option1}) => '$option1条新消息',
      'k_13p3w93': '有人@我',
      'k_18w5uk6': '@所有人',
      'k_0jmujgh': '其他文件正在接收中',
      'k_12s5ept': '消息详情',
      'k_0mxa4f4': ({required Object option1}) => '$option1人已读',
      'k_061tue3': ({required Object option2}) => '$option2人未读',
      'k_18qjstb': '转让群主',
    };
  }
}
