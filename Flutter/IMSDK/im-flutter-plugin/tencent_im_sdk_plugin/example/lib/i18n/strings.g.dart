/*
 * Generated file. Do not edit.
 *
 * Locales: 2
 * Strings: 658 (329.0 per locale)
 *
 * Built on 2022-04-02 at 08:24 UTC
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
        WidgetsBinding.instance.window.locale.toLanguageTag();
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
  String get k_0fdrjph => 'Event callback';
  String get k_15b7vxl => 'Basic module';
  String get k_1f157p5 => 'Initialize SDK';
  String get k_06n8uqh => 'Initialize SDK';
  String get k_05a3xy6 => 'Add event listener';
  String get k_1opua40 =>
      'Add an event listener before adding a login method to avoid missing messages';
  String get k_0ptv10l => 'Get server time';
  String get k_02r2v09 => 'Get server time by SDK';
  String get k_003r6vf => 'Log in';
  String get k_0z9427p => 'SDK login API. Initialize the SDK first.';
  String get k_003ph6s => 'Log out';
  String get k_1wu4tcs => 'Send C2C text message (disused since v3.6)';
  String get k_1t6awxa => 'Send C2C custom message (disused since v3.6)';
  String get k_0pwzyvl => 'Send group text message (disused since v3.6)';
  String get k_1ntp677 => 'Send group custom message (disused since v3.6)';
  String get k_1j35r5o => 'Get SDK version';
  String get k_0kt7otn => 'Get current login user';
  String get k_1v7brb7 => 'Get current login status';
  String get k_0x1tylx => 'Get user info';
  String get k_0elsjm2 => 'Create group chat';
  String get k_0elrwzy => 'Join group chat';
  String get k_0elt2dt => 'Quit group chat';
  String get k_0em2iiz => 'Delete group chat';
  String get k_0qq6zvv => 'Set personal profile';
  String get k_11deha5 => 'Experimental API';
  String get k_15a012s => 'Conversation module';
  String get k_1xdajb0 => 'Get conversation list';
  String get k_1rgdedc => 'Get conversation details';
  String get k_0glns86 => 'Delete conversation';
  String get k_0xzd96m => 'Set conversation as draft';
  String get k_0dg9tmi => 'Pin conversation to top';
  String get k_1vmox4p => 'Get conversation\'s total message unread count';
  String get k_15b6qz8 => 'Message module';
  String get k_1yns1w9 => 'Send text message';
  String get k_0zq67yj => 'Send custom message';
  String get k_1um4zaj => 'Send image message';
  String get k_0bgy5ol => 'Send video message';
  String get k_05gsxdv => 'Send file message';
  String get k_0axzzec => 'Send voice message';
  String get k_02blxws => 'Send text @ message';
  String get k_1um3h9j => 'Send geographical location message';
  String get k_1x28z5r => 'Send emoji message';
  String get k_0310ebw => 'Send combined message';
  String get k_00afgq7 => 'Send forward message';
  String get k_13sdbcu => 'Resend message';
  String get k_12w209p => 'Modify local message (string)';
  String get k_199jsqj => 'Modify local message (int)';
  String get k_0ktebqj => 'Modify cloud message (string; disused)';
  String get k_0k6jqud => 'Get C2C message history';
  String get k_0bf7otk => 'Get group message history';
  String get k_1fbo5v2 => 'Get message history (advanced API)';
  String get k_1asy1yf => 'Get message history (advanced API; unformatted)';
  String get k_13sdxko => 'Recall message';
  String get k_1vlsgoe => 'Mark C2C message as read';
  String get k_17fh8gz => 'Mark group message as read';
  String get k_16sb1e7 => 'Mark all messages as read';
  String get k_01q04pm => 'Delete local message';
  String get k_13sqfye => 'Delete message';
  String get k_1saxzrf => 'Insert local message to group chat';
  String get k_075u68x => 'Insert local message to C2C chat';
  String get k_16tukku => 'Clear local and cloud C2C message history';
  String get k_13z9nvj => 'Get user message receiving option';
  String get k_182b8ni => 'Clear local and cloud group message history';
  String get k_01qv9eo => 'Search for local messages';
  String get k_0bfyrre => 'Query local messages in a specified conversation';
  String get k_0mz8nlf => 'Friend relationship chain module';
  String get k_10ig2ml => 'Get friend list';
  String get k_0q5feak => 'Get friend info';
  String get k_16758qw => 'Add friend';
  String get k_0q5kkj1 => 'Set friend info';
  String get k_1666obb => 'Delete friend';
  String get k_167fad4 => 'Check friend';
  String get k_15gn1d5 => 'Get friend request list';
  String get k_05576s4 => 'Accept friend request';
  String get k_055cno8 => 'Reject friend request';
  String get k_0m517oy => 'Get blocklist';
  String get k_042sv53 => 'Add to blocklist';
  String get k_1oybli5 => 'Remove from blocklist';
  String get k_05jmpkg => 'Create friend list';
  String get k_05jnyuo => 'Get friend list';
  String get k_05jcbyt => 'Delete friend list';
  String get k_14xxze4 => 'Rename friend list';
  String get k_14kqmvu => 'Add friend to friend list';
  String get k_00mp87q => 'Remove friend from friend list';
  String get k_167cp0t => 'Search for friend';
  String get k_15b6vqr => 'Group module';
  String get k_1j2fn17 => 'Create group (advanced)';
  String get k_16mti73 => 'Get group joining request list';
  String get k_0suniq6 => 'Get group info';
  String get k_0supwn3 => 'Set group info';
  String get k_1ojrrgd => 'Get online group member count';
  String get k_1pb3f1z => 'Get group member list';
  String get k_1gx3i86 => 'Get group member info';
  String get k_1gwzvg7 => 'Set group member info';
  String get k_0h1ttfs => 'Mute group member';
  String get k_0c9tkhn => 'Invite friend to group';
  String get k_11yzdz7 => 'Remove member from group';
  String get k_0uupir5 => 'Set group role';
  String get k_18pxx1p => 'Transfer group owner';
  String get k_0r4h8ww => 'Search for group list';
  String get k_0h1m7ef => 'Search for group member';
  String get k_15az05y => 'Signaling module';
  String get k_0gzsnbo => 'Send invitation';
  String get k_1ifjitt => 'Send invitation in group';
  String get k_0qr6nnz => 'Get signaling info';
  String get k_0hsgjrg => 'Add invitation signaling';
  String get k_1499er2 =>
      'Add invitation signaling (triggered by group offline push messages)';
  String get k_1rmuiim => 'Offline push module';
  String get k_1uobs68 => 'Report push configuration';
  String get k_18ufun0 => 'Register event';
  String get k_0dyrkl5 => 'Deregister simpleMsgListener event';
  String get k_1q2xs9c => 'Deregister all simpleMsgListener events';
  String get k_0fyg1xs => 'Deregister advanceMsgListener event';
  String get k_0awkp15 => 'Deregister all advanceMsgListener events';
  String get k_12oryz1 => 'Deregister signalingListener event';
  String get k_1xb912c => 'Deregister all signalingListener events';
  String get k_1ec07ke => 'Friend ID';
  String get k_14bwl8c => 'Friend remarks';
  String get k_121555d => 'Friend list';
  String get k_0qbtor0 => 'Friend list, which must exist';
  String get k_0gavw6m => 'Add remarks';
  String get k_15ihgoz => 'Friend type';
  String get k_1675qge => 'Two-way friend';
  String get k_1675qk7 => 'One-way friend';
  String get k_1eopfpu => 'Select priority';
  String get k_03c51e7 => 'Not selected';
  String get k_0ethd0p =>
      'Add signaling info (select existing signaling info to test)';
  String get k_15i526p => 'Delete type';
  String get k_1ciwziu => 'Agree to add as two-way friend';
  String get k_19iuz0v => 'Agree to add as one-way friend';
  String get k_0ix65gm => 'Select friend type to agree';
  String get k_0gw88si => 'Accept request';
  String get k_0xxojzb => 'Received event callback';
  String get k_0quw2i5 => 'Select only one option';
  String get k_002r2pl => 'Single-choice';
  String get k_002r1h2 => 'Multiple-choice';
  String get k_002v9zj => 'OK';
  String get k_003nevv => 'Cancel';
  String get k_03mgr50 =>
      'Add the friend in the friend relationship chain module first';
  String get k_1ic4dp6 => 'Select friend on blocklist';
  String get k_161zzkm => 'Enter username';
  String get k_00alow4 =>
      'Call the experimental API for initializing local database (you can also call another API in the SDK)';
  String get k_1xogzdp => 'Call experimental API';
  String get k_15ijita => 'Check type';
  String get k_0y8ersu => 'Select check type';
  String get k_0iilkht =>
      'Clear local and cloud C2C message history (without deleting the conversation)';
  String get k_0szs46i => 'Get group information';
  String get k_0hqslym => 'No conversation information available';
  String get k_0gmqf8i => 'Select conversation';
  String get k_03eu3my => 'List name';
  String get k_03768rw => 'Group ID';
  String get k_1vjwjey => '(Optional) Enter a custom group ID';
  String get k_03agq58 => 'Group name';
  String get k_0kg1wsx => 'Select a group type';
  String get k_0lzvumx => 'Work';
  String get k_0mbokjw => 'Public';
  String get k_028lr1o => 'Meeting';
  String get k_1te7y0e => 'AVChatRoom';
  String get k_03avhuo => 'Create group';
  String get k_03es1ox => 'Group type';
  String get k_0wqztai => 'Group type: Work';
  String get k_0shjk7e => 'Group type: Public';
  String get k_1qrpwz6 => 'Group type: Meeting';
  String get k_0jmohdb => 'Group type: AVChatRoom';
  String get k_03f295d => 'Group notification';
  String get k_03i9mfe => 'Group introduction';
  String get k_03fchyy => 'Group profile photo';
  String get k_11msgmy => 'Select a group profile photo';
  String get k_1gyj2yl => 'Mute all members';
  String get k_0zo1d5d => 'Select group joining type';
  String get k_18epku7 => 'Create group (advanced)';
  String get k_0m7f240 => 'Remove from blocklist';
  String get k_0m3mh75 => 'Select deletion type';
  String get k_11vvszp => 'Delete group';
  String get k_1pyaxto => 'No friend request';
  String get k_0556th3 => 'Select friend request';
  String get k_121ewqv => 'Select list';
  String get k_167dvo3 => 'Select friend';
  String get k_1qdxkv0 =>
      'Query C2C message receiving option of user (Mute Notification status)';
  String get k_13v2x0e => 'Get friend list info';
  String get k_0rnrkt5 => 'Get online member count';
  String get k_0jd2nod => 'Select type';
  String get k_1mm5bjo => 'Get message history (advanced API; formatted data)';
  String get k_1b1tzii => 'Get native SDK version';
  String get k_0h1otop => 'Select group member';
  String get k_1ksi75r => 'Join the group first';
  String get k_11vv63p => 'Select group';
  String get k_03fglvp => 'Initialize';
  String get k_132xs0u => 'Send text';
  String get k_17argoi => 'Text content';
  String get k_1qjjcx0 => 'Only online users can receive messages';
  String get k_002ws2a => 'Invite';
  String get k_1bc6l5x => 'Greeting message when joining group';
  String get k_11vsj5s => 'Join group';
  String get k_0812nh1 => 'Remove member from group';
  String get k_1uz99pq => 'Mark C2C message as read';
  String get k_17fhxqb => 'Mark group message as read';
  String get k_13sbhj6 => 'Select message';
  String get k_1gw84h2 => 'Muted group member info';
  String get k_0mf7epf => 'Pin/Unpin conversation to/from top';
  String get k_11vsa3j => 'Leave group';
  String get k_0stba5l => 'Received';
  String get k_09ezm4w => 'Sent';
  String get k_0w3vj1s => 'Request type';
  String get k_16cx0kq => 'Friend request received by me';
  String get k_07d9n7u => 'Friend request sent by me';
  String get k_15ilfmd => 'Select type';
  String get k_0gw8cb2 => 'Reject request';
  String get k_15khfil => 'Original list name';
  String get k_15khfh6 => 'New list name';
  String get k_1cgc6p5 => 'Search keyword list, with up to 5 keywords';
  String get k_1csi4tv => 'Keyword (only 1 keyword is set in the example)';
  String get k_0q9wh26 => 'Search by userID';
  String get k_1p7cxk7 => 'Search by nickname';
  String get k_14mm3m5 => 'Search by remarks';
  String get k_03g1hin => 'Keyword';
  String get k_0xtvoya => 'Search by group member\'s userID';
  String get k_0musqvf => 'Search by group member\'s nickname';
  String get k_0v2tnyc => 'Search by group member\'s name card';
  String get k_0fgvqsh => 'Search by group member\'s remarks';
  String get k_0di7h2o =>
      'Search keyword (up to 5 keywords are supported; only 1 in the example)';
  String get k_139zdqj => 'Search by group ID';
  String get k_0rbflyz => 'Search by group name';
  String get k_0t9qj8k => 'Search for group';
  String get k_03rrahs => 'Keyword (required)';
  String get k_0vl6shl =>
      'Keyword (up to 5 keywords are supported; only 1 in the example)';
  String get k_1p5f8xt =>
      'Query local messages (messageList is not returned if no conversation is specified)';
  String get k_0wmcksi => 'Custom message';
  String get k_1wjd1o3 => 'Send C2C custom message (disused)';
  String get k_0qqamgs => 'Send C2C text message (disused)';
  String get k_17ix8wi => 'data';
  String get k_01cqw1f => 'desc';
  String get k_0gmtcyj => 'extension';
  String get k_03b2yxe => 'Priority';
  String get k_1wmh4z7 => 'Exclude sent messages from unread count';
  String get k_02nlunm => 'localCustomData';
  String get k_121pu0b => 'Emoji location';
  String get k_13mefja => 'Emoji info';
  String get k_1krj2k5 => 'localCustomData (file)';
  String get k_18ni1o4 => 'Select file';
  String get k_1bbh6rj => 'localCustomData (sendForwardMessage)';
  String get k_13sda1r => 'Forward message';
  String get k_08lezoy => 'Send custom message';
  String get k_05wotoe => 'Send group custom message (disused)';
  String get k_0ayxzy6 => 'Send group text message (disused)';
  String get k_0kotqjn => 'localCustomData (sendImageMessage)';
  String get k_111hdgc => 'Select image';
  String get k_060rdwo => 'Location message description';
  String get k_0lbz4k9 => 'localCustomData (sendLocationMessage)';
  String get k_1qpk5nl => 'Get current location info';
  String get k_0yn59ns => 'Conversation between XXX and XXX';
  String get k_1k1pnl2 => 'SDKs of early versions do not support text messages';
  String get k_07uflzi => 'localCustomData (sendMergerMessage)';
  String get k_13sgi0s => 'Combined message';
  String get k_09inq13 => 'localCustomData (sendSoundMessage)';
  String get k_0svi3rz => 'File deleted successfully';
  String get k_0bt4pm7 => 'Stop recording';
  String get k_0bt6ctk => 'Start recording';
  String get k_03eztxo => 'Not recorded';
  String get k_19xq0ad => 'localCustomData (sendVideoMessage)';
  String get k_0d6yawi => 'Select video';
  String get k_13qknk5 => 'Cloud data';
  String get k_0wnmtb3 => 'Modify message (string) on cloud';
  String get k_09qx4fw => 'Draft content. null means to cancel the draft.';
  String get k_1y65mf8 => 'Set draft/Cancel draft';
  String get k_1f4rg84 => 'Set conversation draft';
  String get k_02my10h => 'Group role';
  String get k_0uuoz6p => 'Select group role';
  String get k_1qe4r7d => 'Set group member role';
  String get k_0wng8yl => 'Modify local message (string)';
  String get k_1go5et7 => 'Modify local message (int)';
  String get k_15wdhxq => 'Sign-up successful';
  String get k_0yj1my7 => 'Certificate ID';
  String get k_18e393e => 'ID returned upon certificate upload in the console';
  String get k_0003v6a => 'Male';
  String get k_00043x2 => 'Female';
  String get k_0ghstt4 => 'Accept all friend requests';
  String get k_1b3mn6t => 'Reject all friend requests';
  String get k_1mo5v9d => 'Require approval for friend requests';
  String get k_003lhvk => 'Nickname';
  String get k_003q1na => 'Status';
  String get k_1hgdu7c => 'Date of birth (int)';
  String get k_003m6hr => 'Date of birth';
  String get k_003qgkp => 'Gender';
  String get k_15xu6ax => 'Select a gender';
  String get k_1pgjz7s => 'Friend request verification mode';
  String get k_0r291dl => 'Require approval for friend requests';
  String get k_003qk66 => 'Profile photo';
  String get k_161i8im => 'Select a profile photo';
  String get k_003l8z3 => 'Tip';
  String get k_142aglh =>
      'No app info is configured. Please configure it first.';
  String get k_03bd50d => 'Configure now';
  String get k_13m956w => 'Configuration info';
  String get k_1prb9on => 'sdkappid, applied for in the console';
  String get k_1fen6m9 => 'secret, applied for in the console';
  String get k_1xp25m6 => 'userID, any custom ID';
  String get k_12clf4v => 'Confirm configuration';
  String get k_0um8vqm => 'Clear all configuration';
  String get k_152jijg => 'Add field';
  String get k_0jbia4f => 'Configured fields:';
  String get k_0md2ud6 => 'The field name cannot be empty';
  String get k_05nspni => 'Custom field';
  String get k_03eyrxm => 'Field name';
  String get k_181l8gl => 'View it in the console';
  String get k_03fj93v => 'Field value';
  String get k_003rzap => 'OK';
  String get k_0f2heqk =>
      '"code=0" means success. "code!=0" means failure. You can check the error code information in the Tencent Cloud IM documentation.\n';
  String get k_1r092x8 => 'Deregister groupListener';
  String k_0socms9({required Object addType}) => 'Selected: $addType';
  String k_14awofe({required Object friendType}) => 'Selected: $friendType';
  String k_0w8a6yi({required Object chooseType}) =>
      'Select friend on blocklist ($chooseType)';
  String k_1e74ake({required Object checkType}) => 'Selected: $checkType';
  String k_1pli0aq({required Object chooseType}) =>
      'Select conversation ($chooseType)';
  String k_0itcz3b({required Object groupType}) => 'Selected: $groupType';
  String k_0o7jsdm({required Object addOpt}) => 'Selected: $addOpt';
  String k_0is52zl({required Object deleteType}) => 'Selected: $deleteType';
  String k_0q8ddw7({required Object chooseType}) =>
      'Select friend request ($chooseType)';
  String k_1pm8o4n({required Object chooseType}) => 'Select list ($chooseType)';
  String k_1pmg14j({required Object chooseType}) =>
      'Select friend ($chooseType)';
  String k_0q9n4ea({required Object userStr}) => 'User to query: $userStr';
  String k_0v51dmo({required Object filter}) => 'Selected: $filter';
  String k_1laca48({required Object type}) => 'Selected: $type';
  String k_1pm8vid({required Object chooseType}) =>
      'Select group ($chooseType)';
  String k_0xpwna0({required Object senderStr}) => 'User to query: $senderStr';
  String k_17zxeit({required Object chooseType}) => 'Selected: $chooseType';
  String k_1qkm7de({required Object priority}) => 'Selected: $priority';
  String k_16owmwk({required Object role}) => 'Selected: $role';
  String k_16vvwv0({required Object chooseAllowType}) =>
      'Selected: $chooseAllowType';
  String k_0hzbevw({required Object type}) => '$type trigger\n';
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
  String get k_0fdrjph => '事件回调';
  @override
  String get k_15b7vxl => '基础模块';
  @override
  String get k_1f157p5 => '初始化SDK';
  @override
  String get k_06n8uqh => 'sdk 初始化';
  @override
  String get k_05a3xy6 => '添加事件监听';
  @override
  String get k_1opua40 => '事件监听应先于登录方法前添加，以防漏消息';
  @override
  String get k_0ptv10l => '获取服务端时间';
  @override
  String get k_02r2v09 => 'sdk 获取服务端时间';
  @override
  String get k_003r6vf => '登录';
  @override
  String get k_0z9427p => 'sdk 登录接口，先初始化';
  @override
  String get k_003ph6s => '登出';
  @override
  String get k_1wu4tcs => '发送C2C文本消息（3.6版本已弃用）';
  @override
  String get k_1t6awxa => '发送C2C自定义消息（3.6版本已弃用）';
  @override
  String get k_0pwzyvl => '发送Group文本消息（3.6版本已弃用）';
  @override
  String get k_1ntp677 => '发送Group自定义消息（3.6版本已弃用）';
  @override
  String get k_1j35r5o => '获取 SDK 版本';
  @override
  String get k_0kt7otn => '获取当前登录用户';
  @override
  String get k_1v7brb7 => '获取当前登录状态';
  @override
  String get k_0x1tylx => '获取用户信息';
  @override
  String get k_0elsjm2 => '创建群聊';
  @override
  String get k_0elrwzy => '加入群聊';
  @override
  String get k_0elt2dt => '退出群聊';
  @override
  String get k_0em2iiz => '解散群聊';
  @override
  String get k_0qq6zvv => '设置个人信息';
  @override
  String get k_11deha5 => '试验性接口';
  @override
  String get k_15a012s => '会话模块';
  @override
  String get k_1xdajb0 => '获取会话列表';
  @override
  String get k_1rgdedc => '获取会话详情';
  @override
  String get k_0glns86 => '删除会话';
  @override
  String get k_0xzd96m => '设置会话为草稿';
  @override
  String get k_0dg9tmi => '会话置顶';
  @override
  String get k_1vmox4p => '获取会话未读总数';
  @override
  String get k_15b6qz8 => '消息模块';
  @override
  String get k_1yns1w9 => '发送文本消息';
  @override
  String get k_0zq67yj => '发送自定义消息';
  @override
  String get k_1um4zaj => '发送图片消息';
  @override
  String get k_0bgy5ol => '发送视频消息';
  @override
  String get k_05gsxdv => '发送文件消息';
  @override
  String get k_0axzzec => '发送录音消息';
  @override
  String get k_02blxws => '发送文本At消息';
  @override
  String get k_1um3h9j => '发送地理位置消息';
  @override
  String get k_1x28z5r => '发送表情消息';
  @override
  String get k_0310ebw => '发送合并消息';
  @override
  String get k_00afgq7 => '发送转发消息';
  @override
  String get k_13sdbcu => '重发消息';
  @override
  String get k_12w209p => '修改本地消息（String）';
  @override
  String get k_199jsqj => '修改本地消息（Int）';
  @override
  String get k_0ktebqj => '修改云端消息（String-已弃用）';
  @override
  String get k_0k6jqud => '获取C2C历史消息';
  @override
  String get k_0bf7otk => '获取Group历史消息';
  @override
  String get k_1fbo5v2 => '获取历史消息高级接口';
  @override
  String get k_1asy1yf => '获取历史消息高级接口（不格式化）';
  @override
  String get k_13sdxko => '撤回消息';
  @override
  String get k_1vlsgoe => '标记C2C会话已读';
  @override
  String get k_17fh8gz => '标记Group会话已读';
  @override
  String get k_16sb1e7 => '标记所有消息为已读';
  @override
  String get k_01q04pm => '删除本地消息';
  @override
  String get k_13sqfye => '删除消息';
  @override
  String get k_1saxzrf => '向group中插入一条本地消息';
  @override
  String get k_075u68x => '向c2c会话中插入一条本地消息';
  @override
  String get k_16tukku => '清空单聊本地及云端的消息';
  @override
  String get k_13z9nvj => '获取用户消息接收选项';
  @override
  String get k_182b8ni => '清空群组单聊本地及云端的消息';
  @override
  String get k_01qv9eo => '搜索本地消息';
  @override
  String get k_0bfyrre => '查询指定会话中的本地消息';
  @override
  String get k_0mz8nlf => '好友关系链模块';
  @override
  String get k_10ig2ml => '获取好友列表';
  @override
  String get k_0q5feak => '获取好友信息';
  @override
  String get k_16758qw => '添加好友';
  @override
  String get k_0q5kkj1 => '设置好友信息';
  @override
  String get k_1666obb => '删除好友';
  @override
  String get k_167fad4 => '检测好友';
  @override
  String get k_15gn1d5 => '获取好友申请列表';
  @override
  String get k_05576s4 => '同意好友申请';
  @override
  String get k_055cno8 => '拒绝好友申请';
  @override
  String get k_0m517oy => '获取黑名单列表';
  @override
  String get k_042sv53 => '添加到黑名单';
  @override
  String get k_1oybli5 => '从黑名单移除';
  @override
  String get k_05jmpkg => '创建好友分组';
  @override
  String get k_05jnyuo => '获取好友分组';
  @override
  String get k_05jcbyt => '删除好友分组';
  @override
  String get k_14xxze4 => '重命名好友分组';
  @override
  String get k_14kqmvu => '添加好友到分组';
  @override
  String get k_00mp87q => '从分组中删除好友';
  @override
  String get k_167cp0t => '搜索好友';
  @override
  String get k_15b6vqr => '群组模块';
  @override
  String get k_1j2fn17 => '高级创建群组';
  @override
  String get k_16mti73 => '获取加群列表';
  @override
  String get k_0suniq6 => '获取群信息';
  @override
  String get k_0supwn3 => '设置群信息';
  @override
  String get k_1ojrrgd => '获取群在线人数';
  @override
  String get k_1pb3f1z => '获取群成员列表';
  @override
  String get k_1gx3i86 => '获取群成员信息';
  @override
  String get k_1gwzvg7 => '设置群成员信息';
  @override
  String get k_0h1ttfs => '禁言群成员';
  @override
  String get k_0c9tkhn => '邀请好友进群';
  @override
  String get k_11yzdz7 => '踢人出群';
  @override
  String get k_0uupir5 => '设置群角色';
  @override
  String get k_18pxx1p => '转移群主';
  @override
  String get k_0r4h8ww => '搜索群列表';
  @override
  String get k_0h1m7ef => '搜索群成员';
  @override
  String get k_15az05y => '信令模块';
  @override
  String get k_0gzsnbo => '发起邀请';
  @override
  String get k_1ifjitt => '在群组中发起邀请';
  @override
  String get k_0qr6nnz => '获取信令信息';
  @override
  String get k_0hsgjrg => '添加邀请信令';
  @override
  String get k_1499er2 => '添加邀请信令（可以用于群离线推送消息触发的邀请信令）';
  @override
  String get k_1rmuiim => '离线推送模块';
  @override
  String get k_1uobs68 => '上报推送配置';
  @override
  String get k_18ufun0 => '注册事件';
  @override
  String get k_0dyrkl5 => '注销simpleMsgListener事件';
  @override
  String get k_1q2xs9c => '注销所有simpleMsgListener事件';
  @override
  String get k_0fyg1xs => '注销advanceMsgListener';
  @override
  String get k_0awkp15 => '注销所有advanceMsgListener';
  @override
  String get k_12oryz1 => '注销signalingListener';
  @override
  String get k_1xb912c => '注销所有signalingListener';
  @override
  String get k_1r092x8 => '注销gruopListener';
  @override
  String get k_1ec07ke => '被添加好友ID';
  @override
  String get k_14bwl8c => '好友备注';
  @override
  String get k_121555d => '好友分组';
  @override
  String get k_0qbtor0 => '好友分组，首先得有这个分组';
  @override
  String get k_0gavw6m => '添加简述';
  @override
  String get k_15ihgoz => '好友类型';
  @override
  String get k_1675qge => '双向好友';
  @override
  String get k_1675qk7 => '单向好友';
  @override
  String get k_1eopfpu => '选择优先级';
  @override
  String k_0socms9({required Object addType}) => '已选：$addType';
  @override
  String get k_03c51e7 => '未选择';
  @override
  String get k_0ethd0p => '添加信令信息（选择已有的信令信息进行测试）';
  @override
  String get k_15i526p => '删除类型';
  @override
  String get k_1ciwziu => '同意添加双向好友';
  @override
  String get k_19iuz0v => '同意添加单向好友';
  @override
  String get k_0ix65gm => '选择同意类型类型';
  @override
  String k_14awofe({required Object friendType}) => '已选：$friendType';
  @override
  String get k_0gw88si => '同意申请';
  @override
  String get k_0xxojzb => '收到的事件回调';
  @override
  String get k_0quw2i5 => '单选只能选一个呀';
  @override
  String get k_002r2pl => '单选';
  @override
  String get k_002r1h2 => '多选';
  @override
  String k_0w8a6yi({required Object chooseType}) => '黑名单好友选择（$chooseType）';
  @override
  String get k_002v9zj => '确认';
  @override
  String get k_003nevv => '取消';
  @override
  String get k_03mgr50 => '请先在好友关系链模块中添加好友';
  @override
  String get k_1ic4dp6 => '选择黑名单好友';
  @override
  String get k_161zzkm => '请输入用户名';
  @override
  String get k_00alow4 => '调用实验性接口：初始化本地数据库（您可以在SDK中自行尝试其他接口）';
  @override
  String get k_1xogzdp => '调用实验性接口';
  @override
  String get k_15ijita => '检测类型';
  @override
  String get k_0y8ersu => '选择检测类型';
  @override
  String k_1e74ake({required Object checkType}) => '已选：$checkType';
  @override
  String get k_0iilkht => '清空单聊本地及云端的消息（不删除会话）';
  @override
  String get k_0szs46i => '获取群组信息';
  @override
  String k_1pli0aq({required Object chooseType}) => '会话选择（$chooseType）';
  @override
  String get k_0hqslym => '暂无会话信息';
  @override
  String get k_0gmqf8i => '选择会话';
  @override
  String get k_03eu3my => '分组名';
  @override
  String get k_03768rw => '群ID';
  @override
  String get k_1vjwjey => '选填（如填，则自定义群ID）';
  @override
  String get k_03agq58 => '群名称';
  @override
  String get k_0kg1wsx => '选择群类型';
  @override
  String get k_0lzvumx => 'Work 工作群';
  @override
  String get k_0mbokjw => 'Public 公开群';
  @override
  String get k_028lr1o => 'Meeting 会议群';
  @override
  String get k_1te7y0e => 'AVChatRoom 直播群';
  @override
  String k_0itcz3b({required Object groupType}) => '已选：$groupType';
  @override
  String get k_03avhuo => '创建群';
  @override
  String get k_03es1ox => '群类型';
  @override
  String get k_0wqztai => '群类型：Work';
  @override
  String get k_0shjk7e => '群类型：Public';
  @override
  String get k_1qrpwz6 => '群类型：Meeting';
  @override
  String get k_0jmohdb => '群类型r：AVChatRoom';
  @override
  String get k_03f295d => '群通告';
  @override
  String get k_03i9mfe => '群简介';
  @override
  String get k_03fchyy => '群头像';
  @override
  String get k_11msgmy => '选择群头像';
  @override
  String get k_1gyj2yl => '是否全员禁言';
  @override
  String get k_0zo1d5d => '选择加群类型';
  @override
  String k_0o7jsdm({required Object addOpt}) => '已选：$addOpt';
  @override
  String get k_18epku7 => '高级创建群';
  @override
  String get k_0m7f240 => '从黑名单中移除';
  @override
  String get k_0m3mh75 => '选择删除类型';
  @override
  String k_0is52zl({required Object deleteType}) => '已选：$deleteType';
  @override
  String get k_11vvszp => '解散群组';
  @override
  String k_0q8ddw7({required Object chooseType}) => '好友申请选择（$chooseType）';
  @override
  String get k_1pyaxto => '目前没有好友申请';
  @override
  String get k_0556th3 => '选择好友申请';
  @override
  String k_1pm8o4n({required Object chooseType}) => '分组选择（$chooseType）';
  @override
  String get k_121ewqv => '选择分组';
  @override
  String k_1pmg14j({required Object chooseType}) => '好友选择（$chooseType）';
  @override
  String get k_167dvo3 => '选择好友';
  @override
  String k_0q9n4ea({required Object userStr}) => '要查询的用户: $userStr';
  @override
  String get k_1qdxkv0 => '查询针对某个用户的 C2C 消息接收选项（免打扰状态）';
  @override
  String get k_13v2x0e => '获取好友分组信息';
  @override
  String k_0v51dmo({required Object filter}) => '已选：$filter';
  @override
  String get k_0rnrkt5 => '获取在线人数';
  @override
  String get k_0jd2nod => '选择type';
  @override
  String k_1laca48({required Object type}) => '已选：$type';
  @override
  String get k_1mm5bjo => '获取历史消息高级接口（格式化数据）';
  @override
  String get k_1b1tzii => '获取native sdk版本号';
  @override
  String get k_0h1otop => '选择群成员';
  @override
  String k_1pm8vid({required Object chooseType}) => '群组选择（$chooseType）';
  @override
  String get k_1ksi75r => '请先加入群组';
  @override
  String get k_11vv63p => '选择群组';
  @override
  String get k_03fglvp => '初始化';
  @override
  String k_0xpwna0({required Object senderStr}) => '要查询的用户: $senderStr';
  @override
  String get k_132xs0u => '发送文本';
  @override
  String get k_17argoi => '文本内容';
  @override
  String get k_1qjjcx0 => '是否仅在线用户接受到消息';
  @override
  String get k_002ws2a => '邀请';
  @override
  String get k_1bc6l5x => '进群打招呼Message';
  @override
  String get k_11vsj5s => '加入群组';
  @override
  String get k_0812nh1 => '踢群成员出群';
  @override
  String get k_1uz99pq => '标记c2c会话已读';
  @override
  String get k_17fhxqb => '标记group会话已读';
  @override
  String get k_13sbhj6 => '选择消息';
  @override
  String get k_1gw84h2 => '禁言群成员信息';
  @override
  String get k_0mf7epf => '会话置顶/取消置顶';
  @override
  String get k_11vsa3j => '退出群组';
  @override
  String get k_0stba5l => '别人发给我的';
  @override
  String get k_09ezm4w => '我发别人的';
  @override
  String get k_0w3vj1s => '请求类型类型';
  @override
  String get k_16cx0kq => '别人发给我的加好友请求';
  @override
  String get k_07d9n7u => '我发给别人的加好友请求';
  @override
  String get k_15ilfmd => '选择类型';
  @override
  String k_17zxeit({required Object chooseType}) => '已选：$chooseType';
  @override
  String get k_0gw8cb2 => '拒绝申请';
  @override
  String get k_15khfil => '旧分组名';
  @override
  String get k_15khfh6 => '新分组名';
  @override
  String get k_1cgc6p5 => '搜索关键字列表，最多支持5个';
  @override
  String get k_1csi4tv => '关键字(example只有设置了一个关键字)';
  @override
  String get k_0q9wh26 => '设置是否搜索userID';
  @override
  String get k_1p7cxk7 => '是否设置搜索昵称';
  @override
  String get k_14mm3m5 => '设置是否搜索备注';
  @override
  String get k_03g1hin => '关键字';
  @override
  String get k_0xtvoya => '设置是否搜索群成员 userID';
  @override
  String get k_0musqvf => '设置是否搜索群成员昵称';
  @override
  String get k_0v2tnyc => '设置是否搜索群成员名片';
  @override
  String get k_0fgvqsh => '设置是否搜索群成员备注';
  @override
  String get k_0di7h2o => '搜索关键字(最多支持五个，example只支持一个)';
  @override
  String get k_139zdqj => '设置是否搜索群 ID';
  @override
  String get k_0rbflyz => '设置是否搜索群名称';
  @override
  String get k_0t9qj8k => '搜索Group';
  @override
  String get k_03rrahs => '关键字(必填)';
  @override
  String get k_0vl6shl => '关键字（接口支持5个，example支持一个）';
  @override
  String get k_1p5f8xt => '查询本地消息(不指定会话不返回messageList)';
  @override
  String get k_0wmcksi => '自定义数据';
  @override
  String get k_1wjd1o3 => '发送C2C自定义消息（弃用）';
  @override
  String get k_0qqamgs => '发送C2C文本消息（已经弃用）';
  @override
  String get k_17ix8wi => '自定义数据data';
  @override
  String get k_01cqw1f => '自定义数据desc';
  @override
  String get k_0gmtcyj => '自定义数据extension';
  @override
  String get k_03b2yxe => '优先级';
  @override
  String k_1qkm7de({required Object priority}) => '已选：$priority';
  @override
  String get k_1wmh4z7 => '发送消息是否不计入未读数';
  @override
  String get k_02nlunm => '自定义localCustomData';
  @override
  String get k_121pu0b => '表情位置';
  @override
  String get k_13mefja => '表情信息';
  @override
  String get k_1krj2k5 => '自定义localCustomData(File)';
  @override
  String get k_18ni1o4 => '选择文件';
  @override
  String get k_1bbh6rj => '自定义localCustomData(sendForwardMessage)';
  @override
  String get k_13sda1r => '转发消息';
  @override
  String get k_08lezoy => '发送自定义数据';
  @override
  String get k_05wotoe => '发送Group自定义消息(弃用)';
  @override
  String get k_0ayxzy6 => '发送Group文本消息（已弃用）';
  @override
  String get k_0kotqjn => '自定义localCustomData(sendImageMessage)';
  @override
  String get k_111hdgc => '选择图片';
  @override
  String get k_060rdwo => '地理位置消息描述';
  @override
  String get k_0lbz4k9 => '自定义localCustomData(sendLocationMessage)';
  @override
  String get k_1qpk5nl => '获取当前地理位置信息';
  @override
  String get k_0yn59ns => 'XXX与XXX的会话';
  @override
  String get k_1k1pnl2 => '低版本不支持会会收到文本消息';
  @override
  String get k_07uflzi => '自定义localCustomData(sendMergerMessage)';
  @override
  String get k_13sgi0s => '合并消息';
  @override
  String get k_09inq13 => '自定义localCustomData(sendSoundMessage)';
  @override
  String get k_0svi3rz => '删除文件成功';
  @override
  String get k_0bt4pm7 => '结束录音';
  @override
  String get k_0bt6ctk => '开始录音';
  @override
  String get k_03eztxo => '未录制';
  @override
  String get k_19xq0ad => '自定义localCustomData(sendVideoMessage)';
  @override
  String get k_0d6yawi => '选择视频';
  @override
  String get k_13qknk5 => '云端数据';
  @override
  String get k_0wnmtb3 => '云端修改消息（String）';
  @override
  String get k_09qx4fw => '草稿内容，null为取消';
  @override
  String get k_1y65mf8 => '设置草稿/取消草稿';
  @override
  String get k_1f4rg84 => '设置会话草稿';
  @override
  String get k_02my10h => '群角色';
  @override
  String get k_0uuoz6p => '选择群角色';
  @override
  String k_16owmwk({required Object role}) => '已选：$role';
  @override
  String get k_1qe4r7d => '设置群成员角色';
  @override
  String get k_0wng8yl => '本地修改消息（String）';
  @override
  String get k_1go5et7 => '本地修改消息（Int）';
  @override
  String get k_15wdhxq => '注册成功';
  @override
  String get k_0yj1my7 => '证书id';
  @override
  String get k_18e393e => '控制台上传证书返回的id';
  @override
  String get k_0003v6a => '男';
  @override
  String get k_00043x2 => '女';
  @override
  String get k_0ghstt4 => '允许所有人加我好友';
  @override
  String get k_1b3mn6t => '不允许所有人加我好友';
  @override
  String get k_1mo5v9d => '加我好友许我确认';
  @override
  String get k_003lhvk => '昵称';
  @override
  String get k_003q1na => '签名';
  @override
  String get k_1hgdu7c => '生日(int类型，不要输入字符串)';
  @override
  String get k_003m6hr => '生日';
  @override
  String get k_003qgkp => '性别';
  @override
  String get k_15xu6ax => '选择性别';
  @override
  String get k_1pgjz7s => '加好友验证方式';
  @override
  String get k_0r291dl => '加我好友需我确认';
  @override
  String k_16vvwv0({required Object chooseAllowType}) => '已选：$chooseAllowType';
  @override
  String get k_003qk66 => '头像';
  @override
  String get k_161i8im => '选择头像';
  @override
  String get k_003l8z3 => '提示';
  @override
  String get k_142aglh => '检测到您还未配置应用信息，请先配置';
  @override
  String get k_03bd50d => '去配置';
  @override
  String get k_13m956w => '配置信息';
  @override
  String get k_1prb9on => 'sdkappid，控制台去申请';
  @override
  String get k_1fen6m9 => 'secret，控制台去申请';
  @override
  String get k_1xp25m6 => 'userID，随便填';
  @override
  String get k_12clf4v => '确认设置';
  @override
  String get k_0um8vqm => '清除所有配置';
  @override
  String get k_152jijg => '添加字段';
  @override
  String get k_0jbia4f => '已设置字段：';
  @override
  String get k_0md2ud6 => '字段名不能为空';
  @override
  String get k_05nspni => '自定义字段';
  @override
  String get k_03eyrxm => '字段名';
  @override
  String get k_181l8gl => '请在控制台查看';
  @override
  String get k_03fj93v => '字段值';
  @override
  String get k_003rzap => '确定';
  @override
  String get k_0f2heqk => 'code=0 业务成功 code!=0 业务失败，请在腾讯云即时通信文档文档查看对应的错误码信息。\n';
  @override
  String k_0hzbevw({required Object type}) => '$type触发\n';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
  Map<String, dynamic> _buildFlatMap() {
    return {
      'k_0fdrjph': 'Event callback',
      'k_15b7vxl': 'Basic module',
      'k_1f157p5': 'Initialize SDK',
      'k_06n8uqh': 'Initialize SDK',
      'k_05a3xy6': 'Add event listener',
      'k_1opua40':
          'Add an event listener before adding a login method to avoid missing messages',
      'k_0ptv10l': 'Get server time',
      'k_02r2v09': 'Get server time by SDK',
      'k_003r6vf': 'Log in',
      'k_0z9427p': 'SDK login API. Initialize the SDK first.',
      'k_003ph6s': 'Log out',
      'k_1wu4tcs': 'Send C2C text message (disused since v3.6)',
      'k_1t6awxa': 'Send C2C custom message (disused since v3.6)',
      'k_0pwzyvl': 'Send group text message (disused since v3.6)',
      'k_1ntp677': 'Send group custom message (disused since v3.6)',
      'k_1j35r5o': 'Get SDK version',
      'k_0kt7otn': 'Get current login user',
      'k_1v7brb7': 'Get current login status',
      'k_0x1tylx': 'Get user info',
      'k_0elsjm2': 'Create group chat',
      'k_0elrwzy': 'Join group chat',
      'k_0elt2dt': 'Quit group chat',
      'k_0em2iiz': 'Delete group chat',
      'k_0qq6zvv': 'Set personal profile',
      'k_11deha5': 'Experimental API',
      'k_15a012s': 'Conversation module',
      'k_1xdajb0': 'Get conversation list',
      'k_1rgdedc': 'Get conversation details',
      'k_0glns86': 'Delete conversation',
      'k_0xzd96m': 'Set conversation as draft',
      'k_0dg9tmi': 'Pin conversation to top',
      'k_1vmox4p': 'Get conversation\'s total message unread count',
      'k_15b6qz8': 'Message module',
      'k_1yns1w9': 'Send text message',
      'k_0zq67yj': 'Send custom message',
      'k_1um4zaj': 'Send image message',
      'k_0bgy5ol': 'Send video message',
      'k_05gsxdv': 'Send file message',
      'k_0axzzec': 'Send voice message',
      'k_02blxws': 'Send text @ message',
      'k_1um3h9j': 'Send geographical location message',
      'k_1x28z5r': 'Send emoji message',
      'k_0310ebw': 'Send combined message',
      'k_00afgq7': 'Send forward message',
      'k_13sdbcu': 'Resend message',
      'k_12w209p': 'Modify local message (string)',
      'k_199jsqj': 'Modify local message (int)',
      'k_0ktebqj': 'Modify cloud message (string; disused)',
      'k_0k6jqud': 'Get C2C message history',
      'k_0bf7otk': 'Get group message history',
      'k_1fbo5v2': 'Get message history (advanced API)',
      'k_1asy1yf': 'Get message history (advanced API; unformatted)',
      'k_13sdxko': 'Recall message',
      'k_1vlsgoe': 'Mark C2C message as read',
      'k_17fh8gz': 'Mark group message as read',
      'k_16sb1e7': 'Mark all messages as read',
      'k_01q04pm': 'Delete local message',
      'k_13sqfye': 'Delete message',
      'k_1saxzrf': 'Insert local message to group chat',
      'k_075u68x': 'Insert local message to C2C chat',
      'k_16tukku': 'Clear local and cloud C2C message history',
      'k_13z9nvj': 'Get user message receiving option',
      'k_182b8ni': 'Clear local and cloud group message history',
      'k_01qv9eo': 'Search for local messages',
      'k_0bfyrre': 'Query local messages in a specified conversation',
      'k_0mz8nlf': 'Friend relationship chain module',
      'k_10ig2ml': 'Get friend list',
      'k_0q5feak': 'Get friend info',
      'k_16758qw': 'Add friend',
      'k_0q5kkj1': 'Set friend info',
      'k_1666obb': 'Delete friend',
      'k_167fad4': 'Check friend',
      'k_15gn1d5': 'Get friend request list',
      'k_05576s4': 'Accept friend request',
      'k_055cno8': 'Reject friend request',
      'k_0m517oy': 'Get blocklist',
      'k_042sv53': 'Add to blocklist',
      'k_1oybli5': 'Remove from blocklist',
      'k_05jmpkg': 'Create friend list',
      'k_05jnyuo': 'Get friend list',
      'k_05jcbyt': 'Delete friend list',
      'k_14xxze4': 'Rename friend list',
      'k_14kqmvu': 'Add friend to friend list',
      'k_00mp87q': 'Remove friend from friend list',
      'k_167cp0t': 'Search for friend',
      'k_15b6vqr': 'Group module',
      'k_1j2fn17': 'Create group (advanced)',
      'k_16mti73': 'Get group joining request list',
      'k_0suniq6': 'Get group info',
      'k_0supwn3': 'Set group info',
      'k_1ojrrgd': 'Get online group member count',
      'k_1pb3f1z': 'Get group member list',
      'k_1gx3i86': 'Get group member info',
      'k_1gwzvg7': 'Set group member info',
      'k_0h1ttfs': 'Mute group member',
      'k_0c9tkhn': 'Invite friend to group',
      'k_11yzdz7': 'Remove member from group',
      'k_0uupir5': 'Set group role',
      'k_18pxx1p': 'Transfer group owner',
      'k_0r4h8ww': 'Search for group list',
      'k_0h1m7ef': 'Search for group member',
      'k_15az05y': 'Signaling module',
      'k_0gzsnbo': 'Send invitation',
      'k_1ifjitt': 'Send invitation in group',
      'k_0qr6nnz': 'Get signaling info',
      'k_0hsgjrg': 'Add invitation signaling',
      'k_1499er2':
          'Add invitation signaling (triggered by group offline push messages)',
      'k_1rmuiim': 'Offline push module',
      'k_1uobs68': 'Report push configuration',
      'k_18ufun0': 'Register event',
      'k_0dyrkl5': 'Deregister simpleMsgListener event',
      'k_1q2xs9c': 'Deregister all simpleMsgListener events',
      'k_0fyg1xs': 'Deregister advanceMsgListener event',
      'k_0awkp15': 'Deregister all advanceMsgListener events',
      'k_12oryz1': 'Deregister signalingListener event',
      'k_1xb912c': 'Deregister all signalingListener events',
      'k_1ec07ke': 'Friend ID',
      'k_14bwl8c': 'Friend remarks',
      'k_121555d': 'Friend list',
      'k_0qbtor0': 'Friend list, which must exist',
      'k_0gavw6m': 'Add remarks',
      'k_15ihgoz': 'Friend type',
      'k_1675qge': 'Two-way friend',
      'k_1675qk7': 'One-way friend',
      'k_1eopfpu': 'Select priority',
      'k_03c51e7': 'Not selected',
      'k_0ethd0p':
          'Add signaling info (select existing signaling info to test)',
      'k_15i526p': 'Delete type',
      'k_1ciwziu': 'Agree to add as two-way friend',
      'k_19iuz0v': 'Agree to add as one-way friend',
      'k_0ix65gm': 'Select friend type to agree',
      'k_0gw88si': 'Accept request',
      'k_0xxojzb': 'Received event callback',
      'k_0quw2i5': 'Select only one option',
      'k_002r2pl': 'Single-choice',
      'k_002r1h2': 'Multiple-choice',
      'k_002v9zj': 'OK',
      'k_003nevv': 'Cancel',
      'k_03mgr50':
          'Add the friend in the friend relationship chain module first',
      'k_1ic4dp6': 'Select friend on blocklist',
      'k_161zzkm': 'Enter username',
      'k_00alow4':
          'Call the experimental API for initializing local database (you can also call another API in the SDK)',
      'k_1xogzdp': 'Call experimental API',
      'k_15ijita': 'Check type',
      'k_0y8ersu': 'Select check type',
      'k_0iilkht':
          'Clear local and cloud C2C message history (without deleting the conversation)',
      'k_0szs46i': 'Get group information',
      'k_0hqslym': 'No conversation information available',
      'k_0gmqf8i': 'Select conversation',
      'k_03eu3my': 'List name',
      'k_03768rw': 'Group ID',
      'k_1vjwjey': '(Optional) Enter a custom group ID',
      'k_03agq58': 'Group name',
      'k_0kg1wsx': 'Select a group type',
      'k_0lzvumx': 'Work',
      'k_0mbokjw': 'Public',
      'k_028lr1o': 'Meeting',
      'k_1te7y0e': 'AVChatRoom',
      'k_03avhuo': 'Create group',
      'k_03es1ox': 'Group type',
      'k_0wqztai': 'Group type: Work',
      'k_0shjk7e': 'Group type: Public',
      'k_1qrpwz6': 'Group type: Meeting',
      'k_0jmohdb': 'Group type: AVChatRoom',
      'k_03f295d': 'Group notification',
      'k_03i9mfe': 'Group introduction',
      'k_03fchyy': 'Group profile photo',
      'k_11msgmy': 'Select a group profile photo',
      'k_1gyj2yl': 'Mute all members',
      'k_0zo1d5d': 'Select group joining type',
      'k_18epku7': 'Create group (advanced)',
      'k_0m7f240': 'Remove from blocklist',
      'k_0m3mh75': 'Select deletion type',
      'k_11vvszp': 'Delete group',
      'k_1pyaxto': 'No friend request',
      'k_0556th3': 'Select friend request',
      'k_121ewqv': 'Select list',
      'k_167dvo3': 'Select friend',
      'k_1qdxkv0':
          'Query C2C message receiving option of user (Mute Notification status)',
      'k_13v2x0e': 'Get friend list info',
      'k_0rnrkt5': 'Get online member count',
      'k_0jd2nod': 'Select type',
      'k_1mm5bjo': 'Get message history (advanced API; formatted data)',
      'k_1b1tzii': 'Get native SDK version',
      'k_0h1otop': 'Select group member',
      'k_1ksi75r': 'Join the group first',
      'k_11vv63p': 'Select group',
      'k_03fglvp': 'Initialize',
      'k_132xs0u': 'Send text',
      'k_17argoi': 'Text content',
      'k_1qjjcx0': 'Only online users can receive messages',
      'k_002ws2a': 'Invite',
      'k_1bc6l5x': 'Greeting message when joining group',
      'k_11vsj5s': 'Join group',
      'k_0812nh1': 'Remove member from group',
      'k_1uz99pq': 'Mark C2C message as read',
      'k_17fhxqb': 'Mark group message as read',
      'k_13sbhj6': 'Select message',
      'k_1gw84h2': 'Muted group member info',
      'k_0mf7epf': 'Pin/Unpin conversation to/from top',
      'k_11vsa3j': 'Leave group',
      'k_0stba5l': 'Received',
      'k_09ezm4w': 'Sent',
      'k_0w3vj1s': 'Request type',
      'k_16cx0kq': 'Friend request received by me',
      'k_07d9n7u': 'Friend request sent by me',
      'k_15ilfmd': 'Select type',
      'k_0gw8cb2': 'Reject request',
      'k_15khfil': 'Original list name',
      'k_15khfh6': 'New list name',
      'k_1cgc6p5': 'Search keyword list, with up to 5 keywords',
      'k_1csi4tv': 'Keyword (only 1 keyword is set in the example)',
      'k_0q9wh26': 'Search by userID',
      'k_1p7cxk7': 'Search by nickname',
      'k_14mm3m5': 'Search by remarks',
      'k_03g1hin': 'Keyword',
      'k_0xtvoya': 'Search by group member\'s userID',
      'k_0musqvf': 'Search by group member\'s nickname',
      'k_0v2tnyc': 'Search by group member\'s name card',
      'k_0fgvqsh': 'Search by group member\'s remarks',
      'k_0di7h2o':
          'Search keyword (up to 5 keywords are supported; only 1 in the example)',
      'k_139zdqj': 'Search by group ID',
      'k_0rbflyz': 'Search by group name',
      'k_0t9qj8k': 'Search for group',
      'k_03rrahs': 'Keyword (required)',
      'k_0vl6shl':
          'Keyword (up to 5 keywords are supported; only 1 in the example)',
      'k_1p5f8xt':
          'Query local messages (messageList is not returned if no conversation is specified)',
      'k_0wmcksi': 'Custom message',
      'k_1wjd1o3': 'Send C2C custom message (disused)',
      'k_0qqamgs': 'Send C2C text message (disused)',
      'k_17ix8wi': 'data',
      'k_01cqw1f': 'desc',
      'k_0gmtcyj': 'extension',
      'k_03b2yxe': 'Priority',
      'k_1wmh4z7': 'Exclude sent messages from unread count',
      'k_02nlunm': 'localCustomData',
      'k_121pu0b': 'Emoji location',
      'k_13mefja': 'Emoji info',
      'k_1krj2k5': 'localCustomData (file)',
      'k_18ni1o4': 'Select file',
      'k_1bbh6rj': 'localCustomData (sendForwardMessage)',
      'k_13sda1r': 'Forward message',
      'k_08lezoy': 'Send custom message',
      'k_05wotoe': 'Send group custom message (disused)',
      'k_0ayxzy6': 'Send group text message (disused)',
      'k_0kotqjn': 'localCustomData (sendImageMessage)',
      'k_111hdgc': 'Select image',
      'k_060rdwo': 'Location message description',
      'k_0lbz4k9': 'localCustomData (sendLocationMessage)',
      'k_1qpk5nl': 'Get current location info',
      'k_0yn59ns': 'Conversation between XXX and XXX',
      'k_1k1pnl2': 'SDKs of early versions do not support text messages',
      'k_07uflzi': 'localCustomData (sendMergerMessage)',
      'k_13sgi0s': 'Combined message',
      'k_09inq13': 'localCustomData (sendSoundMessage)',
      'k_0svi3rz': 'File deleted successfully',
      'k_0bt4pm7': 'Stop recording',
      'k_0bt6ctk': 'Start recording',
      'k_03eztxo': 'Not recorded',
      'k_19xq0ad': 'localCustomData (sendVideoMessage)',
      'k_0d6yawi': 'Select video',
      'k_13qknk5': 'Cloud data',
      'k_0wnmtb3': 'Modify message (string) on cloud',
      'k_09qx4fw': 'Draft content. null means to cancel the draft.',
      'k_1y65mf8': 'Set draft/Cancel draft',
      'k_1f4rg84': 'Set conversation draft',
      'k_02my10h': 'Group role',
      'k_0uuoz6p': 'Select group role',
      'k_1qe4r7d': 'Set group member role',
      'k_0wng8yl': 'Modify local message (string)',
      'k_1go5et7': 'Modify local message (int)',
      'k_15wdhxq': 'Sign-up successful',
      'k_0yj1my7': 'Certificate ID',
      'k_18e393e': 'ID returned upon certificate upload in the console',
      'k_0003v6a': 'Male',
      'k_00043x2': 'Female',
      'k_0ghstt4': 'Accept all friend requests',
      'k_1b3mn6t': 'Reject all friend requests',
      'k_1mo5v9d': 'Require approval for friend requests',
      'k_003lhvk': 'Nickname',
      'k_003q1na': 'Status',
      'k_1hgdu7c': 'Date of birth (int)',
      'k_003m6hr': 'Date of birth',
      'k_003qgkp': 'Gender',
      'k_15xu6ax': 'Select a gender',
      'k_1pgjz7s': 'Friend request verification mode',
      'k_0r291dl': 'Require approval for friend requests',
      'k_003qk66': 'Profile photo',
      'k_161i8im': 'Select a profile photo',
      'k_003l8z3': 'Tip',
      'k_142aglh': 'No app info is configured. Please configure it first.',
      'k_03bd50d': 'Configure now',
      'k_13m956w': 'Configuration info',
      'k_1prb9on': 'sdkappid, applied for in the console',
      'k_1fen6m9': 'secret, applied for in the console',
      'k_1xp25m6': 'userID, any custom ID',
      'k_12clf4v': 'Confirm configuration',
      'k_0um8vqm': 'Clear all configuration',
      'k_152jijg': 'Add field',
      'k_0jbia4f': 'Configured fields:',
      'k_0md2ud6': 'The field name cannot be empty',
      'k_05nspni': 'Custom field',
      'k_03eyrxm': 'Field name',
      'k_181l8gl': 'View it in the console',
      'k_03fj93v': 'Field value',
      'k_003rzap': 'OK',
      'k_0f2heqk':
          '"code=0" means success. "code!=0" means failure. You can check the error code information in the Tencent Cloud IM documentation.\n',
      'k_1r092x8': 'Deregister groupListener',
      'k_0socms9': ({required Object addType}) => 'Selected: $addType',
      'k_14awofe': ({required Object friendType}) => 'Selected: $friendType',
      'k_0w8a6yi': ({required Object chooseType}) =>
          'Select friend on blocklist ($chooseType)',
      'k_1e74ake': ({required Object checkType}) => 'Selected: $checkType',
      'k_1pli0aq': ({required Object chooseType}) =>
          'Select conversation ($chooseType)',
      'k_0itcz3b': ({required Object groupType}) => 'Selected: $groupType',
      'k_0o7jsdm': ({required Object addOpt}) => 'Selected: $addOpt',
      'k_0is52zl': ({required Object deleteType}) => 'Selected: $deleteType',
      'k_0q8ddw7': ({required Object chooseType}) =>
          'Select friend request ($chooseType)',
      'k_1pm8o4n': ({required Object chooseType}) =>
          'Select list ($chooseType)',
      'k_1pmg14j': ({required Object chooseType}) =>
          'Select friend ($chooseType)',
      'k_0q9n4ea': ({required Object userStr}) => 'User to query: $userStr',
      'k_0v51dmo': ({required Object filter}) => 'Selected: $filter',
      'k_1laca48': ({required Object type}) => 'Selected: $type',
      'k_1pm8vid': ({required Object chooseType}) =>
          'Select group ($chooseType)',
      'k_0xpwna0': ({required Object senderStr}) => 'User to query: $senderStr',
      'k_17zxeit': ({required Object chooseType}) => 'Selected: $chooseType',
      'k_1qkm7de': ({required Object priority}) => 'Selected: $priority',
      'k_16owmwk': ({required Object role}) => 'Selected: $role',
      'k_16vvwv0': ({required Object chooseAllowType}) =>
          'Selected: $chooseAllowType',
      'k_0hzbevw': ({required Object type}) => '$type trigger\n',
    };
  }
}

extension on _StringsZh {
  Map<String, dynamic> _buildFlatMap() {
    return {
      'k_0fdrjph': '事件回调',
      'k_15b7vxl': '基础模块',
      'k_1f157p5': '初始化SDK',
      'k_06n8uqh': 'sdk 初始化',
      'k_05a3xy6': '添加事件监听',
      'k_1opua40': '事件监听应先于登录方法前添加，以防漏消息',
      'k_0ptv10l': '获取服务端时间',
      'k_02r2v09': 'sdk 获取服务端时间',
      'k_003r6vf': '登录',
      'k_0z9427p': 'sdk 登录接口，先初始化',
      'k_003ph6s': '登出',
      'k_1wu4tcs': '发送C2C文本消息（3.6版本已弃用）',
      'k_1t6awxa': '发送C2C自定义消息（3.6版本已弃用）',
      'k_0pwzyvl': '发送Group文本消息（3.6版本已弃用）',
      'k_1ntp677': '发送Group自定义消息（3.6版本已弃用）',
      'k_1j35r5o': '获取 SDK 版本',
      'k_0kt7otn': '获取当前登录用户',
      'k_1v7brb7': '获取当前登录状态',
      'k_0x1tylx': '获取用户信息',
      'k_0elsjm2': '创建群聊',
      'k_0elrwzy': '加入群聊',
      'k_0elt2dt': '退出群聊',
      'k_0em2iiz': '解散群聊',
      'k_0qq6zvv': '设置个人信息',
      'k_11deha5': '试验性接口',
      'k_15a012s': '会话模块',
      'k_1xdajb0': '获取会话列表',
      'k_1rgdedc': '获取会话详情',
      'k_0glns86': '删除会话',
      'k_0xzd96m': '设置会话为草稿',
      'k_0dg9tmi': '会话置顶',
      'k_1vmox4p': '获取会话未读总数',
      'k_15b6qz8': '消息模块',
      'k_1yns1w9': '发送文本消息',
      'k_0zq67yj': '发送自定义消息',
      'k_1um4zaj': '发送图片消息',
      'k_0bgy5ol': '发送视频消息',
      'k_05gsxdv': '发送文件消息',
      'k_0axzzec': '发送录音消息',
      'k_02blxws': '发送文本At消息',
      'k_1um3h9j': '发送地理位置消息',
      'k_1x28z5r': '发送表情消息',
      'k_0310ebw': '发送合并消息',
      'k_00afgq7': '发送转发消息',
      'k_13sdbcu': '重发消息',
      'k_12w209p': '修改本地消息（String）',
      'k_199jsqj': '修改本地消息（Int）',
      'k_0ktebqj': '修改云端消息（String-已弃用）',
      'k_0k6jqud': '获取C2C历史消息',
      'k_0bf7otk': '获取Group历史消息',
      'k_1fbo5v2': '获取历史消息高级接口',
      'k_1asy1yf': '获取历史消息高级接口（不格式化）',
      'k_13sdxko': '撤回消息',
      'k_1vlsgoe': '标记C2C会话已读',
      'k_17fh8gz': '标记Group会话已读',
      'k_16sb1e7': '标记所有消息为已读',
      'k_01q04pm': '删除本地消息',
      'k_13sqfye': '删除消息',
      'k_1saxzrf': '向group中插入一条本地消息',
      'k_075u68x': '向c2c会话中插入一条本地消息',
      'k_16tukku': '清空单聊本地及云端的消息',
      'k_13z9nvj': '获取用户消息接收选项',
      'k_182b8ni': '清空群组单聊本地及云端的消息',
      'k_01qv9eo': '搜索本地消息',
      'k_0bfyrre': '查询指定会话中的本地消息',
      'k_0mz8nlf': '好友关系链模块',
      'k_10ig2ml': '获取好友列表',
      'k_0q5feak': '获取好友信息',
      'k_16758qw': '添加好友',
      'k_0q5kkj1': '设置好友信息',
      'k_1666obb': '删除好友',
      'k_167fad4': '检测好友',
      'k_15gn1d5': '获取好友申请列表',
      'k_05576s4': '同意好友申请',
      'k_055cno8': '拒绝好友申请',
      'k_0m517oy': '获取黑名单列表',
      'k_042sv53': '添加到黑名单',
      'k_1oybli5': '从黑名单移除',
      'k_05jmpkg': '创建好友分组',
      'k_05jnyuo': '获取好友分组',
      'k_05jcbyt': '删除好友分组',
      'k_14xxze4': '重命名好友分组',
      'k_14kqmvu': '添加好友到分组',
      'k_00mp87q': '从分组中删除好友',
      'k_167cp0t': '搜索好友',
      'k_15b6vqr': '群组模块',
      'k_1j2fn17': '高级创建群组',
      'k_16mti73': '获取加群列表',
      'k_0suniq6': '获取群信息',
      'k_0supwn3': '设置群信息',
      'k_1ojrrgd': '获取群在线人数',
      'k_1pb3f1z': '获取群成员列表',
      'k_1gx3i86': '获取群成员信息',
      'k_1gwzvg7': '设置群成员信息',
      'k_0h1ttfs': '禁言群成员',
      'k_0c9tkhn': '邀请好友进群',
      'k_11yzdz7': '踢人出群',
      'k_0uupir5': '设置群角色',
      'k_18pxx1p': '转移群主',
      'k_0r4h8ww': '搜索群列表',
      'k_0h1m7ef': '搜索群成员',
      'k_15az05y': '信令模块',
      'k_0gzsnbo': '发起邀请',
      'k_1ifjitt': '在群组中发起邀请',
      'k_0qr6nnz': '获取信令信息',
      'k_0hsgjrg': '添加邀请信令',
      'k_1499er2': '添加邀请信令（可以用于群离线推送消息触发的邀请信令）',
      'k_1rmuiim': '离线推送模块',
      'k_1uobs68': '上报推送配置',
      'k_18ufun0': '注册事件',
      'k_0dyrkl5': '注销simpleMsgListener事件',
      'k_1q2xs9c': '注销所有simpleMsgListener事件',
      'k_0fyg1xs': '注销advanceMsgListener',
      'k_0awkp15': '注销所有advanceMsgListener',
      'k_12oryz1': '注销signalingListener',
      'k_1xb912c': '注销所有signalingListener',
      'k_1r092x8': '注销gruopListener',
      'k_1ec07ke': '被添加好友ID',
      'k_14bwl8c': '好友备注',
      'k_121555d': '好友分组',
      'k_0qbtor0': '好友分组，首先得有这个分组',
      'k_0gavw6m': '添加简述',
      'k_15ihgoz': '好友类型',
      'k_1675qge': '双向好友',
      'k_1675qk7': '单向好友',
      'k_1eopfpu': '选择优先级',
      'k_0socms9': ({required Object addType}) => '已选：$addType',
      'k_03c51e7': '未选择',
      'k_0ethd0p': '添加信令信息（选择已有的信令信息进行测试）',
      'k_15i526p': '删除类型',
      'k_1ciwziu': '同意添加双向好友',
      'k_19iuz0v': '同意添加单向好友',
      'k_0ix65gm': '选择同意类型类型',
      'k_14awofe': ({required Object friendType}) => '已选：$friendType',
      'k_0gw88si': '同意申请',
      'k_0xxojzb': '收到的事件回调',
      'k_0quw2i5': '单选只能选一个呀',
      'k_002r2pl': '单选',
      'k_002r1h2': '多选',
      'k_0w8a6yi': ({required Object chooseType}) => '黑名单好友选择（$chooseType）',
      'k_002v9zj': '确认',
      'k_003nevv': '取消',
      'k_03mgr50': '请先在好友关系链模块中添加好友',
      'k_1ic4dp6': '选择黑名单好友',
      'k_161zzkm': '请输入用户名',
      'k_00alow4': '调用实验性接口：初始化本地数据库（您可以在SDK中自行尝试其他接口）',
      'k_1xogzdp': '调用实验性接口',
      'k_15ijita': '检测类型',
      'k_0y8ersu': '选择检测类型',
      'k_1e74ake': ({required Object checkType}) => '已选：$checkType',
      'k_0iilkht': '清空单聊本地及云端的消息（不删除会话）',
      'k_0szs46i': '获取群组信息',
      'k_1pli0aq': ({required Object chooseType}) => '会话选择（$chooseType）',
      'k_0hqslym': '暂无会话信息',
      'k_0gmqf8i': '选择会话',
      'k_03eu3my': '分组名',
      'k_03768rw': '群ID',
      'k_1vjwjey': '选填（如填，则自定义群ID）',
      'k_03agq58': '群名称',
      'k_0kg1wsx': '选择群类型',
      'k_0lzvumx': 'Work 工作群',
      'k_0mbokjw': 'Public 公开群',
      'k_028lr1o': 'Meeting 会议群',
      'k_1te7y0e': 'AVChatRoom 直播群',
      'k_0itcz3b': ({required Object groupType}) => '已选：$groupType',
      'k_03avhuo': '创建群',
      'k_03es1ox': '群类型',
      'k_0wqztai': '群类型：Work',
      'k_0shjk7e': '群类型：Public',
      'k_1qrpwz6': '群类型：Meeting',
      'k_0jmohdb': '群类型r：AVChatRoom',
      'k_03f295d': '群通告',
      'k_03i9mfe': '群简介',
      'k_03fchyy': '群头像',
      'k_11msgmy': '选择群头像',
      'k_1gyj2yl': '是否全员禁言',
      'k_0zo1d5d': '选择加群类型',
      'k_0o7jsdm': ({required Object addOpt}) => '已选：$addOpt',
      'k_18epku7': '高级创建群',
      'k_0m7f240': '从黑名单中移除',
      'k_0m3mh75': '选择删除类型',
      'k_0is52zl': ({required Object deleteType}) => '已选：$deleteType',
      'k_11vvszp': '解散群组',
      'k_0q8ddw7': ({required Object chooseType}) => '好友申请选择（$chooseType）',
      'k_1pyaxto': '目前没有好友申请',
      'k_0556th3': '选择好友申请',
      'k_1pm8o4n': ({required Object chooseType}) => '分组选择（$chooseType）',
      'k_121ewqv': '选择分组',
      'k_1pmg14j': ({required Object chooseType}) => '好友选择（$chooseType）',
      'k_167dvo3': '选择好友',
      'k_0q9n4ea': ({required Object userStr}) => '要查询的用户: $userStr',
      'k_1qdxkv0': '查询针对某个用户的 C2C 消息接收选项（免打扰状态）',
      'k_13v2x0e': '获取好友分组信息',
      'k_0v51dmo': ({required Object filter}) => '已选：$filter',
      'k_0rnrkt5': '获取在线人数',
      'k_0jd2nod': '选择type',
      'k_1laca48': ({required Object type}) => '已选：$type',
      'k_1mm5bjo': '获取历史消息高级接口（格式化数据）',
      'k_1b1tzii': '获取native sdk版本号',
      'k_0h1otop': '选择群成员',
      'k_1pm8vid': ({required Object chooseType}) => '群组选择（$chooseType）',
      'k_1ksi75r': '请先加入群组',
      'k_11vv63p': '选择群组',
      'k_03fglvp': '初始化',
      'k_0xpwna0': ({required Object senderStr}) => '要查询的用户: $senderStr',
      'k_132xs0u': '发送文本',
      'k_17argoi': '文本内容',
      'k_1qjjcx0': '是否仅在线用户接受到消息',
      'k_002ws2a': '邀请',
      'k_1bc6l5x': '进群打招呼Message',
      'k_11vsj5s': '加入群组',
      'k_0812nh1': '踢群成员出群',
      'k_1uz99pq': '标记c2c会话已读',
      'k_17fhxqb': '标记group会话已读',
      'k_13sbhj6': '选择消息',
      'k_1gw84h2': '禁言群成员信息',
      'k_0mf7epf': '会话置顶/取消置顶',
      'k_11vsa3j': '退出群组',
      'k_0stba5l': '别人发给我的',
      'k_09ezm4w': '我发别人的',
      'k_0w3vj1s': '请求类型类型',
      'k_16cx0kq': '别人发给我的加好友请求',
      'k_07d9n7u': '我发给别人的加好友请求',
      'k_15ilfmd': '选择类型',
      'k_17zxeit': ({required Object chooseType}) => '已选：$chooseType',
      'k_0gw8cb2': '拒绝申请',
      'k_15khfil': '旧分组名',
      'k_15khfh6': '新分组名',
      'k_1cgc6p5': '搜索关键字列表，最多支持5个',
      'k_1csi4tv': '关键字(example只有设置了一个关键字)',
      'k_0q9wh26': '设置是否搜索userID',
      'k_1p7cxk7': '是否设置搜索昵称',
      'k_14mm3m5': '设置是否搜索备注',
      'k_03g1hin': '关键字',
      'k_0xtvoya': '设置是否搜索群成员 userID',
      'k_0musqvf': '设置是否搜索群成员昵称',
      'k_0v2tnyc': '设置是否搜索群成员名片',
      'k_0fgvqsh': '设置是否搜索群成员备注',
      'k_0di7h2o': '搜索关键字(最多支持五个，example只支持一个)',
      'k_139zdqj': '设置是否搜索群 ID',
      'k_0rbflyz': '设置是否搜索群名称',
      'k_0t9qj8k': '搜索Group',
      'k_03rrahs': '关键字(必填)',
      'k_0vl6shl': '关键字（接口支持5个，example支持一个）',
      'k_1p5f8xt': '查询本地消息(不指定会话不返回messageList)',
      'k_0wmcksi': '自定义数据',
      'k_1wjd1o3': '发送C2C自定义消息（弃用）',
      'k_0qqamgs': '发送C2C文本消息（已经弃用）',
      'k_17ix8wi': '自定义数据data',
      'k_01cqw1f': '自定义数据desc',
      'k_0gmtcyj': '自定义数据extension',
      'k_03b2yxe': '优先级',
      'k_1qkm7de': ({required Object priority}) => '已选：$priority',
      'k_1wmh4z7': '发送消息是否不计入未读数',
      'k_02nlunm': '自定义localCustomData',
      'k_121pu0b': '表情位置',
      'k_13mefja': '表情信息',
      'k_1krj2k5': '自定义localCustomData(File)',
      'k_18ni1o4': '选择文件',
      'k_1bbh6rj': '自定义localCustomData(sendForwardMessage)',
      'k_13sda1r': '转发消息',
      'k_08lezoy': '发送自定义数据',
      'k_05wotoe': '发送Group自定义消息(弃用)',
      'k_0ayxzy6': '发送Group文本消息（已弃用）',
      'k_0kotqjn': '自定义localCustomData(sendImageMessage)',
      'k_111hdgc': '选择图片',
      'k_060rdwo': '地理位置消息描述',
      'k_0lbz4k9': '自定义localCustomData(sendLocationMessage)',
      'k_1qpk5nl': '获取当前地理位置信息',
      'k_0yn59ns': 'XXX与XXX的会话',
      'k_1k1pnl2': '低版本不支持会会收到文本消息',
      'k_07uflzi': '自定义localCustomData(sendMergerMessage)',
      'k_13sgi0s': '合并消息',
      'k_09inq13': '自定义localCustomData(sendSoundMessage)',
      'k_0svi3rz': '删除文件成功',
      'k_0bt4pm7': '结束录音',
      'k_0bt6ctk': '开始录音',
      'k_03eztxo': '未录制',
      'k_19xq0ad': '自定义localCustomData(sendVideoMessage)',
      'k_0d6yawi': '选择视频',
      'k_13qknk5': '云端数据',
      'k_0wnmtb3': '云端修改消息（String）',
      'k_09qx4fw': '草稿内容，null为取消',
      'k_1y65mf8': '设置草稿/取消草稿',
      'k_1f4rg84': '设置会话草稿',
      'k_02my10h': '群角色',
      'k_0uuoz6p': '选择群角色',
      'k_16owmwk': ({required Object role}) => '已选：$role',
      'k_1qe4r7d': '设置群成员角色',
      'k_0wng8yl': '本地修改消息（String）',
      'k_1go5et7': '本地修改消息（Int）',
      'k_15wdhxq': '注册成功',
      'k_0yj1my7': '证书id',
      'k_18e393e': '控制台上传证书返回的id',
      'k_0003v6a': '男',
      'k_00043x2': '女',
      'k_0ghstt4': '允许所有人加我好友',
      'k_1b3mn6t': '不允许所有人加我好友',
      'k_1mo5v9d': '加我好友许我确认',
      'k_003lhvk': '昵称',
      'k_003q1na': '签名',
      'k_1hgdu7c': '生日(int类型，不要输入字符串)',
      'k_003m6hr': '生日',
      'k_003qgkp': '性别',
      'k_15xu6ax': '选择性别',
      'k_1pgjz7s': '加好友验证方式',
      'k_0r291dl': '加我好友需我确认',
      'k_16vvwv0': ({required Object chooseAllowType}) => '已选：$chooseAllowType',
      'k_003qk66': '头像',
      'k_161i8im': '选择头像',
      'k_003l8z3': '提示',
      'k_142aglh': '检测到您还未配置应用信息，请先配置',
      'k_03bd50d': '去配置',
      'k_13m956w': '配置信息',
      'k_1prb9on': 'sdkappid，控制台去申请',
      'k_1fen6m9': 'secret，控制台去申请',
      'k_1xp25m6': 'userID，随便填',
      'k_12clf4v': '确认设置',
      'k_0um8vqm': '清除所有配置',
      'k_152jijg': '添加字段',
      'k_0jbia4f': '已设置字段：',
      'k_0md2ud6': '字段名不能为空',
      'k_05nspni': '自定义字段',
      'k_03eyrxm': '字段名',
      'k_181l8gl': '请在控制台查看',
      'k_03fj93v': '字段值',
      'k_003rzap': '确定',
      'k_0f2heqk': 'code=0 业务成功 code!=0 业务失败，请在腾讯云即时通信文档文档查看对应的错误码信息。\n',
      'k_0hzbevw': ({required Object type}) => '$type触发\n',
    };
  }
}
