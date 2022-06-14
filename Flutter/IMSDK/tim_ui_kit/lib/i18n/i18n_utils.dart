// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tim_ui_kit/i18n/strings.g.dart';

/// only support Chinese (both traditional and simplified) and English officially.
/// If you need some other languages, can based on this document: https://docs.qq.com/doc/DSVN4aHVpZm1CSEhv?u=c927b5c7e9874f77b40b7549f3fffa57
enum LanguageEnum {
  /// Chinese, Traditional
  zhHant,

  /// Chinese, Simplified
  zhHans,

  /// English
  en
}

Map i18nLanguageEnumMap = {
  "en": AppLocale.en.build(),
  "zhHant": AppLocale.zhHant.build(),
  "zhHans": AppLocale.zhHans.build(),
};

class I18nUtils {
  static I18nUtils? _instance;
  I18nUtils._internal(BuildContext? context, [LanguageEnum? language]) {
    _init(context, language);
  }
  factory I18nUtils(BuildContext? context, [LanguageEnum? language]) {
    if (language != null) {
      // 若为core调用（含language，强制新实例化一个）
      _instance = I18nUtils._internal(context, language);
    } else {
      _instance ??= I18nUtils._internal(context, language);
    }
    return _instance!;
  }

  Map<String, dynamic> zhMap = {};
  Map zhMapRevert = {};
  RegExp expForParameterOut = RegExp(r"{{[^]+}}");
  RegExp expForParameter = RegExp(r"(?<=\{{)[^}]*(?=\}})");
  late final t;

  void _init(BuildContext? context, [LanguageEnum? language]) {
    if (language != null) {
      t = i18nLanguageEnumMap[language.name];
    } else {
      try {
        if (context != null) {
          t = findDeviceLocale().build();
        } else {
          t = AppLocale.en.build();
        }
      } catch (e) {
        t = AppLocale.en.build();
        print("errorInLanguage ${e.toString()}");
      }
    }
    zhMap = jsonDecode(zhJson);
    zhMapRevert = revertMap(zhMap);
  }

  String imt(String value) {
    String currentKey = zhMapRevert[value] ?? getKeyFromMap(zhMap, value) ?? "";
    String translatedValue = t[currentKey] ?? value;
    return translatedValue;
  }

  Function imt_para(String template, String value) {
    // 调用模板：imt_para("已选：{{addType}}",'已选：$addType')(addType: addType)
    final originTemplate = template.replaceAllMapped(
        expForParameterOut, (Match m) => replaceParameterForTemplate(m));
    final originKey = zhMapRevert[originTemplate] ??
        getKeyFromMap(zhMap, originTemplate) ??
        "";
    final Function translatedValueFunction = t[originKey] ??
        ({
          Object? option1,
          Object? option2,
          Object? option3,
          Object? option4,
          Object? option5,
          Object? option6,
          Object? option7,
          Object? option8,
          Object? option9,
          Object? option10,
          Object? option11,
          Object? option12,
          Object? option13,
          Object? option14,
          Object? option15,
          Object? option16,
          Object? option17,
          Object? option18,
          Object? option19,
          Object? option20,
        }) {
          return value;
        };
    return translatedValueFunction;
  }

  String replaceParameterForTemplate(Match value) {
    final String? parameter = expForParameter.stringMatch(value[0] ?? "");
    return "\$$parameter";
  }

  static String getKeyFromMap(Map map, String key) {
    String currentKey = "";
    for (String tempKey in map.keys) {
      if (map[tempKey] == key) {
        currentKey = tempKey;
        break;
      }
    }
    return currentKey;
  }

  static Map revertMap(Map map) {
    final Map<String, String> newMap = {};
    for (String tempKey in map.keys) {
      newMap[map[tempKey]] = tempKey;
    }
    return newMap;
  }

