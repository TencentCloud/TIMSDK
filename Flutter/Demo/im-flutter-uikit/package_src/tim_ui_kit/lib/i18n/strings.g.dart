
/*
 * Generated file. Do not edit.
 *
 * Locales: 2
 * Strings: 340 (170.0 per locale)
 *
 * Built on 2022-03-01 at 11:28 UTC
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
	String get k_1fdhj9g => '该版本不支持此消息';
	String get k_06pujtm => '同意任何用户添加好友';
	String get k_0gyhkp5 => '需要验证';
	String get k_121ruco => '拒绝任何人加好友';
	String get k_05nspni => '自定义字段';
	String get k_03fchyy => '群头像';
	String get k_03i9mfe => '群简介';
	String get k_03agq58 => '群名称';
	String get k_039xqny => '群通知';
	String get k_003tr0a => '群主';
	String k_1xd7osu({required Object s}) => '${s}为 ';
	String k_0u93xpy({required Object opUserNickName}) => '${opUserNickName}修改';
	String k_10oyylx({required Object opUserNickName}) => '${opUserNickName}退出群聊';
	String k_1ss45p9({required Object invitedMemberString}) => '邀请${invitedMemberString}加入群组';
	String k_1w3kivl({required Object invitedMemberString}) => '将${invitedMemberString}踢出群组';
	String k_024xosz({required Object joinedMemberString}) => '用户${joinedMemberString}加入了群聊';
	String get k_002wddw => '禁言';
	String get k_0got6f7 => '解除禁言';
	String k_0nj3nkq({required Object userName}) => '${userName} 被';
	String k_0wn1wy1({required Object operationType}) => '系统消息 ${operationType}';
	String get k_1uaqed6 => '[自定义]';
	String get k_0z2z7rx => '[语音]';
	String get k_0y39ngu => '[表情]';
	String k_0nckgoh({required Object fileName}) => '[文件] ${fileName}';
	String get k_0y1a2my => '[图片]';
	String get k_0z4fib8 => '[视频]';
	String get k_0y24mcg => '[位置]';
	String get k_0pewpd1 => '[聊天记录]';
	String get k_13s8d9p => '未知消息';
	String get k_003qkx2 => '日历';
	String get k_003n2pz => '相机';
	String get k_03idjo0 => '联系人';
	String get k_003ltgm => '位置';
	String get k_02k3k86 => '麦克风';
	String get k_003pm7l => '相册';
	String get k_15ao57x => '相册写入';
	String get k_164m3jd => '本地存储';
	String k_1ut348h({required Object yoursItem}) => '“IM云通信”想访问您的${yoursItem}';
	String get k_03r6qyx => '我们需要您的同意才能获取信息';
	String get k_02noktt => '不允许';
	String get k_00043x4 => '好';
	String get k_003qzac => '昨天';
	String get k_003r39d => '前天';
	String get k_03fqp9o => '星期天';
	String get k_03ibg5h => '星期一';
	String get k_03i7hu1 => '星期二';
	String get k_03iaiks => '星期三';
	String get k_03el9pa => '星期四';
	String get k_03i7ok1 => '星期五';
	String get k_03efxyg => '星期六';
	String k_0bobr6r({required Object diffMinutes}) => '${diffMinutes} 分钟前';
	String get k_003q7ba => '下午';
	String get k_003q7bb => '上午';
	String get k_003pu3h => '现在';
	String k_0fh0id2({required Object yesterday}) => '昨天 ${yesterday}';
	String get k_002rflt => '删除';
	String get k_003q5fi => '复制';
	String get k_003prq0 => '转发';
	String get k_002r1h2 => '多选';
	String get k_003j708 => '引用';
	String get k_003pqpr => '撤回';
	String get k_03ezhho => '已复制';
	String get k_11ctfsz => '暂未实现';
	String get k_1hbjg5g => '[群系统消息]';
	String get k_03tvswb => '[未知消息]';
	String k_0gt5q2o({required Object displayName}) => '${displayName}撤回了一条消息';
	String get k_0003z7x => '您';
	String get k_002wfe4 => '已读';
	String get k_002wjlg => '未读';
	String get k_1jxdqeu => '发送中...';
	String get k_0uu95o6 => '“IM云通信”暂不可以打开此类文件，你可以使用其他应用打开并预览';
	String get k_003nevv => '取消';
	String get k_001nmhu => '用其他应用打开';
	String get k_105682d => '图片加载失败';
	String get k_0pytyeu => '图片保存成功';
	String get k_0akceel => '图片保存失败';
	String get k_003rk1s => '保存';
	String get k_04a0awq => '[语音消息]';
	String get k_0pzwbmg => '视频保存成功';
	String get k_0aktupv => '视频保存失败';
	String get k_105c3y3 => '视频加载失败';
	String get k_176rzr7 => '聊天记录';
	String get k_002r305 => '发送';
	String get k_003kcka => '照相';
	String get k_002s86q => '视频';
	String get k_003n8b0 => '拍摄';
	String get k_003kt0a => '相片';
	String get k_003tnp0 => '文件';
	String get k_0h22snw => '语音通话';
	String get k_003km5r => '名片';
	String get k_03cfe3p => '戳一戳';
	String get k_0ylosxn => '自定义消息';
	String get k_0jhdhtp => '发送失败,视频不能大于100MB';
	String k_1i3evae({required Object successPath}) => '选择成功${successPath}';
	String get k_0am7r68 => '手指上滑，取消发送';
	String get k_13dsw4l => '松开取消';
	String get k_15jl6qw => '说话时间太短!';
	String get k_0gx7vl6 => '按住说话';
	String get k_15dlafd => '逐条转发';
	String get k_15dryxy => '合并转发';
	String get k_1eyhieh => '确定删除已选消息';
	String get k_17fmlyf => '清除聊天';
	String get k_0dhesoz => '取消置顶';
	String get k_002sk7x => '置顶';
	String k_1s03bj1({required Object messageString}) => '${messageString}[有人@我]';
	String k_050tjt8({required Object messageString}) => '${messageString}[@所有人]';
	String get k_003kfai => '未知';
	String get k_13dq4an => '自动审批';
	String get k_0l13cde => '管理员审批';
	String get k_11y8c6a => '禁止加群';
	String get k_16payqf => '加群方式';
	String get k_0vzvn8r => '修改群名称';
	String get k_003rzap => '确定';
	String get k_038lh6u => '群管理';
	String get k_0k5wyiy => '设置管理员';
	String get k_0goiuwk => '全员禁言';
	String get k_1g889xx => '全员禁言开启后，只允许群主和管理员发言。';
	String get k_0wlrefq => '添加需要禁言的群成员';
	String get k_0goox5g => '设置禁言';
	String get k_08daijh => '成功取消管理员身份';
	String k_1fd5tta({required Object adminNum}) => '管理员 (${adminNum}/10)';
	String get k_0k5u935 => '添加管理员';
	String get k_003ngex => '完成';
	String get k_03enyx5 => '群成员';
	String get k_03erpei => '管理员';
	String get k_0qi9tno => '群主、管理员';
	String get k_003kv3v => '搜索';
	String k_01z3dft({required Object groupMemberNum}) => '群成员(${groupMemberNum}人)';
	String k_1vhgizy({required Object memberCount}) => '${memberCount}人';
	String get k_0ef2a12 => '修改我的群昵称';
	String get k_1aajych => '仅限中文、字母、数字和下划线，2-20个字';
	String get k_137pab5 => '我的群昵称';
	String get k_0ivim6d => '暂无群公告';
	String get k_03eq6cn => '群公告';
	String get k_002vxya => '编辑';
	String get k_03gu05e => '聊天室';
	String get k_03b4f3p => '会议群';
	String get k_03avj1p => '公开群';
	String get k_03asq2g => '工作群';
	String get k_03b3hbi => '未知群';
	String get k_03es1ox => '群类型';
	String get k_003mz1i => '同意';
	String get k_003lpre => '拒绝';
	String get k_003qk66 => '头像';
	String get k_003lhvk => '昵称';
	String get k_003ps50 => '账号';
	String get k_15lx52z => '个性签名';
	String get k_003qgkp => '性别';
	String get k_003m6hr => '生日';
	String get k_0003v6a => '男';
	String get k_00043x2 => '女';
	String get k_03bcjkv => '未设置';
	String get k_11s0gdz => '修改昵称';
	String get k_0p3j4sd => '仅限中字、字母、数字和下划线';
	String get k_15lyvdt => '修改签名';
	String get k_0vylzjp => '这个人很懒，什么也没写';
	String get k_1hs7ese => '等上线再改这个';
	String get k_03exjk7 => '备注名';
	String get k_0s3skfd => '加入黑名单';
	String get k_17fpl3y => '置顶聊天';
	String get k_0p3b31s => '修改备注名';
	String get k_0003y9x => '无';
	String get k_11zgnfs => '个人资料';
	String k_1h42emf({required Object signature}) => '个性签名: ${signature}';
	String get k_1tez2xl => '暂无个性签名';
	String k_0vdrbki({required Object receiver}) => '与${receiver}的聊天记录';
	String get k_0vjj2kp => '群聊的聊天记录';
	String get k_003n2rp => '选择';
	String get k_1m9exwh => '最近联系人';
	String get k_119nwqr => '输入不能为空';
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
	@override String get k_1fdhj9g => '该版本不支持此消息';
	@override String get k_06pujtm => '同意任何用户添加好友';
	@override String get k_0gyhkp5 => '需要验证';
	@override String get k_121ruco => '拒绝任何人加好友';
	@override String get k_05nspni => '自定义字段';
	@override String get k_03fchyy => '群头像';
	@override String get k_03i9mfe => '群简介';
	@override String get k_03agq58 => '群名称';
	@override String get k_039xqny => '群通知';
	@override String get k_003tr0a => '群主';
	@override String k_1xd7osu({required Object s}) => '${s}为 ';
	@override String k_0u93xpy({required Object opUserNickName}) => '${opUserNickName}修改';
	@override String k_10oyylx({required Object opUserNickName}) => '${opUserNickName}退出群聊';
	@override String k_1ss45p9({required Object invitedMemberString}) => '邀请${invitedMemberString}加入群组';
	@override String k_1w3kivl({required Object invitedMemberString}) => '将${invitedMemberString}踢出群组';
	@override String k_024xosz({required Object joinedMemberString}) => '用户${joinedMemberString}加入了群聊';
	@override String get k_002wddw => '禁言';
	@override String get k_0got6f7 => '解除禁言';
	@override String k_0nj3nkq({required Object userName}) => '${userName} 被';
	@override String k_0wn1wy1({required Object operationType}) => '系统消息 ${operationType}';
	@override String get k_1uaqed6 => '[自定义]';
	@override String get k_0z2z7rx => '[语音]';
	@override String get k_0y39ngu => '[表情]';
	@override String k_0nckgoh({required Object fileName}) => '[文件] ${fileName}';
	@override String get k_0y1a2my => '[图片]';
	@override String get k_0z4fib8 => '[视频]';
	@override String get k_0y24mcg => '[位置]';
	@override String get k_0pewpd1 => '[聊天记录]';
	@override String get k_13s8d9p => '未知消息';
	@override String get k_003qkx2 => '日历';
	@override String get k_003n2pz => '相机';
	@override String get k_03idjo0 => '联系人';
	@override String get k_003ltgm => '位置';
	@override String get k_02k3k86 => '麦克风';
	@override String get k_003pm7l => '相册';
	@override String get k_15ao57x => '相册写入';
	@override String get k_164m3jd => '本地存储';
	@override String k_1ut348h({required Object yoursItem}) => '“IM云通信”想访问您的${yoursItem}';
	@override String get k_03r6qyx => '我们需要您的同意才能获取信息';
	@override String get k_02noktt => '不允许';
	@override String get k_00043x4 => '好';
	@override String get k_003qzac => '昨天';
	@override String get k_003r39d => '前天';
	@override String get k_03fqp9o => '星期天';
	@override String get k_03ibg5h => '星期一';
	@override String get k_03i7hu1 => '星期二';
	@override String get k_03iaiks => '星期三';
	@override String get k_03el9pa => '星期四';
	@override String get k_03i7ok1 => '星期五';
	@override String get k_03efxyg => '星期六';
	@override String k_0bobr6r({required Object diffMinutes}) => '${diffMinutes} 分钟前';
	@override String get k_003q7ba => '下午';
	@override String get k_003q7bb => '上午';
	@override String get k_003pu3h => '现在';
	@override String k_0fh0id2({required Object yesterday}) => '昨天 ${yesterday}';
	@override String get k_002rflt => '删除';
	@override String get k_003q5fi => '复制';
	@override String get k_003prq0 => '转发';
	@override String get k_002r1h2 => '多选';
	@override String get k_003j708 => '引用';
	@override String get k_003pqpr => '撤回';
	@override String get k_03ezhho => '已复制';
	@override String get k_11ctfsz => '暂未实现';
	@override String get k_1hbjg5g => '[群系统消息]';
	@override String get k_03tvswb => '[未知消息]';
	@override String k_0gt5q2o({required Object displayName}) => '${displayName}撤回了一条消息';
	@override String get k_0003z7x => '您';
	@override String get k_002wfe4 => '已读';
	@override String get k_002wjlg => '未读';
	@override String get k_1jxdqeu => '发送中...';
	@override String get k_0uu95o6 => '“IM云通信”暂不可以打开此类文件，你可以使用其他应用打开并预览';
	@override String get k_003nevv => '取消';
	@override String get k_001nmhu => '用其他应用打开';
	@override String get k_105682d => '图片加载失败';
	@override String get k_0pytyeu => '图片保存成功';
	@override String get k_0akceel => '图片保存失败';
	@override String get k_003rk1s => '保存';
	@override String get k_04a0awq => '[语音消息]';
	@override String get k_0pzwbmg => '视频保存成功';
	@override String get k_0aktupv => '视频保存失败';
	@override String get k_105c3y3 => '视频加载失败';
	@override String get k_176rzr7 => '聊天记录';
	@override String get k_002r305 => '发送';
	@override String get k_003kcka => '照相';
	@override String get k_002s86q => '视频';
	@override String get k_003n8b0 => '拍摄';
	@override String get k_003kt0a => '相片';
	@override String get k_003tnp0 => '文件';
	@override String get k_0h22snw => '语音通话';
	@override String get k_003km5r => '名片';
	@override String get k_03cfe3p => '戳一戳';
	@override String get k_0ylosxn => '自定义消息';
	@override String get k_0jhdhtp => '发送失败,视频不能大于100MB';
	@override String k_1i3evae({required Object successPath}) => '选择成功${successPath}';
	@override String get k_0am7r68 => '手指上滑，取消发送';
	@override String get k_13dsw4l => '松开取消';
	@override String get k_15jl6qw => '说话时间太短!';
	@override String get k_0gx7vl6 => '按住说话';
	@override String get k_15dlafd => '逐条转发';
	@override String get k_15dryxy => '合并转发';
	@override String get k_1eyhieh => '确定删除已选消息';
	@override String get k_17fmlyf => '清除聊天';
	@override String get k_0dhesoz => '取消置顶';
	@override String get k_002sk7x => '置顶';
	@override String k_1s03bj1({required Object messageString}) => '${messageString}[有人@我]';
	@override String k_050tjt8({required Object messageString}) => '${messageString}[@所有人]';
	@override String get k_003kfai => '未知';
	@override String get k_13dq4an => '自动审批';
	@override String get k_0l13cde => '管理员审批';
	@override String get k_11y8c6a => '禁止加群';
	@override String get k_16payqf => '加群方式';
	@override String get k_0vzvn8r => '修改群名称';
	@override String get k_003rzap => '确定';
	@override String get k_038lh6u => '群管理';
	@override String get k_0k5wyiy => '设置管理员';
	@override String get k_0goiuwk => '全员禁言';
	@override String get k_1g889xx => '全员禁言开启后，只允许群主和管理员发言。';
	@override String get k_0wlrefq => '添加需要禁言的群成员';
	@override String get k_0goox5g => '设置禁言';
	@override String get k_08daijh => '成功取消管理员身份';
	@override String k_1fd5tta({required Object adminNum}) => '管理员 (${adminNum}/10)';
	@override String get k_0k5u935 => '添加管理员';
	@override String get k_003ngex => '完成';
	@override String get k_03enyx5 => '群成员';
	@override String get k_03erpei => '管理员';
	@override String get k_0qi9tno => '群主、管理员';
	@override String get k_003kv3v => '搜索';
	@override String k_01z3dft({required Object groupMemberNum}) => '群成员(${groupMemberNum}人)';
	@override String k_1vhgizy({required Object memberCount}) => '${memberCount}人';
	@override String get k_0ef2a12 => '修改我的群昵称';
	@override String get k_1aajych => '仅限中文、字母、数字和下划线，2-20个字';
	@override String get k_137pab5 => '我的群昵称';
	@override String get k_0ivim6d => '暂无群公告';
	@override String get k_03eq6cn => '群公告';
	@override String get k_002vxya => '编辑';
	@override String get k_03gu05e => '聊天室';
	@override String get k_03b4f3p => '会议群';
	@override String get k_03avj1p => '公开群';
	@override String get k_03asq2g => '工作群';
	@override String get k_03b3hbi => '未知群';
	@override String get k_03es1ox => '群类型';
	@override String get k_003mz1i => '同意';
	@override String get k_003lpre => '拒绝';
	@override String get k_003qk66 => '头像';
	@override String get k_003lhvk => '昵称';
	@override String get k_003ps50 => '账号';
	@override String get k_15lx52z => '个性签名';
	@override String get k_003qgkp => '性别';
	@override String get k_003m6hr => '生日';
	@override String get k_0003v6a => '男';
	@override String get k_00043x2 => '女';
	@override String get k_03bcjkv => '未设置';
	@override String get k_11s0gdz => '修改昵称';
	@override String get k_0p3j4sd => '仅限中字、字母、数字和下划线';
	@override String get k_15lyvdt => '修改签名';
	@override String get k_0vylzjp => '这个人很懒，什么也没写';
	@override String get k_1hs7ese => '等上线再改这个';
	@override String get k_03exjk7 => '备注名';
	@override String get k_0s3skfd => '加入黑名单';
	@override String get k_17fpl3y => '置顶聊天';
	@override String get k_0p3b31s => '修改备注名';
	@override String get k_0003y9x => '无';
	@override String get k_11zgnfs => '个人资料';
	@override String k_1h42emf({required Object signature}) => '个性签名: ${signature}';
	@override String get k_1tez2xl => '暂无个性签名';
	@override String k_0vdrbki({required Object receiver}) => '与${receiver}的聊天记录';
	@override String get k_0vjj2kp => '群聊的聊天记录';
	@override String get k_003n2rp => '选择';
	@override String get k_1m9exwh => '最近联系人';
	@override String get k_119nwqr => '输入不能为空';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	Map<String, dynamic> _buildFlatMap() {
		return {
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
			'k_1xd7osu': ({required Object s}) => '${s}为 ',
			'k_0u93xpy': ({required Object opUserNickName}) => '${opUserNickName}修改',
			'k_10oyylx': ({required Object opUserNickName}) => '${opUserNickName}退出群聊',
			'k_1ss45p9': ({required Object invitedMemberString}) => '邀请${invitedMemberString}加入群组',
			'k_1w3kivl': ({required Object invitedMemberString}) => '将${invitedMemberString}踢出群组',
			'k_024xosz': ({required Object joinedMemberString}) => '用户${joinedMemberString}加入了群聊',
			'k_002wddw': '禁言',
			'k_0got6f7': '解除禁言',
			'k_0nj3nkq': ({required Object userName}) => '${userName} 被',
			'k_0wn1wy1': ({required Object operationType}) => '系统消息 ${operationType}',
			'k_1uaqed6': '[自定义]',
			'k_0z2z7rx': '[语音]',
			'k_0y39ngu': '[表情]',
			'k_0nckgoh': ({required Object fileName}) => '[文件] ${fileName}',
			'k_0y1a2my': '[图片]',
			'k_0z4fib8': '[视频]',
			'k_0y24mcg': '[位置]',
			'k_0pewpd1': '[聊天记录]',
			'k_13s8d9p': '未知消息',
			'k_003qkx2': '日历',
			'k_003n2pz': '相机',
			'k_03idjo0': '联系人',
			'k_003ltgm': '位置',
			'k_02k3k86': '麦克风',
			'k_003pm7l': '相册',
			'k_15ao57x': '相册写入',
			'k_164m3jd': '本地存储',
			'k_1ut348h': ({required Object yoursItem}) => '“IM云通信”想访问您的${yoursItem}',
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
			'k_0bobr6r': ({required Object diffMinutes}) => '${diffMinutes} 分钟前',
			'k_003q7ba': '下午',
			'k_003q7bb': '上午',
			'k_003pu3h': '现在',
			'k_0fh0id2': ({required Object yesterday}) => '昨天 ${yesterday}',
			'k_002rflt': '删除',
			'k_003q5fi': '复制',
			'k_003prq0': '转发',
			'k_002r1h2': '多选',
			'k_003j708': '引用',
			'k_003pqpr': '撤回',
			'k_03ezhho': '已复制',
			'k_11ctfsz': '暂未实现',
			'k_1hbjg5g': '[群系统消息]',
			'k_03tvswb': '[未知消息]',
			'k_0gt5q2o': ({required Object displayName}) => '${displayName}撤回了一条消息',
			'k_0003z7x': '您',
			'k_002wfe4': '已读',
			'k_002wjlg': '未读',
			'k_1jxdqeu': '发送中...',
			'k_0uu95o6': '“IM云通信”暂不可以打开此类文件，你可以使用其他应用打开并预览',
			'k_003nevv': '取消',
			'k_001nmhu': '用其他应用打开',
			'k_105682d': '图片加载失败',
			'k_0pytyeu': '图片保存成功',
			'k_0akceel': '图片保存失败',
			'k_003rk1s': '保存',
			'k_04a0awq': '[语音消息]',
			'k_0pzwbmg': '视频保存成功',
			'k_0aktupv': '视频保存失败',
			'k_105c3y3': '视频加载失败',
			'k_176rzr7': '聊天记录',
			'k_002r305': '发送',
			'k_003kcka': '照相',
			'k_002s86q': '视频',
			'k_003n8b0': '拍摄',
			'k_003kt0a': '相片',
			'k_003tnp0': '文件',
			'k_0h22snw': '语音通话',
			'k_003km5r': '名片',
			'k_03cfe3p': '戳一戳',
			'k_0ylosxn': '自定义消息',
			'k_0jhdhtp': '发送失败,视频不能大于100MB',
			'k_1i3evae': ({required Object successPath}) => '选择成功${successPath}',
			'k_0am7r68': '手指上滑，取消发送',
			'k_13dsw4l': '松开取消',
			'k_15jl6qw': '说话时间太短!',
			'k_0gx7vl6': '按住说话',
			'k_15dlafd': '逐条转发',
			'k_15dryxy': '合并转发',
			'k_1eyhieh': '确定删除已选消息',
			'k_17fmlyf': '清除聊天',
			'k_0dhesoz': '取消置顶',
			'k_002sk7x': '置顶',
			'k_1s03bj1': ({required Object messageString}) => '${messageString}[有人@我]',
			'k_050tjt8': ({required Object messageString}) => '${messageString}[@所有人]',
			'k_003kfai': '未知',
			'k_13dq4an': '自动审批',
			'k_0l13cde': '管理员审批',
			'k_11y8c6a': '禁止加群',
			'k_16payqf': '加群方式',
			'k_0vzvn8r': '修改群名称',
			'k_003rzap': '确定',
			'k_038lh6u': '群管理',
			'k_0k5wyiy': '设置管理员',
			'k_0goiuwk': '全员禁言',
			'k_1g889xx': '全员禁言开启后，只允许群主和管理员发言。',
			'k_0wlrefq': '添加需要禁言的群成员',
			'k_0goox5g': '设置禁言',
			'k_08daijh': '成功取消管理员身份',
			'k_1fd5tta': ({required Object adminNum}) => '管理员 (${adminNum}/10)',
			'k_0k5u935': '添加管理员',
			'k_003ngex': '完成',
			'k_03enyx5': '群成员',
			'k_03erpei': '管理员',
			'k_0qi9tno': '群主、管理员',
			'k_003kv3v': '搜索',
			'k_01z3dft': ({required Object groupMemberNum}) => '群成员(${groupMemberNum}人)',
			'k_1vhgizy': ({required Object memberCount}) => '${memberCount}人',
			'k_0ef2a12': '修改我的群昵称',
			'k_1aajych': '仅限中文、字母、数字和下划线，2-20个字',
			'k_137pab5': '我的群昵称',
			'k_0ivim6d': '暂无群公告',
			'k_03eq6cn': '群公告',
			'k_002vxya': '编辑',
			'k_03gu05e': '聊天室',
			'k_03b4f3p': '会议群',
			'k_03avj1p': '公开群',
			'k_03asq2g': '工作群',
			'k_03b3hbi': '未知群',
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
			'k_17fpl3y': '置顶聊天',
			'k_0p3b31s': '修改备注名',
			'k_0003y9x': '无',
			'k_11zgnfs': '个人资料',
			'k_1h42emf': ({required Object signature}) => '个性签名: ${signature}',
			'k_1tez2xl': '暂无个性签名',
			'k_0vdrbki': ({required Object receiver}) => '与${receiver}的聊天记录',
			'k_0vjj2kp': '群聊的聊天记录',
			'k_003n2rp': '选择',
			'k_1m9exwh': '最近联系人',
			'k_119nwqr': '输入不能为空',
		};
	}
}

extension on _StringsZh {
	Map<String, dynamic> _buildFlatMap() {
		return {
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
			'k_1xd7osu': ({required Object s}) => '${s}为 ',
			'k_0u93xpy': ({required Object opUserNickName}) => '${opUserNickName}修改',
			'k_10oyylx': ({required Object opUserNickName}) => '${opUserNickName}退出群聊',
			'k_1ss45p9': ({required Object invitedMemberString}) => '邀请${invitedMemberString}加入群组',
			'k_1w3kivl': ({required Object invitedMemberString}) => '将${invitedMemberString}踢出群组',
			'k_024xosz': ({required Object joinedMemberString}) => '用户${joinedMemberString}加入了群聊',
			'k_002wddw': '禁言',
			'k_0got6f7': '解除禁言',
			'k_0nj3nkq': ({required Object userName}) => '${userName} 被',
			'k_0wn1wy1': ({required Object operationType}) => '系统消息 ${operationType}',
			'k_1uaqed6': '[自定义]',
			'k_0z2z7rx': '[语音]',
			'k_0y39ngu': '[表情]',
			'k_0nckgoh': ({required Object fileName}) => '[文件] ${fileName}',
			'k_0y1a2my': '[图片]',
			'k_0z4fib8': '[视频]',
			'k_0y24mcg': '[位置]',
			'k_0pewpd1': '[聊天记录]',
			'k_13s8d9p': '未知消息',
			'k_003qkx2': '日历',
			'k_003n2pz': '相机',
			'k_03idjo0': '联系人',
			'k_003ltgm': '位置',
			'k_02k3k86': '麦克风',
			'k_003pm7l': '相册',
			'k_15ao57x': '相册写入',
			'k_164m3jd': '本地存储',
			'k_1ut348h': ({required Object yoursItem}) => '“IM云通信”想访问您的${yoursItem}',
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
			'k_0bobr6r': ({required Object diffMinutes}) => '${diffMinutes} 分钟前',
			'k_003q7ba': '下午',
			'k_003q7bb': '上午',
			'k_003pu3h': '现在',
			'k_0fh0id2': ({required Object yesterday}) => '昨天 ${yesterday}',
			'k_002rflt': '删除',
			'k_003q5fi': '复制',
			'k_003prq0': '转发',
			'k_002r1h2': '多选',
			'k_003j708': '引用',
			'k_003pqpr': '撤回',
			'k_03ezhho': '已复制',
			'k_11ctfsz': '暂未实现',
			'k_1hbjg5g': '[群系统消息]',
			'k_03tvswb': '[未知消息]',
			'k_0gt5q2o': ({required Object displayName}) => '${displayName}撤回了一条消息',
			'k_0003z7x': '您',
			'k_002wfe4': '已读',
			'k_002wjlg': '未读',
			'k_1jxdqeu': '发送中...',
			'k_0uu95o6': '“IM云通信”暂不可以打开此类文件，你可以使用其他应用打开并预览',
			'k_003nevv': '取消',
			'k_001nmhu': '用其他应用打开',
			'k_105682d': '图片加载失败',
			'k_0pytyeu': '图片保存成功',
			'k_0akceel': '图片保存失败',
			'k_003rk1s': '保存',
			'k_04a0awq': '[语音消息]',
			'k_0pzwbmg': '视频保存成功',
			'k_0aktupv': '视频保存失败',
			'k_105c3y3': '视频加载失败',
			'k_176rzr7': '聊天记录',
			'k_002r305': '发送',
			'k_003kcka': '照相',
			'k_002s86q': '视频',
			'k_003n8b0': '拍摄',
			'k_003kt0a': '相片',
			'k_003tnp0': '文件',
			'k_0h22snw': '语音通话',
			'k_003km5r': '名片',
			'k_03cfe3p': '戳一戳',
			'k_0ylosxn': '自定义消息',
			'k_0jhdhtp': '发送失败,视频不能大于100MB',
			'k_1i3evae': ({required Object successPath}) => '选择成功${successPath}',
			'k_0am7r68': '手指上滑，取消发送',
			'k_13dsw4l': '松开取消',
			'k_15jl6qw': '说话时间太短!',
			'k_0gx7vl6': '按住说话',
			'k_15dlafd': '逐条转发',
			'k_15dryxy': '合并转发',
			'k_1eyhieh': '确定删除已选消息',
			'k_17fmlyf': '清除聊天',
			'k_0dhesoz': '取消置顶',
			'k_002sk7x': '置顶',
			'k_1s03bj1': ({required Object messageString}) => '${messageString}[有人@我]',
			'k_050tjt8': ({required Object messageString}) => '${messageString}[@所有人]',
			'k_003kfai': '未知',
			'k_13dq4an': '自动审批',
			'k_0l13cde': '管理员审批',
			'k_11y8c6a': '禁止加群',
			'k_16payqf': '加群方式',
			'k_0vzvn8r': '修改群名称',
			'k_003rzap': '确定',
			'k_038lh6u': '群管理',
			'k_0k5wyiy': '设置管理员',
			'k_0goiuwk': '全员禁言',
			'k_1g889xx': '全员禁言开启后，只允许群主和管理员发言。',
			'k_0wlrefq': '添加需要禁言的群成员',
			'k_0goox5g': '设置禁言',
			'k_08daijh': '成功取消管理员身份',
			'k_1fd5tta': ({required Object adminNum}) => '管理员 (${adminNum}/10)',
			'k_0k5u935': '添加管理员',
			'k_003ngex': '完成',
			'k_03enyx5': '群成员',
			'k_03erpei': '管理员',
			'k_0qi9tno': '群主、管理员',
			'k_003kv3v': '搜索',
			'k_01z3dft': ({required Object groupMemberNum}) => '群成员(${groupMemberNum}人)',
			'k_1vhgizy': ({required Object memberCount}) => '${memberCount}人',
			'k_0ef2a12': '修改我的群昵称',
			'k_1aajych': '仅限中文、字母、数字和下划线，2-20个字',
			'k_137pab5': '我的群昵称',
			'k_0ivim6d': '暂无群公告',
			'k_03eq6cn': '群公告',
			'k_002vxya': '编辑',
			'k_03gu05e': '聊天室',
			'k_03b4f3p': '会议群',
			'k_03avj1p': '公开群',
			'k_03asq2g': '工作群',
			'k_03b3hbi': '未知群',
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
			'k_17fpl3y': '置顶聊天',
			'k_0p3b31s': '修改备注名',
			'k_0003y9x': '无',
			'k_11zgnfs': '个人资料',
			'k_1h42emf': ({required Object signature}) => '个性签名: ${signature}',
			'k_1tez2xl': '暂无个性签名',
			'k_0vdrbki': ({required Object receiver}) => '与${receiver}的聊天记录',
			'k_0vjj2kp': '群聊的聊天记录',
			'k_003n2rp': '选择',
			'k_1m9exwh': '最近联系人',
			'k_119nwqr': '输入不能为空',
		};
	}
}
