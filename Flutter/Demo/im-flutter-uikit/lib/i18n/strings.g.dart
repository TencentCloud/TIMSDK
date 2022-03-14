
/*
 * Generated file. Do not edit.
 *
 * Locales: 2
 * Strings: 254 (127.0 per locale)
 *
 * Built on 2022-03-05 at 16:50 UTC
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
late _StringsZh _translationsZh = _StringsZh.build();

// extensions for AppLocale

extension AppLocaleExtensions on AppLocale {

	/// Gets the translation instance managed by this library.
	/// [TranslationProvider] is using this instance.
	/// The plural resolvers are set via [LocaleSettings].
	_StringsEn get translations {
		switch (this) {
			case AppLocale.en: return _translationsEn;
			case AppLocale.zh: return _translationsZh;
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
			case AppLocale.zh: return _StringsZh.build();
		}
	}

	String get languageTag {
		switch (this) {
			case AppLocale.en: return 'en';
			case AppLocale.zh: return 'zh';
		}
	}

	Locale get flutterLocale {
		switch (this) {
			case AppLocale.en: return const Locale.fromSubtags(languageCode: 'en');
			case AppLocale.zh: return const Locale.fromSubtags(languageCode: 'zh');
		}
	}
}

extension StringAppLocaleExtensions on String {
	AppLocale? toAppLocale() {
		switch (this) {
			case 'en': return AppLocale.en;
			case 'zh': return AppLocale.zh;
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

	// ignore: unused_field
	late final _StringsEn _root = this;

	// Translations
	String get k_03f15qk => '黑名单';
	String get k_0uc5cnb => '我们还在内测中，暂不支持创建频道。';
	String get k_003nevv => '取消';
	String get k_003rzap => '确定';
	String get k_0s5ey0o => '实时音视频 TRTC';
	String k_0chorra({required Object message}) => '获取列表失败 ${message}';
	String get k_03gpl3d => '大家好';
	String get k_0352fjr => '无网络连接，进入频道失败';
	String get k_0d7n018 => '结束话题';
	String get k_0d826hk => '置顶话题';
	String get k_15wcgna => '结束成功';
	String get k_15wo7xu => '置顶成功';
	String k_1a8zex8({required Object errorMessage}) => '发生错误 ${errorMessage}';
	String get k_1kvftgu => '我是自定义文本消息';
	String get k_0cvagfm => '我是自定义视频消息';
	String get k_1muiqp7 => '我是自定义群提示消息';
	String get k_1ok1knw => '我是自定义图片消息';
	String get k_002s934 => '话题';
	String get k_18g3zdo => '云通信·IM';
	String get k_1m8vyp0 => '新的联系人';
	String get k_0elz70e => '我的群聊';
	String get k_18tb4mo => '无联系人';
	String get k_18nuh87 => '联系我们';
	String get k_1uf134v => '反馈及建议可以加入QQ群：788910197';
	String get k_0xlhhrn => '在线时间，周一到周五，早上10点 - 晚上8点';
	String get k_17fmlyf => '清除聊天';
	String get k_0dhesoz => '取消置顶';
	String get k_002sk7x => '置顶';
	String get k_0gmpgcg => '暂无会话';
	String get k_002tu9r => '性能';
	String k_0welsao({required Object getMsg}) => '获取到的消息:${getMsg}';
	String k_1mvlw3y({required Object message}) => '获取讨论区列表失败 ${message}';
	String get k_1tmcw5c => '请完善话题标题';
	String get k_1cnmslk => '必须选择一个标签';
	String k_0f2a1ks({required Object message}) => '创建话题失败 ${message}';
	String get k_0z3ytji => '创建话题成功';
	String get k_1a8vem3 => '创建者异常';
	String get k_0eskkr1 => '选择讨论区';
	String get k_0d7plb5 => '创建话题';
	String get k_144t0ho => '---- 相关讨论 ----';
	String get k_0pnz619 => '填写话题标题';
	String get k_136v279 => '+标签（至少添加一个）';
	String get k_04hjhvp => '讨论区参数异常';
	String get k_002r79h => '全部';
	String get k_03ejkb6 => '已加入';
	String get k_172tngw => '话题（未连接）';
	String get k_0rnmfc4 => '该讨论区下暂无话题';
	String get k_1pq0ybn => '暂未加入任何话题';
	String get k_0bh95w0 => '无网络连接，进入话题失败';
	String get k_002twmj => '群聊';
	String get k_09kalj0 => '清空聊天记录';
	String get k_18qjstb => '转让群主';
	String get k_14j5iul => '删除并退出';
	String get k_0jtutmw => '退出后不会接收到此群聊消息';
	String get k_08k00l9 => '正在加载...';
	String get k_197r4f7 => '即时通信服务连接成功';
	String get k_0gfsln9 => '信息已变更';
	String get k_1s5xnir => '即时通信 SDK初始化失败';
	String k_0d3vixm({required Object failedReason}) => '登录失败 ${failedReason}';
	String get k_15bxnkw => '网络连接丢失';
	String get k_002r09z => '频道';
	String get k_003nvk2 => '消息';
	String get k_1jwxwgt => '连接中...';
	String get k_03gm52d => '通讯录';
	String get k_003k7dc => '我的';
	String get k_14yh35u => '登录·即时通信';
	String get k_0st7i3e => '体验群组聊天，音视频对话等IM功能';
	String get k_0cr1atw => '中国大陆';
	String get k_0jsvmjm => '请输入手机号';
	String get k_1lg8qh2 => '手机号格式错误';
	String get k_03jia4z => '无网络连接';
	String get k_007jqt2 => '验证码发送成功';
	String get k_0m9ineu => '需要同意隐私与用户协议';
	String get k_1t2zg6h => '图片验证码校验失败';
	String get k_1a55aib => '验证码异常';
	String k_06emov5({required Object errorReason}) => '登录失败${errorReason}';
	String get k_16r3sej => '国家/地区';
	String get k_15hlgzr => '选择你的国家区号';
	String get k_1bnmt3h => '请使用英文搜索';
	String get k_003kv3v => '搜索';
	String get k_03fei8z => '手机号';
	String get k_03aj66h => '验证码';
	String get k_1m9jtmw => '请输入验证码';
	String get k_0y1wbxk => '获取验证码';
	String get k_0o6nt4d => '我已阅读并同意';
	String get k_0orhtx0 => '《隐私协议》';
	String get k_00041m1 => '和';
	String get k_0opnzp6 => '《用户协议》';
	String get k_003r6vf => '登录';
	String get k_161ecly => '当前无网络';
	String get k_11uz2i8 => '重试网络';
	String get k_1vhzltr => '腾讯云即时通信IM';
	String get k_0j433ys => '腾讯云TRTC';
	String get k_12u8g8l => '免责声明';
	String get k_1p0j8i3 => 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。';
	String get k_0k7qoht => '同意任何用户加好友';
	String get k_0gyhkp5 => '需要验证';
	String get k_121ruco => '拒绝任何人加好友';
	String get k_003kfai => '未知';
	String get k_1kvyskd => '无网络连接，无法修改';
	String get k_1wmkneq => '加我为好友时需要验证';
	String get k_1eitsd0 => '关于腾讯云·通信';
	String get k_1919d6m => '隐私条例';
	String get k_16kts8h => '退出登录';
	String get k_129scag => '好友删除成功';
	String get k_094phq4 => '好友添加失败';
	String get k_13spdki => '发送消息';
	String get k_0h22snw => '语音通话';
	String get k_0h20hg5 => '视频通话';
	String get k_1666isy => '清除好友';
	String get k_0r8fi93 => '好友添加成功';
	String get k_02qw14e => '好友申请已发出';
	String get k_0n3md5x => '当前用户在黑名单';
	String get k_14c600t => '修改备注';
	String get k_1f811a4 => '支持数字、英文、下划线';
	String get k_11z7ml4 => '详细资料';
	String get k_0003y9x => '无';
	String get k_1679vrd => '加为好友';
	String get k_03ibg5h => '星期一';
	String get k_03i7hu1 => '星期二';
	String get k_03iaiks => '星期三';
	String get k_03el9pa => '星期四';
	String get k_03i7ok1 => '星期五';
	String get k_03efxyg => '星期六';
	String get k_03ibfd2 => '星期七';
	String k_0fc9uho({required Object errorMessage}) => '服务器错误：${errorMessage}';
	String k_0mmwekc({required Object requestErrorMessage}) => '请求错误：${requestErrorMessage}';
}

// Path: <root>
class _StringsZh implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsZh.build();

	/// Access flat map
	@override dynamic operator[](String key) => _flatMap[key];

	// Internal flat map initialized lazily
	late final Map<String, dynamic> _flatMap = _buildFlatMap();

	// ignore: unused_field
	@override late final _StringsZh _root = this;

	// Translations
	@override String get k_03f15qk => '黑名单';
	@override String get k_0uc5cnb => '我们还在内测中，暂不支持创建频道。';
	@override String get k_003nevv => '取消';
	@override String get k_003rzap => '确定';
	@override String get k_0s5ey0o => '实时音视频 TRTC';
	@override String k_0chorra({required Object message}) => '获取列表失败 ${message}';
	@override String get k_03gpl3d => '大家好';
	@override String get k_0352fjr => '无网络连接，进入频道失败';
	@override String get k_0d7n018 => '结束话题';
	@override String get k_0d826hk => '置顶话题';
	@override String get k_15wcgna => '结束成功';
	@override String get k_15wo7xu => '置顶成功';
	@override String k_1a8zex8({required Object errorMessage}) => '发生错误 ${errorMessage}';
	@override String get k_1kvftgu => '我是自定义文本消息';
	@override String get k_0cvagfm => '我是自定义视频消息';
	@override String get k_1muiqp7 => '我是自定义群提示消息';
	@override String get k_1ok1knw => '我是自定义图片消息';
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
	@override String get k_0gmpgcg => '暂无会话';
	@override String get k_002tu9r => '性能';
	@override String k_0welsao({required Object getMsg}) => '获取到的消息:${getMsg}';
	@override String k_1mvlw3y({required Object message}) => '获取讨论区列表失败 ${message}';
	@override String get k_1tmcw5c => '请完善话题标题';
	@override String get k_1cnmslk => '必须选择一个标签';
	@override String k_0f2a1ks({required Object message}) => '创建话题失败 ${message}';
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
	@override String get k_09kalj0 => '清空聊天记录';
	@override String get k_18qjstb => '转让群主';
	@override String get k_14j5iul => '删除并退出';
	@override String get k_0jtutmw => '退出后不会接收到此群聊消息';
	@override String get k_08k00l9 => '正在加载...';
	@override String get k_197r4f7 => '即时通信服务连接成功';
	@override String get k_0gfsln9 => '信息已变更';
	@override String get k_1s5xnir => '即时通信 SDK初始化失败';
	@override String k_0d3vixm({required Object failedReason}) => '登录失败 ${failedReason}';
	@override String get k_15bxnkw => '网络连接丢失';
	@override String get k_002r09z => '频道';
	@override String get k_003nvk2 => '消息';
	@override String get k_1jwxwgt => '连接中...';
	@override String get k_03gm52d => '通讯录';
	@override String get k_003k7dc => '我的';
	@override String get k_14yh35u => '登录·即时通信';
	@override String get k_0st7i3e => '体验群组聊天，音视频对话等IM功能';
	@override String get k_0cr1atw => '中国大陆';
	@override String get k_0jsvmjm => '请输入手机号';
	@override String get k_1lg8qh2 => '手机号格式错误';
	@override String get k_03jia4z => '无网络连接';
	@override String get k_007jqt2 => '验证码发送成功';
	@override String get k_0m9ineu => '需要同意隐私与用户协议';
	@override String get k_1t2zg6h => '图片验证码校验失败';
	@override String get k_1a55aib => '验证码异常';
	@override String k_06emov5({required Object errorReason}) => '登录失败${errorReason}';
	@override String get k_16r3sej => '国家/地区';
	@override String get k_15hlgzr => '选择你的国家区号';
	@override String get k_1bnmt3h => '请使用英文搜索';
	@override String get k_003kv3v => '搜索';
	@override String get k_03fei8z => '手机号';
	@override String get k_03aj66h => '验证码';
	@override String get k_1m9jtmw => '请输入验证码';
	@override String get k_0y1wbxk => '获取验证码';
	@override String get k_0o6nt4d => '我已阅读并同意';
	@override String get k_0orhtx0 => '《隐私协议》';
	@override String get k_00041m1 => '和';
	@override String get k_0opnzp6 => '《用户协议》';
	@override String get k_003r6vf => '登录';
	@override String get k_161ecly => '当前无网络';
	@override String get k_11uz2i8 => '重试网络';
	@override String get k_1vhzltr => '腾讯云即时通信IM';
	@override String get k_0j433ys => '腾讯云TRTC';
	@override String get k_12u8g8l => '免责声明';
	@override String get k_1p0j8i3 => 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。';
	@override String get k_0k7qoht => '同意任何用户加好友';
	@override String get k_0gyhkp5 => '需要验证';
	@override String get k_121ruco => '拒绝任何人加好友';
	@override String get k_003kfai => '未知';
	@override String get k_1kvyskd => '无网络连接，无法修改';
	@override String get k_1wmkneq => '加我为好友时需要验证';
	@override String get k_1eitsd0 => '关于腾讯云·通信';
	@override String get k_1919d6m => '隐私条例';
	@override String get k_16kts8h => '退出登录';
	@override String get k_129scag => '好友删除成功';
	@override String get k_094phq4 => '好友添加失败';
	@override String get k_13spdki => '发送消息';
	@override String get k_0h22snw => '语音通话';
	@override String get k_0h20hg5 => '视频通话';
	@override String get k_1666isy => '清除好友';
	@override String get k_0r8fi93 => '好友添加成功';
	@override String get k_02qw14e => '好友申请已发出';
	@override String get k_0n3md5x => '当前用户在黑名单';
	@override String get k_14c600t => '修改备注';
	@override String get k_1f811a4 => '支持数字、英文、下划线';
	@override String get k_11z7ml4 => '详细资料';
	@override String get k_0003y9x => '无';
	@override String get k_1679vrd => '加为好友';
	@override String get k_03ibg5h => '星期一';
	@override String get k_03i7hu1 => '星期二';
	@override String get k_03iaiks => '星期三';
	@override String get k_03el9pa => '星期四';
	@override String get k_03i7ok1 => '星期五';
	@override String get k_03efxyg => '星期六';
	@override String get k_03ibfd2 => '星期七';
	@override String k_0fc9uho({required Object errorMessage}) => '服务器错误：${errorMessage}';
	@override String k_0mmwekc({required Object requestErrorMessage}) => '请求错误：${requestErrorMessage}';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return {
			'k_03f15qk': '黑名单',
			'k_0uc5cnb': '我们还在内测中，暂不支持创建频道。',
			'k_003nevv': '取消',
			'k_003rzap': '确定',
			'k_0s5ey0o': '实时音视频 TRTC',
			'k_0chorra': ({required Object message}) => '获取列表失败 ${message}',
			'k_03gpl3d': '大家好',
			'k_0352fjr': '无网络连接，进入频道失败',
			'k_0d7n018': '结束话题',
			'k_0d826hk': '置顶话题',
			'k_15wcgna': '结束成功',
			'k_15wo7xu': '置顶成功',
			'k_1a8zex8': ({required Object errorMessage}) => '发生错误 ${errorMessage}',
			'k_1kvftgu': '我是自定义文本消息',
			'k_0cvagfm': '我是自定义视频消息',
			'k_1muiqp7': '我是自定义群提示消息',
			'k_1ok1knw': '我是自定义图片消息',
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
			'k_0gmpgcg': '暂无会话',
			'k_002tu9r': '性能',
			'k_0welsao': ({required Object getMsg}) => '获取到的消息:${getMsg}',
			'k_1mvlw3y': ({required Object message}) => '获取讨论区列表失败 ${message}',
			'k_1tmcw5c': '请完善话题标题',
			'k_1cnmslk': '必须选择一个标签',
			'k_0f2a1ks': ({required Object message}) => '创建话题失败 ${message}',
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
			'k_09kalj0': '清空聊天记录',
			'k_18qjstb': '转让群主',
			'k_14j5iul': '删除并退出',
			'k_0jtutmw': '退出后不会接收到此群聊消息',
			'k_08k00l9': '正在加载...',
			'k_197r4f7': '即时通信服务连接成功',
			'k_0gfsln9': '信息已变更',
			'k_1s5xnir': '即时通信 SDK初始化失败',
			'k_0d3vixm': ({required Object failedReason}) => '登录失败 ${failedReason}',
			'k_15bxnkw': '网络连接丢失',
			'k_002r09z': '频道',
			'k_003nvk2': '消息',
			'k_1jwxwgt': '连接中...',
			'k_03gm52d': '通讯录',
			'k_003k7dc': '我的',
			'k_14yh35u': '登录·即时通信',
			'k_0st7i3e': '体验群组聊天，音视频对话等IM功能',
			'k_0cr1atw': '中国大陆',
			'k_0jsvmjm': '请输入手机号',
			'k_1lg8qh2': '手机号格式错误',
			'k_03jia4z': '无网络连接',
			'k_007jqt2': '验证码发送成功',
			'k_0m9ineu': '需要同意隐私与用户协议',
			'k_1t2zg6h': '图片验证码校验失败',
			'k_1a55aib': '验证码异常',
			'k_06emov5': ({required Object errorReason}) => '登录失败${errorReason}',
			'k_16r3sej': '国家/地区',
			'k_15hlgzr': '选择你的国家区号',
			'k_1bnmt3h': '请使用英文搜索',
			'k_003kv3v': '搜索',
			'k_03fei8z': '手机号',
			'k_03aj66h': '验证码',
			'k_1m9jtmw': '请输入验证码',
			'k_0y1wbxk': '获取验证码',
			'k_0o6nt4d': '我已阅读并同意',
			'k_0orhtx0': '《隐私协议》',
			'k_00041m1': '和',
			'k_0opnzp6': '《用户协议》',
			'k_003r6vf': '登录',
			'k_161ecly': '当前无网络',
			'k_11uz2i8': '重试网络',
			'k_1vhzltr': '腾讯云即时通信IM',
			'k_0j433ys': '腾讯云TRTC',
			'k_12u8g8l': '免责声明',
			'k_1p0j8i3': 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
			'k_0k7qoht': '同意任何用户加好友',
			'k_0gyhkp5': '需要验证',
			'k_121ruco': '拒绝任何人加好友',
			'k_003kfai': '未知',
			'k_1kvyskd': '无网络连接，无法修改',
			'k_1wmkneq': '加我为好友时需要验证',
			'k_1eitsd0': '关于腾讯云·通信',
			'k_1919d6m': '隐私条例',
			'k_16kts8h': '退出登录',
			'k_129scag': '好友删除成功',
			'k_094phq4': '好友添加失败',
			'k_13spdki': '发送消息',
			'k_0h22snw': '语音通话',
			'k_0h20hg5': '视频通话',
			'k_1666isy': '清除好友',
			'k_0r8fi93': '好友添加成功',
			'k_02qw14e': '好友申请已发出',
			'k_0n3md5x': '当前用户在黑名单',
			'k_14c600t': '修改备注',
			'k_1f811a4': '支持数字、英文、下划线',
			'k_11z7ml4': '详细资料',
			'k_0003y9x': '无',
			'k_1679vrd': '加为好友',
			'k_03ibg5h': '星期一',
			'k_03i7hu1': '星期二',
			'k_03iaiks': '星期三',
			'k_03el9pa': '星期四',
			'k_03i7ok1': '星期五',
			'k_03efxyg': '星期六',
			'k_03ibfd2': '星期七',
			'k_0fc9uho': ({required Object errorMessage}) => '服务器错误：${errorMessage}',
			'k_0mmwekc': ({required Object requestErrorMessage}) => '请求错误：${requestErrorMessage}',
		};
	}
}

extension on _StringsZh {
	Map<String, dynamic> _buildFlatMap() {
		return {
			'k_03f15qk': '黑名单',
			'k_0uc5cnb': '我们还在内测中，暂不支持创建频道。',
			'k_003nevv': '取消',
			'k_003rzap': '确定',
			'k_0s5ey0o': '实时音视频 TRTC',
			'k_0chorra': ({required Object message}) => '获取列表失败 ${message}',
			'k_03gpl3d': '大家好',
			'k_0352fjr': '无网络连接，进入频道失败',
			'k_0d7n018': '结束话题',
			'k_0d826hk': '置顶话题',
			'k_15wcgna': '结束成功',
			'k_15wo7xu': '置顶成功',
			'k_1a8zex8': ({required Object errorMessage}) => '发生错误 ${errorMessage}',
			'k_1kvftgu': '我是自定义文本消息',
			'k_0cvagfm': '我是自定义视频消息',
			'k_1muiqp7': '我是自定义群提示消息',
			'k_1ok1knw': '我是自定义图片消息',
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
			'k_0gmpgcg': '暂无会话',
			'k_002tu9r': '性能',
			'k_0welsao': ({required Object getMsg}) => '获取到的消息:${getMsg}',
			'k_1mvlw3y': ({required Object message}) => '获取讨论区列表失败 ${message}',
			'k_1tmcw5c': '请完善话题标题',
			'k_1cnmslk': '必须选择一个标签',
			'k_0f2a1ks': ({required Object message}) => '创建话题失败 ${message}',
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
			'k_09kalj0': '清空聊天记录',
			'k_18qjstb': '转让群主',
			'k_14j5iul': '删除并退出',
			'k_0jtutmw': '退出后不会接收到此群聊消息',
			'k_08k00l9': '正在加载...',
			'k_197r4f7': '即时通信服务连接成功',
			'k_0gfsln9': '信息已变更',
			'k_1s5xnir': '即时通信 SDK初始化失败',
			'k_0d3vixm': ({required Object failedReason}) => '登录失败 ${failedReason}',
			'k_15bxnkw': '网络连接丢失',
			'k_002r09z': '频道',
			'k_003nvk2': '消息',
			'k_1jwxwgt': '连接中...',
			'k_03gm52d': '通讯录',
			'k_003k7dc': '我的',
			'k_14yh35u': '登录·即时通信',
			'k_0st7i3e': '体验群组聊天，音视频对话等IM功能',
			'k_0cr1atw': '中国大陆',
			'k_0jsvmjm': '请输入手机号',
			'k_1lg8qh2': '手机号格式错误',
			'k_03jia4z': '无网络连接',
			'k_007jqt2': '验证码发送成功',
			'k_0m9ineu': '需要同意隐私与用户协议',
			'k_1t2zg6h': '图片验证码校验失败',
			'k_1a55aib': '验证码异常',
			'k_06emov5': ({required Object errorReason}) => '登录失败${errorReason}',
			'k_16r3sej': '国家/地区',
			'k_15hlgzr': '选择你的国家区号',
			'k_1bnmt3h': '请使用英文搜索',
			'k_003kv3v': '搜索',
			'k_03fei8z': '手机号',
			'k_03aj66h': '验证码',
			'k_1m9jtmw': '请输入验证码',
			'k_0y1wbxk': '获取验证码',
			'k_0o6nt4d': '我已阅读并同意',
			'k_0orhtx0': '《隐私协议》',
			'k_00041m1': '和',
			'k_0opnzp6': '《用户协议》',
			'k_003r6vf': '登录',
			'k_161ecly': '当前无网络',
			'k_11uz2i8': '重试网络',
			'k_1vhzltr': '腾讯云即时通信IM',
			'k_0j433ys': '腾讯云TRTC',
			'k_12u8g8l': '免责声明',
			'k_1p0j8i3': 'IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。',
			'k_0k7qoht': '同意任何用户加好友',
			'k_0gyhkp5': '需要验证',
			'k_121ruco': '拒绝任何人加好友',
			'k_003kfai': '未知',
			'k_1kvyskd': '无网络连接，无法修改',
			'k_1wmkneq': '加我为好友时需要验证',
			'k_1eitsd0': '关于腾讯云·通信',
			'k_1919d6m': '隐私条例',
			'k_16kts8h': '退出登录',
			'k_129scag': '好友删除成功',
			'k_094phq4': '好友添加失败',
			'k_13spdki': '发送消息',
			'k_0h22snw': '语音通话',
			'k_0h20hg5': '视频通话',
			'k_1666isy': '清除好友',
			'k_0r8fi93': '好友添加成功',
			'k_02qw14e': '好友申请已发出',
			'k_0n3md5x': '当前用户在黑名单',
			'k_14c600t': '修改备注',
			'k_1f811a4': '支持数字、英文、下划线',
			'k_11z7ml4': '详细资料',
			'k_0003y9x': '无',
			'k_1679vrd': '加为好友',
			'k_03ibg5h': '星期一',
			'k_03i7hu1': '星期二',
			'k_03iaiks': '星期三',
			'k_03el9pa': '星期四',
			'k_03i7ok1': '星期五',
			'k_03efxyg': '星期六',
			'k_03ibfd2': '星期七',
			'k_0fc9uho': ({required Object errorMessage}) => '服务器错误：${errorMessage}',
			'k_0mmwekc': ({required Object requestErrorMessage}) => '请求错误：${requestErrorMessage}',
		};
	}
}
