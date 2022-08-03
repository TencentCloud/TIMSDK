
/*
 * Generated file. Do not edit.
 *
 * Locales: 3
 * Strings: 711 (237.0 per locale)
 *
 * Built on 2022-08-03 at 07:36 UTC
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
	zhHans, // 'zh-Hans'
	zhHant, // 'zh-Hant'
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
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
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

		// force rebuild if TranslationProvider is used
		_translationProviderKey.currentState?.setLocale(_currLocale);

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
		return AppLocale.values
			.map((locale) => locale.languageTag)
			.toList();
	}

	/// Gets supported locales (as Locale objects) with base locale sorted first.
	static List<Locale> get supportedLocales {
		return AppLocale.values
			.map((locale) => locale.flutterLocale)
			.toList();
	}
}

/// Provides utility functions without any side effects.
class AppLocaleUtils {
	AppLocaleUtils._(); // no constructor

	/// Returns the locale of the device as the enum type.
	/// Fallbacks to base locale.
	static AppLocale findDeviceLocale() {
		final String? deviceLocale = WidgetsBinding.instance?.window.locale.toLanguageTag();
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
late _StringsZhHans _translationsZhHans = _StringsZhHans.build();
late _StringsZhHant _translationsZhHant = _StringsZhHant.build();

// extensions for AppLocale

extension AppLocaleExtensions on AppLocale {

	/// Gets the translation instance managed by this library.
	/// [TranslationProvider] is using this instance.
	/// The plural resolvers are set via [LocaleSettings].
	_StringsEn get translations {
		switch (this) {
			case AppLocale.en: return _translationsEn;
			case AppLocale.zhHans: return _translationsZhHans;
			case AppLocale.zhHant: return _translationsZhHant;
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
			case AppLocale.en: return _StringsEn.build();
			case AppLocale.zhHans: return _StringsZhHans.build();
			case AppLocale.zhHant: return _StringsZhHant.build();
		}
	}

	String get languageTag {
		switch (this) {
			case AppLocale.en: return 'en';
			case AppLocale.zhHans: return 'zh-Hans';
			case AppLocale.zhHant: return 'zh-Hant';
		}
	}

	Locale get flutterLocale {
		switch (this) {
			case AppLocale.en: return const Locale.fromSubtags(languageCode: 'en');
			case AppLocale.zhHans: return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', );
			case AppLocale.zhHant: return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', );
		}
	}
}

extension StringAppLocaleExtensions on String {
	AppLocale? toAppLocale() {
		switch (this) {
			case 'en': return AppLocale.en;
			case 'zh-Hans': return AppLocale.zhHans;
			case 'zh-Hant': return AppLocale.zhHant;
			default: return null;
		}
	}
}

// wrappers

GlobalKey<_TranslationProviderState> _translationProviderKey = GlobalKey<_TranslationProviderState>();

class TranslationProvider extends StatefulWidget {
	TranslationProvider({required this.child}) : super(key: _translationProviderKey);

	final Widget child;

	@override
	_TranslationProviderState createState() => _TranslationProviderState();

	static _InheritedLocaleData of(BuildContext context) {
		final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_InheritedLocaleData>();
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
		: translations = locale.translations, super(child: child);

	@override
	bool updateShouldNotify(_InheritedLocaleData oldWidget) {
		return oldWidget.locale != locale;
	}
}

// pluralization feature not used

// helpers

final _localeRegex = RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');
AppLocale? _selectLocale(String localeRaw) {
	final match = _localeRegex.firstMatch(localeRaw);
	AppLocale? selected;
	if (match != null) {
		final language = match.group(1);
		final country = match.group(5);

		// match exactly
		selected = AppLocale.values
			.cast<AppLocale?>()
			.firstWhere((supported) => supported?.languageTag == localeRaw.replaceAll('_', '-'), orElse: () => null);

		if (selected == null && language != null) {
			// match language
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.startsWith(language) == true, orElse: () => null);
		}

		if (selected == null && country != null) {
			// match country
			selected = AppLocale.values
				.cast<AppLocale?>()
				.firstWhere((supported) => supported?.languageTag.contains(country) == true, orElse: () => null);
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
	dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	late final Map<String, dynamic> _flatMap = _buildFlatMap();

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get k_03f15qk => 'Blocklist';
	String get k_0uc5cnb => 'Beta test in progress. Channel creation is not supported now.';
	String get k_003nevv => 'Cancel';
	String get k_003rzap => 'OK';
	String get k_0s5ey0o => 'TRTC';
	String get k_03gpl3d => 'Hello';
	String get k_0352fjr => 'Failed to enter the channel due to network disconnection';
	String get k_0d7n018 => 'End topic';
	String get k_0d826hk => 'Pin topic to top';
	String get k_15wcgna => 'Ended successfully';
	String get k_15wo7xu => 'Pinned to top successfully';
	String get k_002s934 => 'Topic';
	String get k_18g3zdo => 'Tencent Cloud · IM';
	String get k_1m8vyp0 => 'New contacts';
	String get k_0elz70e => 'Group chats';
	String get k_18tb4mo => 'No contact';
	String get k_18nuh87 => 'Contact us';
	String get k_1uf134v => 'To provide feedback or suggestions, join our QQ group at 788910197.';
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
	String get k_0bh95w0 => 'Failed to join the topic due to network disconnection';
	String get k_002twmj => 'Group chat';
	String get k_09kalj0 => 'Clear chat history';
	String get k_18qjstb => 'Transfer group owner';
	String get k_14j5iul => 'Delete and exit';
	String get k_0jtutmw => 'You will not be able to receive messages from this group chat after you exit';
	String get k_08k00l9 => 'Loading…';
	String get k_197r4f7 => 'IM service connected successfully';
	String get k_1s5xnir => 'Failed to initialize the IM SDK';
	String get k_15bxnkw => 'Network connection lost';
	String get k_002r09z => 'Channels';
	String get k_003nvk2 => 'Chats';
	String get k_1jwxwgt => 'Connecting…';
	String get k_03gm52d => 'Contacts';
	String get k_003k7dc => 'Me';
	String get k_14yh35u => 'Log in to IM';
	String get k_0st7i3e => 'Try IM features such as group chat and voice/video call';
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
	String get k_0orhtx0 => ' Privacy Agreement ';
	String get k_00041m1 => 'and';
	String get k_0opnzp6 => ' User Agreement ';
	String get k_161ecly => 'Network unavailable';
	String get k_11uz2i8 => 'Reconnect network';
	String get k_1vhzltr => 'Tencent Cloud IM';
	String get k_0j433ys => 'Tencent Cloud TRTC';
	String get k_12u8g8l => 'Disclaimer';
	String get k_1p0j8i3 => 'Instant Messaging (IM) is a test product provided by Tencent Cloud. It is for trying out features, but not for commercial use. To follow regulatory requirements of the authority, voice and video-based interactions performed via IM will be recorded and archived throughout the whole process. It is strictly prohibited to disseminate via IM any pornographic, abusive, violent, political and other noncompliant content.';
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
	String get k_0h22snw => 'Voice call';
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
	String get k_0mnxjg7 => 'Welcome to Tencent Cloud Instant Messaging (IM). To protect the security of your personal information, we have updated the Privacy Policy, mainly improving the specific content and purpose for user information collection and adding the use of third-party SDKs.';
	String get k_1545beg => 'Please tap ';
	String get k_11x8pvm => 'and read them carefully. If you agree to the content, tap "Accept and continue" to start using our product and service.';
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
	String k_0upijvs({required Object message}) => 'Failed to get the discussion forum list: $message';
	String k_0v5hlay({required Object message}) => 'Failed to create the topic: $message';
	String get k_0em28sp => 'No group chat';
	String k_0owk5ss({required Object failedReason}) => 'Login failed: $failedReason';
	String get k_0glj9us => 'Initiate conversation';
	String get k_1631kyh => 'Create work group';
	String get k_1644yii => 'Create public group';
	String get k_1fxfx04 => 'Create meeting group';
	String get k_1cnkqc9 => 'Create voice-video group';
	String k_1mw45lz({required Object errorReason}) => 'Login failed: $errorReason';
	String get k_0epvs61 => 'Change skin';
	String get k_002ri2g => 'Log in';
	String k_1o7lf2y({required Object errorMessage}) => 'Server error: $errorMessage';
	String k_118l7sq({required Object requestErrorMessage}) => 'Request error: $requestErrorMessage';
	String get k_003nfx9 => 'Deep';
	String get k_003rvjp => 'Light';
	String get k_003rtht => 'Bright';
	String get k_003qxiw => 'Fantasy';
	String k_0s5zoi3({required Object option1}) => 'Error: $option1';
	String k_0i8egqa({required Object option8}) => 'Message obtained: $option8';
	String k_0pokyns({required Object option8}) => 'Failed to get the discussion forum list: $option8';
	String k_1y03m8a({required Object option8}) => 'Failed to create the topic: $option8';
	String k_1v6uh9c({required Object option8}) => 'Login failed: $option8';
	String k_0t5a9hl({required Object option1}) => 'Login failed: $option1';
	String k_0k3uv02({required Object option8}) => 'Server error: $option8';
	String k_1g9o3kz({required Object option8}) => 'Request error: $option8';
	String get k_10s6v2i => ' Information Collection Statement ';
	String get k_0pasxq8 => ' Information Sharing Statement ';
	String get k_14cahuz => 'About Tencent Cloud · IM';
	String get k_0llnalm => 'SDK Version';
	String get k_13dyfii => 'APP Version';
	String get k_12h52zh => 'Privacy Policy';
	String get k_0fxhhwb => 'User Agreement';
	String get k_18z2e6q => 'APP Tencent Cloud · IM(\'this product\') is a test product provided by Tencent Cloud and Tencent Cloud enjoys the copyright and ownership of this product. This product is only used for functional experience and must not be used for any commercial purposes.In order to comply with the regulatory requirements of relevant departments the voice and video interactions of this product are archived throughout the entire voice and video interactions. Any pornography,abusive,violent and politically related content is strictly prohibited during use.';
	String get k_0zu7dd7 => 'Personal Information Collected';
	String get k_0mcqhgh => 'Information Shared with Third Parties';
	String get k_12eqaty => 'Confirm to deregister account';
	String get k_0ziqsr6 => 'Account deregistered successfully';
	String get k_002qtgt => 'Deregister Account';
	String k_0rvdu91({required Object option1}) => 'After deregister this account, you will be unable to use it, and the related data will be permanently deleted. Current account: $option1';
	String get k_15d22qk => 'Deregister Account';
	String get k_036uv3f => 'Tencent Cloud · IM';
	String get k_167916k => 'WeChat contacts';
	String get k_03euwr1 => 'Moments';
	String get k_0cxccci => 'invites you to a video call';
	String get k_06lhh4b => 'invites you to a voice call';
	String get k_1ywo9ut => 'Tencent Cloud · IM is developed based on QQ messaging module. Chat, conversation, group, data management and LVB on-screen comments can be easily implemented by Chat SDK. Also, connecting with other products such as whiteboards through signaling messages is supported. We can fully covering your business scenarios. Our Chat SDK can support major platforms and Mini Program, to meet communication needs.';
	String get k_0ios26v => 'WeChat is not detected';
	String get k_002rflt => 'Delete';
	String get k_125ru1w => 'Disband Group';
	String get k_0jtzmqa => 'You will not receiving messages from this group after disbanding';
	String get k_1jg6d5x => ' Summary of Privacy Policy ';
	String get k_0selni4 => ' Privacy Policy ';
	String get k_003r6vf => 'Log in';
	String get k_09khmso => 'Related messages';
	String get k_118prbn => 'Search globally';
	String get k_03f2zbs => 'Share to ';
	String get k_0cfkcaz => 'Chat Message';
	String get k_1rmkb2w => 'New Chat Message';
	String get k_1lg375c => 'New Chat Message Remind';
	String k_1t0akzp({required Object option1}) => 'After deregister this account, you will be unable to use it, and the related data will be permanently deleted. Current account: $option1';
	String get k_1699p6d => 'Tencent Building';
	String get k_1ngd60h => 'No. 10000 Shennan avenue, Shenzhen';
	String get k_1na29vg => 'Location messages is not supported in DEMO temporarily';
	String get k_1xmms9t => 'Request to Join Group';
	String get k_0dla4vp => 'To provide feedback or suggestions,\n please join our QQ group at';
	String get k_1odrjd1 => 'Online time: 10 AM to 8 PM, Mon through Fri';
	String get k_1bh903m => 'Copied successfully';
	String get k_16264lp => 'Copy group number';
	String get k_18ger86 => 'Tencent Cloud IM';
	String get k_1vd70l1 => 'Chat SDK serving hundreds of millions of QQ users';
	String get k_036phup => 'Tencent Cloud IM';
	String get k_003qgkp => 'Gender';
	String get k_0003v6a => 'Male';
	String get k_00043x2 => 'Female';
	String get k_03bcjkv => 'Not sett';
	String get k_11zgnfs => 'My Profile';
	String get k_003qk66 => 'Profile Photo';
	String get k_11s0gdz => 'Modify nickname';
	String get k_0p3j4sd => 'Letters, numbers and underscores only';
	String get k_003lhvk => 'Nickname';
	String get k_15lyvdt => 'Modify Status';
	String get k_15lx52z => 'Status';
	String get k_0vylzjp => 'Nothing here';
	String get k_1c3us5n => '@ALL is not supported in this group';
	String get k_11k579v => 'Illegal sentences in the text';
	String get k_0gfsln9 => 'Information modified';
	String get k_0ow4akh => 'Please configure Baidu AK according to the README guidelines of Demo to experience the location messaging capability of DEMO.';
	String get k_1kzh3lo => 'Please follow the guidelines of this document to https://docs.qq.com/doc/DSVliWE9acURta2dL to quickly experience location messaging capabilities.';
	String get k_161zzkm => 'Please enter a User ID';
	String get k_1veosyv => 'Please config the secret KEY in the environment variable';
	String get k_03exdnb => 'User ID';
	String get k_16kquu8 => 'Current path';
	String get k_0fbvuqs => 'Copy';
	String get k_16j153h => 'Tencent Cloud IM APP ("this APP") is a product provided by Tencent Cloud aims of demonstration, which enjoys the copyright and ownership of this APP. This APP is for functional experience only and must not be used for any commercial purpose. It is strictly forbidden to spread any illegal content such as pornography, abuse, violence and terrorism, politics and so on.';
	String get k_13ghyf8 => '[Security Reminder] This APP is only for experiencing the features of Tencent Cloud IM Chat, and cannot be used for any other purposes.';
	String get k_0gt6cro => 'Complain here';
	String k_03595fk({required Object option1}) => ' and $option1 more';
	String k_1gpzgni({required Object option2}) => 'group with $option2 people';
	String get k_02lfg57 => 'New Group Chat';
	String get k_17ifd8i => 'Welcome to Tencent IM Chat SDK and TUIKit on Flutter';
	String get k_1f0ms23 => 'Message read status';
	String get k_1c0x9ha => 'Determines if the reading status shows for your messages and whether others can know about if you read.';
	String get k_1dzhdr5 => 'Online status';
	String get k_0mwsniq => 'Determines if the online status shows for you contacts or friends.';
}

// Path: <root>
class _StringsZhHans implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsZhHans.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsZhHans _root = this; // ignore: unused_field

	// Translations
	@override String get k_16758qw => '添加好友';
	@override String get k_0elt0kw => '添加群聊';
	@override String get k_03f15qk => '黑名单';
	@override String get k_0s3p3ji => '暂无黑名单';
	@override String get k_0uc5cnb => '我们还在内测中，暂不支持创建频道。';
	@override String get k_003rzap => '确定';
	@override String get k_003nevv => '取消';
	@override String get k_0s5ey0o => '实时音视频 TRTC';
	@override String get k_03gpl3d => '大家好';
	@override String get k_0352fjr => '无网络连接，进入频道失败';
	@override String get k_0d7n018 => '结束话题';
	@override String get k_0d826hk => '置顶话题';
	@override String get k_15wcgna => '结束成功';
	@override String get k_15wo7xu => '置顶成功';
	@override String k_02slfpm({required Object errorMessage}) => '发生错误 $errorMessage';
	@override String get k_003ltgm => '位置';
	@override String get k_0h22snw => '语音通话';
	@override String get k_0h20hg5 => '视频通话';
	@override String get k_002s934 => '话题';
	@override String get k_18g3zdo => '云通信·IM';
	@override String get k_1m8vyp0 => '新的联系人';
	@override String get k_0elz70e => '我的群聊';
	@override String get k_18tb4mo => '无联系人';
	@override String get k_18nuh87 => '联系我们';
	@override String get k_1uf134v => '反馈及建议可以加入QQ群：788910197';
	@override String get k_0xlhhrn => '在线时间，周一到周五，早上10点 - 晚上8点';
	@override String get k_17fmlyf => '清除聊天';
	@override String get k_0dhesoz => '取消置顶';
	@override String get k_002sk7x => '置顶';
	@override String get k_003kv3v => '搜索';
	@override String get k_0gmpgcg => '暂无会话';
	@override String get k_1m8zuj4 => '选择联系人';
	@override String get k_002tu9r => '性能';
	@override String k_0vwtop2({required Object getMsg}) => '获取到的消息:$getMsg';
	@override String k_0upijvs({required Object message}) => '获取讨论区列表失败 $message';
	@override String get k_1tmcw5c => '请完善话题标题';
	@override String get k_1cnmslk => '必须选择一个标签';
	@override String k_0v5hlay({required Object message}) => '创建话题失败 $message';
	@override String get k_0z3ytji => '创建话题成功';
	@override String get k_1a8vem3 => '创建者异常';
	@override String get k_0eskkr1 => '选择讨论区';
	@override String get k_0d7plb5 => '创建话题';
	@override String get k_144t0ho => '---- 相关讨论 ----';
	@override String get k_0pnz619 => '填写话题标题';
	@override String get k_136v279 => '+标签（至少添加一个）';
	@override String get k_04hjhvp => '讨论区参数异常';
	@override String get k_002r79h => '全部';
	@override String get k_03ejkb6 => '已加入';
	@override String get k_172tngw => '话题（未连接）';
	@override String get k_0rnmfc4 => '该讨论区下暂无话题';
	@override String get k_1pq0ybn => '暂未加入任何话题';
	@override String get k_0bh95w0 => '无网络连接，进入话题失败';
	@override String get k_002twmj => '群聊';
	@override String get k_0em28sp => '暂无群聊';
	@override String get k_09kalj0 => '清空聊天记录';
	@override String get k_18qjstb => '转让群主';
	@override String get k_14j5iul => '删除并退出';
	@override String get k_0jtutmw => '退出后不会接收到此群聊消息';
	@override String get k_04dqh36 => '暂无新联系人';
	@override String get k_08k00l9 => '正在加载...';
	@override String get k_197r4f7 => '即时通信服务连接成功';
	@override String get k_1s5xnir => '即时通信 SDK初始化失败';
	@override String k_0owk5ss({required Object failedReason}) => '登录失败 $failedReason';
	@override String get k_15bxnkw => '网络连接丢失';
	@override String get k_0glj9us => '发起会话';
	@override String get k_1631kyh => '创建工作群';
	@override String get k_1644yii => '创建社交群';
	@override String get k_1fxfx04 => '创建会议群';
	@override String get k_1cnkqc9 => '创建直播群';
	@override String get k_002r09z => '频道';
	@override String get k_003nvk2 => '消息';
	@override String get k_1jwxwgt => '连接中...';
	@override String get k_03gm52d => '通讯录';
	@override String get k_003k7dc => '我的';
	@override String get k_14yh35u => '登录·即时通信';
	@override String get k_0st7i3e => '体验群组聊天，音视频对话等IM功能';
	@override String get k_0cr1atw => '中国大陆';
	@override String get k_0mnxjg7 => '欢迎使用腾讯云即时通信 IM，为保护您的个人信息安全，我们更新了《隐私政策》，主要完善了收集用户信息的具体内容和目的、增加了第三方SDK使用等方面的内容。';
	@override String get k_1545beg => '请您点击';
	@override String get k_0opnzp6 => '《用户协议》';
	@override String get k_00041m1 => '和';
	@override String get k_0orhtx0 => '《隐私协议》';
	@override String get k_11x8pvm => '并仔细阅读，如您同意以上内容，请点击“同意并继续”，开始使用我们的产品与服务！';
	@override String get k_17nw8gq => '同意并继续';
	@override String get k_1nynslj => '不同意并退出';
	@override String get k_0jsvmjm => '请输入手机号';
	@override String get k_1lg8qh2 => '手机号格式错误';
	@override String get k_03jia4z => '无网络连接';
	@override String get k_007jqt2 => '验证码发送成功';
	@override String get k_1a55aib => '验证码异常';
	@override String k_1mw45lz({required Object errorReason}) => '登录失败$errorReason';
	@override String get k_16r3sej => '国家/地区';
	@override String get k_15hlgzr => '选择你的国家区号';
	@override String get k_1bnmt3h => '请使用英文搜索';
	@override String get k_03fei8z => '手机号';
	@override String get k_03aj66h => '验证码';
	@override String get k_1m9jtmw => '请输入验证码';
	@override String get k_0y1wbxk => '获取验证码';
	@override String get k_002ri2g => '登陆';
	@override String get k_161ecly => '当前无网络';
	@override String get k_11uz2i8 => '重试网络';
	@override String get k_1vhzltr => '腾讯云即时通信IM';
	@override String get k_0j433ys => '腾讯云TRTC';
	@override String get k_0epvs61 => '更换皮肤';
	@override String get k_12u8g8l => '免责声明';
	@override String get k_1p0j8i3 => 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。';
	@override String get k_0k7qoht => '同意任何用户加好友';
	@override String get k_0gyhkp5 => '需要验证';
	@override String get k_121ruco => '拒绝任何人加好友';
	@override String get k_003kfai => '未知';
	@override String get k_1kvyskd => '无网络连接，无法修改';
	@override String get k_1j91bvz => 'TUIKIT 为你选择一个头像?';
	@override String get k_1wmkneq => '加我为好友时需要验证';
	@override String get k_1eitsd0 => '关于腾讯云·通信';
	@override String get k_1919d6m => '隐私条例';
	@override String get k_0wqhgor => '个人信息收集清单';
	@override String get k_12rfxml => '第三方信息共享清单';
	@override String get k_131g7q4 => '注销账户';
	@override String get k_03fel2u => '版本号';
	@override String get k_16kts8h => '退出登录';
	@override String get k_129scag => '好友删除成功';
	@override String get k_094phq4 => '好友添加失败';
	@override String get k_13spdki => '发送消息';
	@override String get k_1666isy => '清除好友';
	@override String get k_0r8fi93 => '好友添加成功';
	@override String get k_02qw14e => '好友申请已发出';
	@override String get k_0n3md5x => '当前用户在黑名单';
	@override String get k_14c600t => '修改备注';
	@override String get k_1f811a4 => '支持数字、英文、下划线';
	@override String get k_11z7ml4 => '详细资料';
	@override String get k_0003y9x => '无';
	@override String get k_1679vrd => '加为好友';
	@override String get k_1ajt0b1 => '获取当前位置失败';
	@override String get k_0lhm9xq => '发起检索成功';
	@override String get k_0fdeled => '发起检索失败';
	@override String get k_1yh0a50 => 'mapDidLoad-地图加载完成';
	@override String get k_1t2zg6h => '图片验证码校验失败';
	@override String get k_03ibg5h => '星期一';
	@override String get k_03i7hu1 => '星期二';
	@override String get k_03iaiks => '星期三';
	@override String get k_03el9pa => '星期四';
	@override String get k_03i7ok1 => '星期五';
	@override String get k_03efxyg => '星期六';
	@override String get k_03ibfd2 => '星期七';
	@override String k_1o7lf2y({required Object errorMessage}) => '服务器错误：$errorMessage';
	@override String k_118l7sq({required Object requestErrorMessage}) => '请求错误：$requestErrorMessage';
	@override String get k_003nfx9 => '深沉';
	@override String get k_003rvjp => '轻快';
	@override String get k_003rtht => '明媚';
	@override String get k_003qxiw => '梦幻';
	@override String k_0s5zoi3({required Object option1}) => '发生错误 $option1';
	@override String k_0i8egqa({required Object option8}) => '获取到的消息:$option8';
	@override String k_0pokyns({required Object option8}) => '获取讨论区列表失败 $option8';
	@override String k_1y03m8a({required Object option8}) => '创建话题失败 $option8';
	@override String k_1v6uh9c({required Object option8}) => '登录失败 $option8';
	@override String k_0t5a9hl({required Object option1}) => '登录失败$option1';
	@override String k_0k3uv02({required Object option8}) => '服务器错误：$option8';
	@override String k_1g9o3kz({required Object option8}) => '请求错误：$option8';
	@override String get k_14cahuz => '关于腾讯云 · IM';
	@override String get k_0llnalm => 'SDK版本号';
	@override String get k_13dyfii => '应用版本号';
	@override String get k_12h52zh => '隐私政策';
	@override String get k_0fxhhwb => '用户协议';
	@override String get k_18z2e6q => 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。';
	@override String get k_0zu7dd7 => '信息收集清单';
	@override String get k_0mcqhgh => '信息共享清单';
	@override String get k_12eqaty => '确认注销账户';
	@override String get k_0ziqsr6 => '账户注销成功！';
	@override String get k_002qtgt => '注销';
	@override String k_0rvdu91({required Object option1}) => '注销后，您将无法使用当前账号，相关数据也将删除且无法找回。当前账号ID: $option1';
	@override String get k_15d22qk => '注销账号';
	@override String get k_036uv3f => '腾讯云IM';
	@override String get k_167916k => '微信好友';
	@override String get k_03euwr1 => '朋友圈';
	@override String get k_0cxccci => '邀请你视频通话';
	@override String get k_06lhh4b => '邀请你语音通话';
	@override String get k_1ywo9ut => '即时通信 IM (Instant Messaging)基于 QQ 底层 IM 能力开发，仅需植入 SDK 即可轻松集成聊天、会话、群组、资料管理和直播弹幕能力，也支持通过信令消息与白板等其他产品打通，全面覆盖您的业务场景，支持各大平台小程序接入使用，全面满足通信需要';
	@override String get k_0ios26v => '未检测到微信安装';
	@override String get k_002rflt => '删除';
	@override String get k_125ru1w => '解散该群';
	@override String get k_0jtzmqa => '解散后不会接收到此群聊消息';
	@override String get k_1jg6d5x => '《隐私政策摘要》';
	@override String get k_0selni4 => '《隐私政策》';
	@override String get k_10s6v2i => '《信息收集清单》';
	@override String get k_0pasxq8 => '《信息共享清单》';
	@override String get k_003r6vf => '登录';
	@override String get k_09khmso => '相关聊天记录';
	@override String get k_118prbn => '全局搜索';
	@override String get k_03f2zbs => '分享到';
	@override String get k_0cfkcaz => '消息推送';
	@override String get k_1rmkb2w => '推送新聊天消息';
	@override String get k_1lg375c => '新消息提醒';
	@override String k_1t0akzp({required Object option1}) => '注销后，您将无法使用当前账号，相关数据也将删除且无法找回。当前账号ID: $option1';
	@override String get k_1699p6d => '腾讯大厦';
	@override String get k_1ngd60h => '深圳市深南大道10000号';
	@override String get k_1na29vg => '位置消息维护中';
	@override String get k_1xmms9t => '进群申请列表';
	@override String get k_0dla4vp => '反馈及建议可以加入QQ群';
	@override String get k_1odrjd1 => '在线时间: 周一到周五，早上10点 - 晚上8点';
	@override String get k_1bh903m => 'QQ群号复制成功';
	@override String get k_16264lp => '复制群号';
	@override String get k_18ger86 => '腾讯云 · IM';
	@override String get k_1vd70l1 => '服务亿级 QQ 用户的即时通讯技术';
	@override String get k_036phup => '腾讯云IM';
	@override String get k_003qgkp => '性别';
	@override String get k_0003v6a => '男';
	@override String get k_00043x2 => '女';
	@override String get k_03bcjkv => '未设置';
	@override String get k_11zgnfs => '个人资料';
	@override String get k_003qk66 => '头像';
	@override String get k_11s0gdz => '修改昵称';
	@override String get k_0p3j4sd => '仅限中字、字母、数字和下划线';
	@override String get k_003lhvk => '昵称';
	@override String get k_15lyvdt => '修改签名';
	@override String get k_15lx52z => '个性签名';
	@override String get k_0vylzjp => '这个人很懒，什么也没写';
	@override String get k_1c3us5n => '当前群组不支持@全体成员';
	@override String get k_11k579v => '发言中有非法语句';
	@override String get k_0gfsln9 => '信息已变更';
	@override String get k_0ow4akh => '请根据Demo的README指引，配置百度AK，体验DEMO的位置消息能力';
	@override String get k_1kzh3lo => '请根据本文档指引 https://docs.qq.com/doc/DSVliWE9acURta2dL ， 快速体验位置消息能力';
	@override String get k_161zzkm => '请输入用户名';
	@override String get k_1veosyv => '请在环境变量中写入key';
	@override String get k_03exdnb => '用户名';
	@override String get k_16kquu8 => '当前目录';
	@override String get k_0fbvuqs => '开始拷贝';
	@override String get k_16j153h => '腾讯云IM APP（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。';
	@override String get k_13ghyf8 => '【安全提示】本 APP 仅用于体验腾讯云即时通信 IM 产品功能，不可用于业务洽谈与拓展。请勿轻信汇款、中奖等涉及钱款的信息，勿轻易拨打陌生电话，谨防上当受骗。';
	@override String get k_0gt6cro => '点此投诉';
	@override String k_03595fk({required Object option1}) => ' 等$option1人';
	@override String k_1gpzgni({required Object option2}) => '$option2人群';
	@override String get k_02lfg57 => '新群聊';
	@override String get k_17ifd8i => '欢迎使用本 APP 体验腾讯云 IM 产品服务';
	@override String get k_1f0ms23 => '消息阅读状态';
	@override String get k_1c0x9ha => '关闭后，您收发的消息均不带消息阅读状态，您将无法看到对方是否已读，同时对方也无法看到你是否已读。';
	@override String get k_1dzhdr5 => '显示在线状态';
	@override String get k_0mwsniq => '关闭后，您将不可以在会话列表和通讯录中看到好友在线或离线的状态提示。';
}

// Path: <root>
class _StringsZhHant implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsZhHant.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	@override late final Map<String, dynamic> _flatMap = _buildFlatMap();

	@override late final _StringsZhHant _root = this; // ignore: unused_field

	// Translations
	@override String get k_16758qw => '添加好友';
	@override String get k_0elt0kw => '添加群組';
	@override String get k_03f15qk => '黑名單';
	@override String get k_0s3p3ji => '暫無黑名單';
	@override String get k_0uc5cnb => '我們還在內測中，暫不支持創建頻道。';
	@override String get k_003rzap => '確定';
	@override String get k_003nevv => '取消';
	@override String get k_0s5ey0o => '實時音視訊 TRTC';
	@override String get k_03gpl3d => '大家好';
	@override String get k_0352fjr => '無網絡連接，進入頻道失敗';
	@override String get k_0d7n018 => '結束話題';
	@override String get k_0d826hk => '置頂話題';
	@override String get k_15wcgna => '結束成功';
	@override String get k_15wo7xu => '置頂成功';
	@override String k_02slfpm({required Object errorMessage}) => '發生錯誤 $errorMessage';
	@override String get k_003ltgm => '位置';
	@override String get k_0h22snw => '語音通話';
	@override String get k_0h20hg5 => '視訊通話';
	@override String get k_002s934 => '話題';
	@override String get k_18g3zdo => '雲通信·IM';
	@override String get k_1m8vyp0 => '新的聯絡人';
	@override String get k_0elz70e => '我的群組';
	@override String get k_18tb4mo => '無聯絡人';
	@override String get k_18nuh87 => '聯絡我們';
	@override String get k_1uf134v => '反饋及建議可以加入QQ群：788910197';
	@override String get k_0xlhhrn => '在線時間，周一到周五，早上10點 - 晚上8點';
	@override String get k_17fmlyf => '清除聊天';
	@override String get k_0dhesoz => '取消置頂';
	@override String get k_002sk7x => '置頂';
	@override String get k_003kv3v => '搜尋';
	@override String get k_0gmpgcg => '暫無會話';
	@override String get k_1m8zuj4 => '選擇聯絡人';
	@override String get k_002tu9r => '性能';
	@override String k_0vwtop2({required Object getMsg}) => '獲取到的訊息:$getMsg';
	@override String k_0upijvs({required Object message}) => '獲取討論區列表失敗 $message';
	@override String get k_1tmcw5c => '請完善話題標題';
	@override String get k_1cnmslk => '必須選擇一個標簽';
	@override String k_0v5hlay({required Object message}) => '創建話題失敗 $message';
	@override String get k_0z3ytji => '創建話題成功';
	@override String get k_1a8vem3 => '創建者異常';
	@override String get k_0eskkr1 => '選擇討論區';
	@override String get k_0d7plb5 => '創建話題';
	@override String get k_144t0ho => '---- 相關討論 ----';
	@override String get k_0pnz619 => '填寫話題標題';
	@override String get k_136v279 => '+標簽（至少添加一個）';
	@override String get k_04hjhvp => '討論區參數異常';
	@override String get k_002r79h => '全部';
	@override String get k_03ejkb6 => '已加入';
	@override String get k_172tngw => '話題（未連接）';
	@override String get k_0rnmfc4 => '該討論區下暫無話題';
	@override String get k_1pq0ybn => '暫未加入任何話題';
	@override String get k_0bh95w0 => '無網絡連接，進入話題失敗';
	@override String get k_002twmj => '群組';
	@override String get k_0em28sp => '暫無群組';
	@override String get k_09kalj0 => '清空聊天記錄';
	@override String get k_18qjstb => '轉讓群主';
	@override String get k_14j5iul => '刪除並退出';
	@override String get k_0jtutmw => '退出後不會接收到此群組訊息';
	@override String get k_04dqh36 => '暫無新聯絡人';
	@override String get k_08k00l9 => '正在載入...';
	@override String get k_197r4f7 => '即時通信服務連接成功';
	@override String get k_1s5xnir => '即時通信 SDK初始化失敗';
	@override String k_0owk5ss({required Object failedReason}) => '登入失敗 $failedReason';
	@override String get k_15bxnkw => '網絡連接丟失';
	@override String get k_0glj9us => '發起會話';
	@override String get k_1631kyh => '創建工作群';
	@override String get k_1644yii => '創建社交群';
	@override String get k_1fxfx04 => '創建會議群';
	@override String get k_1cnkqc9 => '創建直播群';
	@override String get k_002r09z => '頻道';
	@override String get k_003nvk2 => '訊息';
	@override String get k_1jwxwgt => '連接中...';
	@override String get k_03gm52d => '通訊錄';
	@override String get k_003k7dc => '我的';
	@override String get k_14yh35u => '登入·即時通信';
	@override String get k_0st7i3e => '體驗群組聊天，音視訊對話等IM功能';
	@override String get k_0cr1atw => '中國大陸';
	@override String get k_0mnxjg7 => '歡迎使用騰訊雲即時通信 IM，為保護您的個人信息安全，我們更新了《私隱政策》，主要完善了收集用戶信息的具體內容和目的、增加了第三方SDK使用等方面的內容。';
	@override String get k_1545beg => '請您點擊';
	@override String get k_0opnzp6 => '《用戶協議》';
	@override String get k_00041m1 => '和';
	@override String get k_0orhtx0 => '《私隱協議》';
	@override String get k_11x8pvm => '並仔細閱讀，如您同意以上內容，請點擊「同意並繼續」，開始使用我們的產品與服務！';
	@override String get k_17nw8gq => '同意並繼續';
	@override String get k_1nynslj => '不同意並退出';
	@override String get k_0jsvmjm => '請輸入手機號碼';
	@override String get k_1lg8qh2 => '手機號碼格式錯誤';
	@override String get k_03jia4z => '無網絡連接';
	@override String get k_007jqt2 => '驗證碼發送成功';
	@override String get k_1a55aib => '驗證碼異常';
	@override String k_1mw45lz({required Object errorReason}) => '登入失敗$errorReason';
	@override String get k_16r3sej => '國家/地區';
	@override String get k_15hlgzr => '選擇你的國家區號';
	@override String get k_1bnmt3h => '請使用英文搜尋';
	@override String get k_03fei8z => '手機號碼';
	@override String get k_03aj66h => '驗證碼';
	@override String get k_1m9jtmw => '請輸入驗證碼';
	@override String get k_0y1wbxk => '獲取驗證碼';
	@override String get k_002ri2g => '登陸';
	@override String get k_161ecly => '當前無網絡';
	@override String get k_11uz2i8 => '重試網絡';
	@override String get k_1vhzltr => '騰訊雲即時通信IM';
	@override String get k_0j433ys => '騰訊雲TRTC';
	@override String get k_0epvs61 => '更換皮膚';
	@override String get k_12u8g8l => '免責聲明';
	@override String get k_1p0j8i3 => 'IM即時通信（「本產品」）是由騰訊雲提供的一款測試產品，騰訊雲享有本產品的著作權和所有權。本產品僅用於功能體驗，不得用於任何商業用途。為配合相關部門監管要求，本產品音視訊互動全程均有錄音錄像存檔，嚴禁在使用中有任何色情、辱罵、暴恐、涉政等違法內容傳播。';
	@override String get k_0k7qoht => '同意任何用戶加好友';
	@override String get k_0gyhkp5 => '需要驗證';
	@override String get k_121ruco => '拒絕任何人加好友';
	@override String get k_003kfai => '未知';
	@override String get k_1kvyskd => '無網絡連接，無法修改';
	@override String get k_1j91bvz => 'TUIKIT 為你選擇一個頭像?';
	@override String get k_1wmkneq => '加我為好友時需要驗證';
	@override String get k_1eitsd0 => '關於騰訊雲·通信';
	@override String get k_1919d6m => '私隱條例';
	@override String get k_0wqhgor => '個人資料收集清單';
	@override String get k_12rfxml => '第三方資料共用清單';
	@override String get k_131g7q4 => '註銷賬戶';
	@override String get k_03fel2u => '版本號';
	@override String get k_16kts8h => '登出';
	@override String get k_129scag => '好友刪除成功';
	@override String get k_094phq4 => '好友添加失敗';
	@override String get k_13spdki => '發送訊息';
	@override String get k_1666isy => '清除好友';
	@override String get k_0r8fi93 => '好友添加成功';
	@override String get k_02qw14e => '好友申請已發出';
	@override String get k_0n3md5x => '當前用戶在黑名單';
	@override String get k_14c600t => '修改備註';
	@override String get k_1f811a4 => '支持數字、英文、下劃線';
	@override String get k_11z7ml4 => '詳細資料';
	@override String get k_0003y9x => '無';
	@override String get k_1679vrd => '加為好友';
	@override String get k_1ajt0b1 => '獲取當前位置失敗';
	@override String get k_0lhm9xq => '發起檢索成功';
	@override String get k_0fdeled => '發起檢索失敗';
	@override String get k_1yh0a50 => 'mapDidLoad-地圖載入完成';
	@override String get k_1t2zg6h => '圖片驗證碼校驗失敗';
	@override String get k_03ibg5h => '星期一';
	@override String get k_03i7hu1 => '星期二';
	@override String get k_03iaiks => '星期三';
	@override String get k_03el9pa => '星期四';
	@override String get k_03i7ok1 => '星期五';
	@override String get k_03efxyg => '星期六';
	@override String get k_03ibfd2 => '星期七';
	@override String k_1o7lf2y({required Object errorMessage}) => '服務器錯誤：$errorMessage';
	@override String k_118l7sq({required Object requestErrorMessage}) => '請求錯誤：$requestErrorMessage';
	@override String get k_003nfx9 => '深沈';
	@override String get k_003rvjp => '輕快';
	@override String get k_003rtht => '明媚';
	@override String get k_003qxiw => '夢幻';
	@override String k_0s5zoi3({required Object option1}) => '發生錯誤 $option1';
	@override String k_0i8egqa({required Object option8}) => '獲取到的訊息:$option8';
	@override String k_0pokyns({required Object option8}) => '獲取討論區列表失敗 $option8';
	@override String k_1y03m8a({required Object option8}) => '創建話題失敗 $option8';
	@override String k_1v6uh9c({required Object option8}) => '登入失敗 $option8';
	@override String k_0t5a9hl({required Object option1}) => '登入失敗$option1';
	@override String k_0k3uv02({required Object option8}) => '服務器錯誤：$option8';
	@override String k_1g9o3kz({required Object option8}) => '請求錯誤：$option8';
	@override String get k_14cahuz => '關於騰訊雲 · IM';
	@override String get k_0llnalm => 'SDK版本號';
	@override String get k_13dyfii => '應用版本號';
	@override String get k_12h52zh => '私隱政策';
	@override String get k_0fxhhwb => '用戶協議';
	@override String get k_18z2e6q => 'IM即時通信（「本產品」）是由騰訊雲提供的一款測試產品，騰訊雲享有本產品的著作權和所有權。本產品僅用於功能體驗，不得用於任何商業用途。嚴禁在使用中有任何色情、辱罵、暴恐、涉政等違法內容傳播。';
	@override String get k_0zu7dd7 => '個人資料收集清單';
	@override String get k_0mcqhgh => '第三方資料共用清單';
	@override String get k_12eqaty => '確認註銷賬戶';
	@override String get k_0ziqsr6 => '賬戶註銷成功！';
	@override String get k_002qtgt => '註銷';
	@override String k_0rvdu91({required Object option1}) => '註銷後，您將無法使用當前賬號，相關數據也將刪除且無法找回。當前賬號ID: $option1';
	@override String get k_15d22qk => '註銷賬號';
	@override String get k_036uv3f => '雲通信IM';
	@override String get k_167916k => '微信好友';
	@override String get k_03euwr1 => '朋友圈';
	@override String get k_0cxccci => '邀請你視訊通話';
	@override String get k_06lhh4b => '邀請你語音通話';
	@override String get k_1ywo9ut => '即時通信 IM (Instant Messaging)基於 QQ 底層 IM 能力開發，僅需植入 SDK 即可輕松集成聊天、會話、群組、資料管理和直播彈幕能力，也支持通過信令訊息與白板等其他產品打通，全面覆蓋您的業務場景，支持各大平臺小程序接入使用，全面滿足通信需要';
	@override String get k_0ios26v => '未檢測到微信安裝';
	@override String get k_002rflt => '刪除';
	@override String get k_125ru1w => '解散該群';
	@override String get k_0jtzmqa => '解散後不會接收到此群組訊息';
	@override String get k_1jg6d5x => '《私隱政策摘要》';
	@override String get k_0selni4 => '《私隱政策》';
	@override String get k_10s6v2i => '《個人資料收集清單》';
	@override String get k_0pasxq8 => '《第三方資料共用清單》';
	@override String get k_003r6vf => '登入';
	@override String get k_09khmso => '相關聊天記錄';
	@override String get k_118prbn => '全局搜尋';
	@override String get k_03f2zbs => '分享到';
	@override String get k_0cfkcaz => '訊息推送';
	@override String get k_1rmkb2w => '推送新聊天訊息';
	@override String get k_1lg375c => '新訊息提醒';
	@override String k_1t0akzp({required Object option1}) => '註銷後，您將無法使用當前賬號，相關數據也將刪除且無法找回。當前賬號ID: $option1';
	@override String get k_1699p6d => '騰訊大廈';
	@override String get k_1ngd60h => '深圳市深南大道10000號';
	@override String get k_1na29vg => '位置訊息維護中';
	@override String get k_1xmms9t => '進群申請列表';
	@override String get k_0dla4vp => '反饋及建議可以加入QQ群組';
	@override String get k_1odrjd1 => '在線時間: 周一到周五，早上10點 - 晚上8點';
	@override String get k_1bh903m => '群組復製成功';
	@override String get k_16264lp => '復製群組號';
	@override String get k_18ger86 => '騰訊雲 · IM';
	@override String get k_1vd70l1 => '服務億級 QQ 用戶的即時通訊技術';
	@override String get k_036phup => '騰訊雲IM';
	@override String get k_003qgkp => '性別';
	@override String get k_0003v6a => '男';
	@override String get k_00043x2 => '女';
	@override String get k_03bcjkv => '未設置';
	@override String get k_11zgnfs => '個人資料';
	@override String get k_003qk66 => '頭像';
	@override String get k_11s0gdz => '修改昵稱';
	@override String get k_0p3j4sd => '僅限中字、字母、數字和下劃線';
	@override String get k_003lhvk => '昵稱';
	@override String get k_15lyvdt => '修改簽名';
	@override String get k_15lx52z => '個性簽名';
	@override String get k_0vylzjp => '這個人很懶，什麽也沒寫';
	@override String get k_1c3us5n => '當前群組不支持@全體成員';
	@override String get k_11k579v => '發言中有非法語句';
	@override String get k_0gfsln9 => '信息已變更';
	@override String get k_0ow4akh => '請根據Demo的README指引，配置百度AK，體驗DEMO的位置消息能力';
	@override String get k_1kzh3lo => '請根據本文檔指引 https://docs.qq.com/doc/DSVliWE9acURta2dL ， 快速體驗位置消息能力';
	@override String get k_161zzkm => '請輸入用戶名';
	@override String get k_1veosyv => '請在環境變量中寫入key';
	@override String get k_03exdnb => '用戶名';
	@override String get k_16kquu8 => '當前目錄';
	@override String get k_0fbvuqs => '開始拷貝';
	@override String get k_16j153h => '騰訊雲IM APP（「本產品」）是由騰訊雲提供的一款測試產品，騰訊雲享有本產品的著作權和所有權。本產品僅用於功能體驗，不得用於任何商業用途。嚴禁在使用中有任何色情、辱罵、暴恐、涉政等違法內容傳播。';
	@override String get k_13ghyf8 => '【安全提示】本 APP 僅用於體驗騰訊雲即時通信 IM 產品功能，不可用於業務洽談與拓展。請勿輕信匯款、中獎等涉及錢款的信息，勿輕易撥打陌生電話，謹防上當受騙。';
	@override String get k_0gt6cro => '點此投訴';
	@override String k_03595fk({required Object option1}) => ' 等$option1人';
	@override String k_1gpzgni({required Object option2}) => '$option2人群';
	@override String get k_02lfg57 => '新群組';
	@override String get k_17ifd8i => '歡迎使用本 APP 體驗騰訊雲 IM 產品服務';
	@override String get k_1f0ms23 => '消息閱讀狀態';
	@override String get k_1c0x9ha => '關閉後，您收發的消息均不帶消息閱讀狀態，您將無法看到對方是否已讀，同時對方也無法看到你是否已讀。';
	@override String get k_1dzhdr5 => '顯示在線狀態';
	@override String get k_0mwsniq => '關閉後，您將不可以在會話列表和通訊錄中看到好友在線或離線的狀態提示。';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'k_03f15qk': 'Blocklist',
			'k_0uc5cnb': 'Beta test in progress. Channel creation is not supported now.',
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
			'k_18g3zdo': 'Tencent Cloud · IM',
			'k_1m8vyp0': 'New contacts',
			'k_0elz70e': 'Group chats',
			'k_18tb4mo': 'No contact',
			'k_18nuh87': 'Contact us',
			'k_1uf134v': 'To provide feedback or suggestions, join our QQ group at 788910197.',
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
			'k_0jtutmw': 'You will not be able to receive messages from this group chat after you exit',
			'k_08k00l9': 'Loading…',
			'k_197r4f7': 'IM service connected successfully',
			'k_1s5xnir': 'Failed to initialize the IM SDK',
			'k_15bxnkw': 'Network connection lost',
			'k_002r09z': 'Channels',
			'k_003nvk2': 'Chats',
			'k_1jwxwgt': 'Connecting…',
			'k_03gm52d': 'Contacts',
			'k_003k7dc': 'Me',
			'k_14yh35u': 'Log in to IM',
			'k_0st7i3e': 'Try IM features such as group chat and voice/video call',
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
			'k_0orhtx0': ' Privacy Agreement ',
			'k_00041m1': 'and',
			'k_0opnzp6': ' User Agreement ',
			'k_161ecly': 'Network unavailable',
			'k_11uz2i8': 'Reconnect network',
			'k_1vhzltr': 'Tencent Cloud IM',
			'k_0j433ys': 'Tencent Cloud TRTC',
			'k_12u8g8l': 'Disclaimer',
			'k_1p0j8i3': 'Instant Messaging (IM) is a test product provided by Tencent Cloud. It is for trying out features, but not for commercial use. To follow regulatory requirements of the authority, voice and video-based interactions performed via IM will be recorded and archived throughout the whole process. It is strictly prohibited to disseminate via IM any pornographic, abusive, violent, political and other noncompliant content.',
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
			'k_0h22snw': 'Voice call',
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
			'k_0mnxjg7': 'Welcome to Tencent Cloud Instant Messaging (IM). To protect the security of your personal information, we have updated the Privacy Policy, mainly improving the specific content and purpose for user information collection and adding the use of third-party SDKs.',
			'k_1545beg': 'Please tap ',
			'k_11x8pvm': 'and read them carefully. If you agree to the content, tap "Accept and continue" to start using our product and service.',
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
			'k_0upijvs': ({required Object message}) => 'Failed to get the discussion forum list: $message',
			'k_0v5hlay': ({required Object message}) => 'Failed to create the topic: $message',
			'k_0em28sp': 'No group chat',
			'k_0owk5ss': ({required Object failedReason}) => 'Login failed: $failedReason',
			'k_0glj9us': 'Initiate conversation',
			'k_1631kyh': 'Create work group',
			'k_1644yii': 'Create public group',
			'k_1fxfx04': 'Create meeting group',
			'k_1cnkqc9': 'Create voice-video group',
			'k_1mw45lz': ({required Object errorReason}) => 'Login failed: $errorReason',
			'k_0epvs61': 'Change skin',
			'k_002ri2g': 'Log in',
			'k_1o7lf2y': ({required Object errorMessage}) => 'Server error: $errorMessage',
			'k_118l7sq': ({required Object requestErrorMessage}) => 'Request error: $requestErrorMessage',
			'k_003nfx9': 'Deep',
			'k_003rvjp': 'Light',
			'k_003rtht': 'Bright',
			'k_003qxiw': 'Fantasy',
			'k_0s5zoi3': ({required Object option1}) => 'Error: $option1',
			'k_0i8egqa': ({required Object option8}) => 'Message obtained: $option8',
			'k_0pokyns': ({required Object option8}) => 'Failed to get the discussion forum list: $option8',
			'k_1y03m8a': ({required Object option8}) => 'Failed to create the topic: $option8',
			'k_1v6uh9c': ({required Object option8}) => 'Login failed: $option8',
			'k_0t5a9hl': ({required Object option1}) => 'Login failed: $option1',
			'k_0k3uv02': ({required Object option8}) => 'Server error: $option8',
			'k_1g9o3kz': ({required Object option8}) => 'Request error: $option8',
			'k_10s6v2i': ' Information Collection Statement ',
			'k_0pasxq8': ' Information Sharing Statement ',
			'k_14cahuz': 'About Tencent Cloud · IM',
			'k_0llnalm': 'SDK Version',
			'k_13dyfii': 'APP Version',
			'k_12h52zh': 'Privacy Policy',
			'k_0fxhhwb': 'User Agreement',
			'k_18z2e6q': 'APP Tencent Cloud · IM(\'this product\') is a test product provided by Tencent Cloud and Tencent Cloud enjoys the copyright and ownership of this product. This product is only used for functional experience and must not be used for any commercial purposes.In order to comply with the regulatory requirements of relevant departments the voice and video interactions of this product are archived throughout the entire voice and video interactions. Any pornography,abusive,violent and politically related content is strictly prohibited during use.',
			'k_0zu7dd7': 'Personal Information Collected',
			'k_0mcqhgh': 'Information Shared with Third Parties',
			'k_12eqaty': 'Confirm to deregister account',
			'k_0ziqsr6': 'Account deregistered successfully',
			'k_002qtgt': 'Deregister Account',
			'k_0rvdu91': ({required Object option1}) => 'After deregister this account, you will be unable to use it, and the related data will be permanently deleted. Current account: $option1',
			'k_15d22qk': 'Deregister Account',
			'k_036uv3f': 'Tencent Cloud · IM',
			'k_167916k': 'WeChat contacts',
			'k_03euwr1': 'Moments',
			'k_0cxccci': 'invites you to a video call',
			'k_06lhh4b': 'invites you to a voice call',
			'k_1ywo9ut': 'Tencent Cloud · IM is developed based on QQ messaging module. Chat, conversation, group, data management and LVB on-screen comments can be easily implemented by Chat SDK. Also, connecting with other products such as whiteboards through signaling messages is supported. We can fully covering your business scenarios. Our Chat SDK can support major platforms and Mini Program, to meet communication needs.',
			'k_0ios26v': 'WeChat is not detected',
			'k_002rflt': 'Delete',
			'k_125ru1w': 'Disband Group',
			'k_0jtzmqa': 'You will not receiving messages from this group after disbanding',
			'k_1jg6d5x': ' Summary of Privacy Policy ',
			'k_0selni4': ' Privacy Policy ',
			'k_003r6vf': 'Log in',
			'k_09khmso': 'Related messages',
			'k_118prbn': 'Search globally',
			'k_03f2zbs': 'Share to ',
			'k_0cfkcaz': 'Chat Message',
			'k_1rmkb2w': 'New Chat Message',
			'k_1lg375c': 'New Chat Message Remind',
			'k_1t0akzp': ({required Object option1}) => 'After deregister this account, you will be unable to use it, and the related data will be permanently deleted. Current account: $option1',
			'k_1699p6d': 'Tencent Building',
			'k_1ngd60h': 'No. 10000 Shennan avenue, Shenzhen',
			'k_1na29vg': 'Location messages is not supported in DEMO temporarily',
			'k_1xmms9t': 'Request to Join Group',
			'k_0dla4vp': 'To provide feedback or suggestions,\n please join our QQ group at',
			'k_1odrjd1': 'Online time: 10 AM to 8 PM, Mon through Fri',
			'k_1bh903m': 'Copied successfully',
			'k_16264lp': 'Copy group number',
			'k_18ger86': 'Tencent Cloud IM',
			'k_1vd70l1': 'Chat SDK serving hundreds of millions of QQ users',
			'k_036phup': 'Tencent Cloud IM',
			'k_003qgkp': 'Gender',
			'k_0003v6a': 'Male',
			'k_00043x2': 'Female',
			'k_03bcjkv': 'Not sett',
			'k_11zgnfs': 'My Profile',
			'k_003qk66': 'Profile Photo',
			'k_11s0gdz': 'Modify nickname',
			'k_0p3j4sd': 'Letters, numbers and underscores only',
			'k_003lhvk': 'Nickname',
			'k_15lyvdt': 'Modify Status',
			'k_15lx52z': 'Status',
			'k_0vylzjp': 'Nothing here',
			'k_1c3us5n': '@ALL is not supported in this group',
			'k_11k579v': 'Illegal sentences in the text',
			'k_0gfsln9': 'Information modified',
			'k_0ow4akh': 'Please configure Baidu AK according to the README guidelines of Demo to experience the location messaging capability of DEMO.',
			'k_1kzh3lo': 'Please follow the guidelines of this document to https://docs.qq.com/doc/DSVliWE9acURta2dL to quickly experience location messaging capabilities.',
			'k_161zzkm': 'Please enter a User ID',
			'k_1veosyv': 'Please config the secret KEY in the environment variable',
			'k_03exdnb': 'User ID',
			'k_16kquu8': 'Current path',
			'k_0fbvuqs': 'Copy',
			'k_16j153h': 'Tencent Cloud IM APP ("this APP") is a product provided by Tencent Cloud aims of demonstration, which enjoys the copyright and ownership of this APP. This APP is for functional experience only and must not be used for any commercial purpose. It is strictly forbidden to spread any illegal content such as pornography, abuse, violence and terrorism, politics and so on.',
			'k_13ghyf8': '[Security Reminder] This APP is only for experiencing the features of Tencent Cloud IM Chat, and cannot be used for any other purposes.',
			'k_0gt6cro': 'Complain here',
			'k_03595fk': ({required Object option1}) => ' and $option1 more',
			'k_1gpzgni': ({required Object option2}) => 'group with $option2 people',
			'k_02lfg57': 'New Group Chat',
			'k_17ifd8i': 'Welcome to Tencent IM Chat SDK and TUIKit on Flutter',
			'k_1f0ms23': 'Message read status',
			'k_1c0x9ha': 'Determines if the reading status shows for your messages and whether others can know about if you read.',
			'k_1dzhdr5': 'Online status',
			'k_0mwsniq': 'Determines if the online status shows for you contacts or friends.',
		};
	}
}

extension on _StringsZhHans {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
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
			'k_0mnxjg7': '欢迎使用腾讯云即时通信 IM，为保护您的个人信息安全，我们更新了《隐私政策》，主要完善了收集用户信息的具体内容和目的、增加了第三方SDK使用等方面的内容。',
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
			'k_1p0j8i3': 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
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
			'k_118l7sq': ({required Object requestErrorMessage}) => '请求错误：$requestErrorMessage',
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
			'k_14cahuz': '关于腾讯云 · IM',
			'k_0llnalm': 'SDK版本号',
			'k_13dyfii': '应用版本号',
			'k_12h52zh': '隐私政策',
			'k_0fxhhwb': '用户协议',
			'k_18z2e6q': 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
			'k_0zu7dd7': '信息收集清单',
			'k_0mcqhgh': '信息共享清单',
			'k_12eqaty': '确认注销账户',
			'k_0ziqsr6': '账户注销成功！',
			'k_002qtgt': '注销',
			'k_0rvdu91': ({required Object option1}) => '注销后，您将无法使用当前账号，相关数据也将删除且无法找回。当前账号ID: $option1',
			'k_15d22qk': '注销账号',
			'k_036uv3f': '腾讯云IM',
			'k_167916k': '微信好友',
			'k_03euwr1': '朋友圈',
			'k_0cxccci': '邀请你视频通话',
			'k_06lhh4b': '邀请你语音通话',
			'k_1ywo9ut': '即时通信 IM (Instant Messaging)基于 QQ 底层 IM 能力开发，仅需植入 SDK 即可轻松集成聊天、会话、群组、资料管理和直播弹幕能力，也支持通过信令消息与白板等其他产品打通，全面覆盖您的业务场景，支持各大平台小程序接入使用，全面满足通信需要',
			'k_0ios26v': '未检测到微信安装',
			'k_002rflt': '删除',
			'k_125ru1w': '解散该群',
			'k_0jtzmqa': '解散后不会接收到此群聊消息',
			'k_1jg6d5x': '《隐私政策摘要》',
			'k_0selni4': '《隐私政策》',
			'k_10s6v2i': '《信息收集清单》',
			'k_0pasxq8': '《信息共享清单》',
			'k_003r6vf': '登录',
			'k_09khmso': '相关聊天记录',
			'k_118prbn': '全局搜索',
			'k_03f2zbs': '分享到',
			'k_0cfkcaz': '消息推送',
			'k_1rmkb2w': '推送新聊天消息',
			'k_1lg375c': '新消息提醒',
			'k_1t0akzp': ({required Object option1}) => '注销后，您将无法使用当前账号，相关数据也将删除且无法找回。当前账号ID: $option1',
			'k_1699p6d': '腾讯大厦',
			'k_1ngd60h': '深圳市深南大道10000号',
			'k_1na29vg': '位置消息维护中',
			'k_1xmms9t': '进群申请列表',
			'k_0dla4vp': '反馈及建议可以加入QQ群',
			'k_1odrjd1': '在线时间: 周一到周五，早上10点 - 晚上8点',
			'k_1bh903m': 'QQ群号复制成功',
			'k_16264lp': '复制群号',
			'k_18ger86': '腾讯云 · IM',
			'k_1vd70l1': '服务亿级 QQ 用户的即时通讯技术',
			'k_036phup': '腾讯云IM',
			'k_003qgkp': '性别',
			'k_0003v6a': '男',
			'k_00043x2': '女',
			'k_03bcjkv': '未设置',
			'k_11zgnfs': '个人资料',
			'k_003qk66': '头像',
			'k_11s0gdz': '修改昵称',
			'k_0p3j4sd': '仅限中字、字母、数字和下划线',
			'k_003lhvk': '昵称',
			'k_15lyvdt': '修改签名',
			'k_15lx52z': '个性签名',
			'k_0vylzjp': '这个人很懒，什么也没写',
			'k_1c3us5n': '当前群组不支持@全体成员',
			'k_11k579v': '发言中有非法语句',
			'k_0gfsln9': '信息已变更',
			'k_0ow4akh': '请根据Demo的README指引，配置百度AK，体验DEMO的位置消息能力',
			'k_1kzh3lo': '请根据本文档指引 https://docs.qq.com/doc/DSVliWE9acURta2dL ， 快速体验位置消息能力',
			'k_161zzkm': '请输入用户名',
			'k_1veosyv': '请在环境变量中写入key',
			'k_03exdnb': '用户名',
			'k_16kquu8': '当前目录',
			'k_0fbvuqs': '开始拷贝',
			'k_16j153h': '腾讯云IM APP（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
			'k_13ghyf8': '【安全提示】本 APP 仅用于体验腾讯云即时通信 IM 产品功能，不可用于业务洽谈与拓展。请勿轻信汇款、中奖等涉及钱款的信息，勿轻易拨打陌生电话，谨防上当受骗。',
			'k_0gt6cro': '点此投诉',
			'k_03595fk': ({required Object option1}) => ' 等$option1人',
			'k_1gpzgni': ({required Object option2}) => '$option2人群',
			'k_02lfg57': '新群聊',
			'k_17ifd8i': '欢迎使用本 APP 体验腾讯云 IM 产品服务',
			'k_1f0ms23': '消息阅读状态',
			'k_1c0x9ha': '关闭后，您收发的消息均不带消息阅读状态，您将无法看到对方是否已读，同时对方也无法看到你是否已读。',
			'k_1dzhdr5': '显示在线状态',
			'k_0mwsniq': '关闭后，您将不可以在会话列表和通讯录中看到好友在线或离线的状态提示。',
		};
	}
}

extension on _StringsZhHant {
	Map<String, dynamic> _buildFlatMap() {
		return <String, dynamic>{
			'k_16758qw': '添加好友',
			'k_0elt0kw': '添加群組',
			'k_03f15qk': '黑名單',
			'k_0s3p3ji': '暫無黑名單',
			'k_0uc5cnb': '我們還在內測中，暫不支持創建頻道。',
			'k_003rzap': '確定',
			'k_003nevv': '取消',
			'k_0s5ey0o': '實時音視訊 TRTC',
			'k_03gpl3d': '大家好',
			'k_0352fjr': '無網絡連接，進入頻道失敗',
			'k_0d7n018': '結束話題',
			'k_0d826hk': '置頂話題',
			'k_15wcgna': '結束成功',
			'k_15wo7xu': '置頂成功',
			'k_02slfpm': ({required Object errorMessage}) => '發生錯誤 $errorMessage',
			'k_003ltgm': '位置',
			'k_0h22snw': '語音通話',
			'k_0h20hg5': '視訊通話',
			'k_002s934': '話題',
			'k_18g3zdo': '雲通信·IM',
			'k_1m8vyp0': '新的聯絡人',
			'k_0elz70e': '我的群組',
			'k_18tb4mo': '無聯絡人',
			'k_18nuh87': '聯絡我們',
			'k_1uf134v': '反饋及建議可以加入QQ群：788910197',
			'k_0xlhhrn': '在線時間，周一到周五，早上10點 - 晚上8點',
			'k_17fmlyf': '清除聊天',
			'k_0dhesoz': '取消置頂',
			'k_002sk7x': '置頂',
			'k_003kv3v': '搜尋',
			'k_0gmpgcg': '暫無會話',
			'k_1m8zuj4': '選擇聯絡人',
			'k_002tu9r': '性能',
			'k_0vwtop2': ({required Object getMsg}) => '獲取到的訊息:$getMsg',
			'k_0upijvs': ({required Object message}) => '獲取討論區列表失敗 $message',
			'k_1tmcw5c': '請完善話題標題',
			'k_1cnmslk': '必須選擇一個標簽',
			'k_0v5hlay': ({required Object message}) => '創建話題失敗 $message',
			'k_0z3ytji': '創建話題成功',
			'k_1a8vem3': '創建者異常',
			'k_0eskkr1': '選擇討論區',
			'k_0d7plb5': '創建話題',
			'k_144t0ho': '---- 相關討論 ----',
			'k_0pnz619': '填寫話題標題',
			'k_136v279': '+標簽（至少添加一個）',
			'k_04hjhvp': '討論區參數異常',
			'k_002r79h': '全部',
			'k_03ejkb6': '已加入',
			'k_172tngw': '話題（未連接）',
			'k_0rnmfc4': '該討論區下暫無話題',
			'k_1pq0ybn': '暫未加入任何話題',
			'k_0bh95w0': '無網絡連接，進入話題失敗',
			'k_002twmj': '群組',
			'k_0em28sp': '暫無群組',
			'k_09kalj0': '清空聊天記錄',
			'k_18qjstb': '轉讓群主',
			'k_14j5iul': '刪除並退出',
			'k_0jtutmw': '退出後不會接收到此群組訊息',
			'k_04dqh36': '暫無新聯絡人',
			'k_08k00l9': '正在載入...',
			'k_197r4f7': '即時通信服務連接成功',
			'k_1s5xnir': '即時通信 SDK初始化失敗',
			'k_0owk5ss': ({required Object failedReason}) => '登入失敗 $failedReason',
			'k_15bxnkw': '網絡連接丟失',
			'k_0glj9us': '發起會話',
			'k_1631kyh': '創建工作群',
			'k_1644yii': '創建社交群',
			'k_1fxfx04': '創建會議群',
			'k_1cnkqc9': '創建直播群',
			'k_002r09z': '頻道',
			'k_003nvk2': '訊息',
			'k_1jwxwgt': '連接中...',
			'k_03gm52d': '通訊錄',
			'k_003k7dc': '我的',
			'k_14yh35u': '登入·即時通信',
			'k_0st7i3e': '體驗群組聊天，音視訊對話等IM功能',
			'k_0cr1atw': '中國大陸',
			'k_0mnxjg7': '歡迎使用騰訊雲即時通信 IM，為保護您的個人信息安全，我們更新了《私隱政策》，主要完善了收集用戶信息的具體內容和目的、增加了第三方SDK使用等方面的內容。',
			'k_1545beg': '請您點擊',
			'k_0opnzp6': '《用戶協議》',
			'k_00041m1': '和',
			'k_0orhtx0': '《私隱協議》',
			'k_11x8pvm': '並仔細閱讀，如您同意以上內容，請點擊「同意並繼續」，開始使用我們的產品與服務！',
			'k_17nw8gq': '同意並繼續',
			'k_1nynslj': '不同意並退出',
			'k_0jsvmjm': '請輸入手機號碼',
			'k_1lg8qh2': '手機號碼格式錯誤',
			'k_03jia4z': '無網絡連接',
			'k_007jqt2': '驗證碼發送成功',
			'k_1a55aib': '驗證碼異常',
			'k_1mw45lz': ({required Object errorReason}) => '登入失敗$errorReason',
			'k_16r3sej': '國家/地區',
			'k_15hlgzr': '選擇你的國家區號',
			'k_1bnmt3h': '請使用英文搜尋',
			'k_03fei8z': '手機號碼',
			'k_03aj66h': '驗證碼',
			'k_1m9jtmw': '請輸入驗證碼',
			'k_0y1wbxk': '獲取驗證碼',
			'k_002ri2g': '登陸',
			'k_161ecly': '當前無網絡',
			'k_11uz2i8': '重試網絡',
			'k_1vhzltr': '騰訊雲即時通信IM',
			'k_0j433ys': '騰訊雲TRTC',
			'k_0epvs61': '更換皮膚',
			'k_12u8g8l': '免責聲明',
			'k_1p0j8i3': 'IM即時通信（「本產品」）是由騰訊雲提供的一款測試產品，騰訊雲享有本產品的著作權和所有權。本產品僅用於功能體驗，不得用於任何商業用途。為配合相關部門監管要求，本產品音視訊互動全程均有錄音錄像存檔，嚴禁在使用中有任何色情、辱罵、暴恐、涉政等違法內容傳播。',
			'k_0k7qoht': '同意任何用戶加好友',
			'k_0gyhkp5': '需要驗證',
			'k_121ruco': '拒絕任何人加好友',
			'k_003kfai': '未知',
			'k_1kvyskd': '無網絡連接，無法修改',
			'k_1j91bvz': 'TUIKIT 為你選擇一個頭像?',
			'k_1wmkneq': '加我為好友時需要驗證',
			'k_1eitsd0': '關於騰訊雲·通信',
			'k_1919d6m': '私隱條例',
			'k_0wqhgor': '個人資料收集清單',
			'k_12rfxml': '第三方資料共用清單',
			'k_131g7q4': '註銷賬戶',
			'k_03fel2u': '版本號',
			'k_16kts8h': '登出',
			'k_129scag': '好友刪除成功',
			'k_094phq4': '好友添加失敗',
			'k_13spdki': '發送訊息',
			'k_1666isy': '清除好友',
			'k_0r8fi93': '好友添加成功',
			'k_02qw14e': '好友申請已發出',
			'k_0n3md5x': '當前用戶在黑名單',
			'k_14c600t': '修改備註',
			'k_1f811a4': '支持數字、英文、下劃線',
			'k_11z7ml4': '詳細資料',
			'k_0003y9x': '無',
			'k_1679vrd': '加為好友',
			'k_1ajt0b1': '獲取當前位置失敗',
			'k_0lhm9xq': '發起檢索成功',
			'k_0fdeled': '發起檢索失敗',
			'k_1yh0a50': 'mapDidLoad-地圖載入完成',
			'k_1t2zg6h': '圖片驗證碼校驗失敗',
			'k_03ibg5h': '星期一',
			'k_03i7hu1': '星期二',
			'k_03iaiks': '星期三',
			'k_03el9pa': '星期四',
			'k_03i7ok1': '星期五',
			'k_03efxyg': '星期六',
			'k_03ibfd2': '星期七',
			'k_1o7lf2y': ({required Object errorMessage}) => '服務器錯誤：$errorMessage',
			'k_118l7sq': ({required Object requestErrorMessage}) => '請求錯誤：$requestErrorMessage',
			'k_003nfx9': '深沈',
			'k_003rvjp': '輕快',
			'k_003rtht': '明媚',
			'k_003qxiw': '夢幻',
			'k_0s5zoi3': ({required Object option1}) => '發生錯誤 $option1',
			'k_0i8egqa': ({required Object option8}) => '獲取到的訊息:$option8',
			'k_0pokyns': ({required Object option8}) => '獲取討論區列表失敗 $option8',
			'k_1y03m8a': ({required Object option8}) => '創建話題失敗 $option8',
			'k_1v6uh9c': ({required Object option8}) => '登入失敗 $option8',
			'k_0t5a9hl': ({required Object option1}) => '登入失敗$option1',
			'k_0k3uv02': ({required Object option8}) => '服務器錯誤：$option8',
			'k_1g9o3kz': ({required Object option8}) => '請求錯誤：$option8',
			'k_14cahuz': '關於騰訊雲 · IM',
			'k_0llnalm': 'SDK版本號',
			'k_13dyfii': '應用版本號',
			'k_12h52zh': '私隱政策',
			'k_0fxhhwb': '用戶協議',
			'k_18z2e6q': 'IM即時通信（「本產品」）是由騰訊雲提供的一款測試產品，騰訊雲享有本產品的著作權和所有權。本產品僅用於功能體驗，不得用於任何商業用途。嚴禁在使用中有任何色情、辱罵、暴恐、涉政等違法內容傳播。',
			'k_0zu7dd7': '個人資料收集清單',
			'k_0mcqhgh': '第三方資料共用清單',
			'k_12eqaty': '確認註銷賬戶',
			'k_0ziqsr6': '賬戶註銷成功！',
			'k_002qtgt': '註銷',
			'k_0rvdu91': ({required Object option1}) => '註銷後，您將無法使用當前賬號，相關數據也將刪除且無法找回。當前賬號ID: $option1',
			'k_15d22qk': '註銷賬號',
			'k_036uv3f': '雲通信IM',
			'k_167916k': '微信好友',
			'k_03euwr1': '朋友圈',
			'k_0cxccci': '邀請你視訊通話',
			'k_06lhh4b': '邀請你語音通話',
			'k_1ywo9ut': '即時通信 IM (Instant Messaging)基於 QQ 底層 IM 能力開發，僅需植入 SDK 即可輕松集成聊天、會話、群組、資料管理和直播彈幕能力，也支持通過信令訊息與白板等其他產品打通，全面覆蓋您的業務場景，支持各大平臺小程序接入使用，全面滿足通信需要',
			'k_0ios26v': '未檢測到微信安裝',
			'k_002rflt': '刪除',
			'k_125ru1w': '解散該群',
			'k_0jtzmqa': '解散後不會接收到此群組訊息',
			'k_1jg6d5x': '《私隱政策摘要》',
			'k_0selni4': '《私隱政策》',
			'k_10s6v2i': '《個人資料收集清單》',
			'k_0pasxq8': '《第三方資料共用清單》',
			'k_003r6vf': '登入',
			'k_09khmso': '相關聊天記錄',
			'k_118prbn': '全局搜尋',
			'k_03f2zbs': '分享到',
			'k_0cfkcaz': '訊息推送',
			'k_1rmkb2w': '推送新聊天訊息',
			'k_1lg375c': '新訊息提醒',
			'k_1t0akzp': ({required Object option1}) => '註銷後，您將無法使用當前賬號，相關數據也將刪除且無法找回。當前賬號ID: $option1',
			'k_1699p6d': '騰訊大廈',
			'k_1ngd60h': '深圳市深南大道10000號',
			'k_1na29vg': '位置訊息維護中',
			'k_1xmms9t': '進群申請列表',
			'k_0dla4vp': '反饋及建議可以加入QQ群組',
			'k_1odrjd1': '在線時間: 周一到周五，早上10點 - 晚上8點',
			'k_1bh903m': '群組復製成功',
			'k_16264lp': '復製群組號',
			'k_18ger86': '騰訊雲 · IM',
			'k_1vd70l1': '服務億級 QQ 用戶的即時通訊技術',
			'k_036phup': '騰訊雲IM',
			'k_003qgkp': '性別',
			'k_0003v6a': '男',
			'k_00043x2': '女',
			'k_03bcjkv': '未設置',
			'k_11zgnfs': '個人資料',
			'k_003qk66': '頭像',
			'k_11s0gdz': '修改昵稱',
			'k_0p3j4sd': '僅限中字、字母、數字和下劃線',
			'k_003lhvk': '昵稱',
			'k_15lyvdt': '修改簽名',
			'k_15lx52z': '個性簽名',
			'k_0vylzjp': '這個人很懶，什麽也沒寫',
			'k_1c3us5n': '當前群組不支持@全體成員',
			'k_11k579v': '發言中有非法語句',
			'k_0gfsln9': '信息已變更',
			'k_0ow4akh': '請根據Demo的README指引，配置百度AK，體驗DEMO的位置消息能力',
			'k_1kzh3lo': '請根據本文檔指引 https://docs.qq.com/doc/DSVliWE9acURta2dL ， 快速體驗位置消息能力',
			'k_161zzkm': '請輸入用戶名',
			'k_1veosyv': '請在環境變量中寫入key',
			'k_03exdnb': '用戶名',
			'k_16kquu8': '當前目錄',
			'k_0fbvuqs': '開始拷貝',
			'k_16j153h': '騰訊雲IM APP（「本產品」）是由騰訊雲提供的一款測試產品，騰訊雲享有本產品的著作權和所有權。本產品僅用於功能體驗，不得用於任何商業用途。嚴禁在使用中有任何色情、辱罵、暴恐、涉政等違法內容傳播。',
			'k_13ghyf8': '【安全提示】本 APP 僅用於體驗騰訊雲即時通信 IM 產品功能，不可用於業務洽談與拓展。請勿輕信匯款、中獎等涉及錢款的信息，勿輕易撥打陌生電話，謹防上當受騙。',
			'k_0gt6cro': '點此投訴',
			'k_03595fk': ({required Object option1}) => ' 等$option1人',
			'k_1gpzgni': ({required Object option2}) => '$option2人群',
			'k_02lfg57': '新群組',
			'k_17ifd8i': '歡迎使用本 APP 體驗騰訊雲 IM 產品服務',
			'k_1f0ms23': '消息閱讀狀態',
			'k_1c0x9ha': '關閉後，您收發的消息均不帶消息閱讀狀態，您將無法看到對方是否已讀，同時對方也無法看到你是否已讀。',
			'k_1dzhdr5': '顯示在線狀態',
			'k_0mwsniq': '關閉後，您將不可以在會話列表和通訊錄中看到好友在線或離線的狀態提示。',
		};
	}
}