  String getCurrentLanguage(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  AppLocale findDeviceLocale() {
    final String? deviceLocale =
        WidgetsBinding.instance?.window.locale.toLanguageTag();
    if (deviceLocale != null) {
      final typedLocale = _selectLocale(deviceLocale);
      if (typedLocale != null) {
        return typedLocale;
      }
    }
    return AppLocale.en;
  }

  final _localeRegex =
      RegExp(r'^([a-z]{2,8})?([_-]([A-Za-z]{4}))?([_-]?([A-Z]{2}|[0-9]{3}))?$');
  AppLocale? _selectLocale(String localeRaw) {
    final match = _localeRegex.firstMatch(localeRaw);
    AppLocale? selected;
    if (match != null) {
      final language = match.group(1);
      final country = match.group(5);
      final script = match.group(3);
      // match exactly
      selected = AppLocale.values.cast<AppLocale?>().firstWhere(
          (supported) =>
              supported?.languageTag == localeRaw.replaceAll('_', '-'),
          orElse: () => null);

      if (selected == null && script != null) {
        // match script
        selected = AppLocale.values.cast<AppLocale?>().firstWhere(
            (supported) => supported?.languageTag.contains(script) == true,
            orElse: () => null);
      }

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

  // 不用手动改这里了，也不用手动node scan。这些国际化的文件也不用再提交到dev。
  final zhJson =
      '''{"k_0ylosxn":"自定义消息","k_13sajrj":"表情消息","k_13sjeb7":"文件消息","k_0yd2ft8":"群提示消息","k_13s7mxn":"图片消息","k_13satlt":"位置消息","k_00bbtsx":"合并转发消息","k_13sqwu4":"语音消息","k_13sqjjp":"视频消息","k_1fdhj9g":"该版本不支持此消息","k_06pujtm":"同意任何用户添加好友","k_0gyhkp5":"需要验证","k_121ruco":"拒绝任何人加好友","k_05nspni":"自定义字段","k_03fchyy":"群头像","k_03i9mfe":"群简介","k_03agq58":"群名称","k_039xqny":"群通知","k_003tr0a":"群主","k_1qbg9xc":"\$option8为 ","k_1wq5ubm":"\$option7修改","k_0y5pu80":"\$option6退出群聊","k_0nl7cmd":"邀请\$option5加入群组","k_1ju5iqw":"将\$option4踢出群组","k_1ovt677":"用户\$option3加入了群聊","k_002wddw":"禁言","k_0got6f7":"解除禁言","k_0k05b8b":"\$option2 被","k_0spotql":"将 \$adminMember 设置为管理员","k_1vn4xq1":"将 \$adminMember 取消管理员","k_0wm4xeb":"系统消息 \$option2","k_0nbq9v3":"通话时间：\$option2","k_1uaqed6":"[自定义]","k_0z2z7rx":"[语音]","k_0y39ngu":"[表情]","k_0i1kf53":"[文件] \$option2","k_0y1a2my":"[图片]","k_0z4fib8":"[视频]","k_0y24mcg":"[位置]","k_0pewpd1":"[聊天记录]","k_13s8d9p":"未知消息","k_1c3us5n":"当前群组不支持@全体成员","k_11k579v":"发言中有非法语句","k_003n2pz":"相机","k_0e35hsw":"为方便您将所拍摄的照片或视频发送给朋友，以及进行视频通话，请允许我们访问摄像头进行拍摄照片和视频。","k_02k3k86":"麦克风","k_0dj6yr7":"为方便您发送语音消息、拍摄视频以及音视频通话，请允许我们使用麦克风进行录音。","k_003qnsl":"存储","k_0s3rtpw":"为方便您查看和选择相册里的图片视频发送给朋友，以及保存内容到设备，请允许我们访问您设备上的照片、媒体内容。","k_0tezv85":" 申请获取\$option2","k_002rety":"权限","k_003qkx2":"日历","k_03idjo0":"联系人","k_003ltgm":"位置","k_003kthh":"照片","k_15ao57x":"相册写入","k_003tnp0":"文件","k_18o68ro":"需要授予","k_1onpf8u":" 相机权限，以正常使用拍摄图片视频、视频通话等功能。","k_17irga5":" 麦克风权限，以正常使用发送语音消息、拍摄视频、音视频通话等功能。","k_0572kc4":" 访问照片权限，以正常使用发送图片、视频等功能。","k_0slykws":" 访问相册写入权限，以正常使用存储图片、视频等功能。","k_119pkcd":" 文件读写权限，以正常使用在聊天功能中的图片查看、选择能力和发送文件的能力。","k_1gnnby6":" 想访问您的\$option2","k_0gqewd3":"以后再说","k_03eq4s1":"去开启","k_003qzac":"昨天","k_003r39d":"前天","k_03fqp9o":"星期天","k_03ibg5h":"星期一","k_03i7hu1":"星期二","k_03iaiks":"星期三","k_03el9pa":"星期四","k_03i7ok1":"星期五","k_03efxyg":"星期六","k_1wh4atg":"\$option2 分钟前","k_003q7ba":"下午","k_003q7bb":"上午","k_003pu3h":"现在","k_07sh7g1":"昨天 \$option2","k_0n9pyxz":"用户不存在","k_1bjwemh":"搜索用户 ID","k_003kv3v":"搜索","k_1pj8xzh":"我的用户ID: \$option2","k_1wu8h4x":"我是: \$showName","k_16758qw":"添加好友","k_0py1evo":"个性签名: \$option2","k_0i553x0":"填写验证信息","k_031ocwx":"请填写备注和分组","k_003ojje":"备注","k_003lsav":"分组","k_167bdvq":"我的好友","k_156b4ut":"好友申请已发送","k_002r305":"发送","k_03gu05e":"聊天室","k_03b4f3p":"会议群","k_03avj1p":"公开群","k_03asq2g":"工作群","k_03b3hbi":"未知群","k_1loix7s":"群类型: \$groupType","k_1lqbsib":"该群聊不存在","k_03h153m":"搜索群ID","k_1x5a9vb":"我是: \$option1","k_0gw8pum":"进群申请","k_08nc5j1":"群类型: \$option1","k_0oxak3r":"群申请已发送","k_002rflt":"删除","k_0on1aj2":"有\$option2条@我消息","k_13p3w93":"有人@我","k_0nt2uyg":"回到最新位置","k_04l16at":"\$option1条新消息","k_18w5uk6":"@所有人","k_1don84v":"无法定位到原消息","k_003q5fi":"复制","k_003prq0":"转发","k_002r1h2":"多选","k_003j708":"引用","k_003pqpr":"撤回","k_03ezhho":"已复制","k_11ctfsz":"暂未实现","k_1hbjg5g":"[群系统消息]","k_03tvswb":"[未知消息]","k_155cj23":"您撤回了一条消息，","k_0gapun3":"重新编辑","k_1kvj4i2":"\$option2撤回了一条消息","k_1aszp2k":"您确定要重发这条消息么？","k_003rzap":"确定","k_003nevv":"取消","k_0003z7x":"您","k_002wfe4":"已读","k_002wjlg":"未读","k_0h1ygf8":"发起通话","k_0h169j0":"取消通话","k_0h13jjk":"接受通话","k_0h19hfx":"拒绝通话","k_0obi9lh":"超时未接听","k_1v0lbpp":"“\$option2”暂不可以打开此类文件，你可以使用其他应用打开并预览","k_001nmhu":"用其他应用打开","k_0jmujgh":"其他文件正在接收中","k_1ht1b80":"正在接收中","k_105682d":"图片加载失败","k_0pytyeu":"图片保存成功","k_0akceel":"图片保存失败","k_04a0awq":"[语音消息]","k_105c3y3":"视频加载失败","k_176rzr7":"聊天记录","k_0d5z4m5":"选择提醒人","k_003ngex":"完成","k_1665ltg":"发起呼叫","k_003n8b0":"拍摄","k_0jhdhtp":"发送失败,视频不能大于100MB","k_119ucng":"图片不能为空","k_0torwfz":"选择成功\$option2","k_0am7r68":"手指上滑，取消发送","k_13dsw4l":"松开取消","k_15jl6qw":"说话时间太短!","k_0gx7vl6":"按住说话","k_1josu12":"\$option1 条入群请求","k_038ryos":"去处理","k_15dlafd":"逐条转发","k_15dryxy":"合并转发","k_1eyhieh":"确定删除已选消息","k_17fmlyf":"清除聊天","k_0dhesoz":"取消置顶","k_002sk7x":"置顶","k_003ll77":"草稿","k_0i1bjah":"\$option1撤回了一条消息","k_03icaxo":"自定义","k_1qzxh9q":"通话时间：\$option3","k_0wrgmom":"[语音通话]：\$option1","k_06ix2f0":"[视频通话]：\$option2","k_08o3z5w":"[文件] \$option1","k_09j4izl":"[有人@我] ","k_1oqtjw0":"[@所有人] ","k_0n2x5s0":"验证消息: \$option2","k_003mz1i":"同意","k_003lpre":"拒绝","k_03c1nx0":"已同意","k_03aw9w8":"已拒绝","k_1uaov41":"查找聊天内容","k_003kfai":"未知","k_13dq4an":"自动审批","k_0l13cde":"管理员审批","k_11y8c6a":"禁止加群","k_1kvyskd":"无网络连接，无法修改","k_16payqf":"加群方式","k_0vzvn8r":"修改群名称","k_038lh6u":"群管理","k_0k5wyiy":"设置管理员","k_0goiuwk":"全员禁言","k_1g889xx":"全员禁言开启后，只允许群主和管理员发言。","k_0wlrefq":"添加需要禁言的群成员","k_0goox5g":"设置禁言","k_08daijh":"成功取消管理员身份","k_1k3arsw":"管理员 (\$option2/10)","k_0k5u935":"添加管理员","k_03enyx5":"群成员","k_1d4golg":"群成员(\$option1人)","k_0h1svv1":"删除群成员","k_0h1g636":"添加群成员","k_0uj7208":"无网络连接，无法查看群成员","k_1bg69nt":"\$option1人","k_0hpukyx":"查看更多群成员","k_0qtsar0":"消息免打扰","k_0ef2a12":"修改我的群昵称","k_1aajych":"仅限中文、字母、数字和下划线，2-20个字","k_137pab5":"我的群昵称","k_0ivim6d":"暂无群公告","k_03eq6cn":"群公告","k_002vxya":"编辑","k_17fpl3y":"置顶聊天","k_03es1ox":"群类型","k_003qk66":"头像","k_003lhvk":"昵称","k_003ps50":"账号","k_15lx52z":"个性签名","k_003qgkp":"性别","k_003m6hr":"生日","k_0003v6a":"男","k_00043x2":"女","k_03bcjkv":"未设置","k_11s0gdz":"修改昵称","k_0p3j4sd":"仅限中字、字母、数字和下划线","k_15lyvdt":"修改签名","k_0vylzjp":"这个人很懒，什么也没写","k_1hs7ese":"等上线再改这个","k_03exjk7":"备注名","k_0s3skfd":"加入黑名单","k_0p3b31s":"修改备注名","k_0003y9x":"无","k_11zgnfs":"个人资料","k_00gjqxj":"个性签名: \$option1","k_1tez2xl":"暂无个性签名","k_1m9dftc":"全部联系人","k_0em4gyz":"全部群聊","k_002twmj":"群聊","k_09kga0d":"更多聊天记录","k_0c29cxr":"\$option1条相关聊天记录","k_1twk5rz":"与\$option1的聊天记录","k_0vjj2kp":"群聊的聊天记录","k_003n2rp":"选择","k_03ignw6":"所有人","k_03erpei":"管理员","k_0qi9tno":"群主、管理员","k_12s5ept":"消息详情","k_0mxa4f4":"\$option1人已读","k_061tue3":"\$option2人未读","k_1m9exwh":"最近联系人","k_119nwqr":"输入不能为空","k_18qjstb":"转让群主","k_0pzwbmg":"视频保存成功","k_0aktupv":"视频保存失败"}''';
}
