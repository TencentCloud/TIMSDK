// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:convert';

import '../i18n/strings.g.dart';

final I18nUtils ttBuild = I18nUtils();
String imt(String value) => ttBuild._imt(value);
Function imt_para(String template, String value) =>
    ttBuild._imt_parameter(template, value);

class I18nUtils {
  I18nUtils._internal() {
    _init();
  }
  factory I18nUtils() => _instance;
  static late final I18nUtils _instance = I18nUtils._internal();

  Map<String, dynamic> zhMap = {};
  Map zhMapRevert = {};
  RegExp expForParameterOut = RegExp(r"{{[^]+}}");
  RegExp expForParameter = RegExp(r"(?<=\{{)[^}]*(?=\}})");

  void _init() {
    zhMap = jsonDecode(zhJson);
    zhMapRevert = revertMap(zhMap);
  }

  String _imt(String value) {
    String currentKey = zhMapRevert[value] ?? getKeyFromMap(zhMap, value) ?? "";
    String translatedValue = t[currentKey] ?? value;
    return translatedValue;
  }

  Function _imt_parameter(String template, String value) {
    // 调用模板：imt_para("已选：{{addType}}",'已选：$addType')(addType: addType)
    final originTemplate = template.replaceAllMapped(
        expForParameterOut, (Match m) => replaceParameterForTemplate(m));
    final originKey = zhMapRevert[originTemplate] ??
        getKeyFromMap(zhMap, originTemplate) ??
        "";
    print("template $template $value");
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

  static int getHashValue(String text) {
    "use strict";

    var hash = 5381, index = text.length;

    while (index > 0) {
      hash = (hash * 33) ^ text.codeUnitAt(--index);
    }

    return hash;
  }

  // 不用手动改这里了，也不用手动node scan。这些国际化的文件也不用再提交到dev。
  final zhJson = '''{"k_16758qw":"添加好友","k_0elt0kw":"添加群聊","k_03f15qk":"黑名单","k_0s3p3ji":"暂无黑名单","k_0uc5cnb":"我们还在内测中，暂不支持创建频道。","k_003rzap":"确定","k_003nevv":"取消","k_0s5ey0o":"实时音视频 TRTC","k_03gpl3d":"大家好","k_0352fjr":"无网络连接，进入频道失败","k_0d7n018":"结束话题","k_0d826hk":"置顶话题","k_15wcgna":"结束成功","k_15wo7xu":"置顶成功","k_0s5zoi3":"发生错误 \$option1","k_003ltgm":"位置","k_0h22snw":"语音通话","k_0h20hg5":"视频通话","k_002s934":"话题","k_18g3zdo":"云通信·IM","k_1m8vyp0":"新的联系人","k_0elz70e":"我的群聊","k_18tb4mo":"无联系人","k_18nuh87":"联系我们","k_1uf134v":"反馈及建议可以加入QQ群：788910197","k_0xlhhrn":"在线时间，周一到周五，早上10点 - 晚上8点","k_17fmlyf":"清除聊天","k_0dhesoz":"取消置顶","k_002sk7x":"置顶","k_003kv3v":"搜索","k_0gmpgcg":"暂无会话","k_1m8zuj4":"选择联系人","k_002tu9r":"性能","k_0i8egqa":"获取到的消息:\$option8","k_0pokyns":"获取讨论区列表失败 \$option8","k_1tmcw5c":"请完善话题标题","k_1cnmslk":"必须选择一个标签","k_1y03m8a":"创建话题失败 \$option8","k_0z3ytji":"创建话题成功","k_1a8vem3":"创建者异常","k_0eskkr1":"选择讨论区","k_0d7plb5":"创建话题","k_144t0ho":"---- 相关讨论 ----","k_0pnz619":"填写话题标题","k_136v279":"+标签（至少添加一个）","k_04hjhvp":"讨论区参数异常","k_002r79h":"全部","k_03ejkb6":"已加入","k_172tngw":"话题（未连接）","k_0rnmfc4":"该讨论区下暂无话题","k_1pq0ybn":"暂未加入任何话题","k_0bh95w0":"无网络连接，进入话题失败","k_002twmj":"群聊","k_0em28sp":"暂无群聊","k_09kalj0":"清空聊天记录","k_18qjstb":"转让群主","k_14j5iul":"删除并退出","k_0jtutmw":"退出后不会接收到此群聊消息","k_04dqh36":"暂无新联系人","k_08k00l9":"正在加载...","k_197r4f7":"即时通信服务连接成功","k_1s5xnir":"即时通信 SDK初始化失败","k_1v6uh9c":"登录失败 \$option8","k_15bxnkw":"网络连接丢失","k_0glj9us":"发起会话","k_1631kyh":"创建工作群","k_1644yii":"创建社交群","k_1fxfx04":"创建会议群","k_1cnkqc9":"创建直播群","k_002r09z":"频道","k_003nvk2":"消息","k_1jwxwgt":"连接中...","k_03gm52d":"通讯录","k_003k7dc":"我的","k_14yh35u":"登录·即时通信","k_0st7i3e":"体验群组聊天，音视频对话等IM功能","k_0cr1atw":"中国大陆","k_0mnxjg7":"欢迎使用腾讯云即时通信 IM，为保护您的个人信息安全，我们更新了《隐私政策》，主要完善了收集用户信息的具体内容和目的、增加了第三方SDK使用等方面的内容。","k_1545beg":"请您点击","k_0opnzp6":"《用户协议》","k_00041m1":"和","k_0orhtx0":"《隐私协议》","k_11x8pvm":"并仔细阅读，如您同意以上内容，请点击“同意并继续”，开始使用我们的产品与服务！","k_17nw8gq":"同意并继续","k_1nynslj":"不同意并退出","k_0jsvmjm":"请输入手机号","k_1lg8qh2":"手机号格式错误","k_03jia4z":"无网络连接","k_007jqt2":"验证码发送成功","k_1a55aib":"验证码异常","k_0t5a9hl":"登录失败\$option1","k_16r3sej":"国家/地区","k_15hlgzr":"选择你的国家区号","k_1bnmt3h":"请使用英文搜索","k_03fei8z":"手机号","k_03aj66h":"验证码","k_1m9jtmw":"请输入验证码","k_0y1wbxk":"获取验证码","k_002ri2g":"登陆","k_161ecly":"当前无网络","k_11uz2i8":"重试网络","k_1vhzltr":"腾讯云即时通信IM","k_0j433ys":"腾讯云TRTC","k_0epvs61":"更换皮肤","k_12u8g8l":"免责声明","k_1p0j8i3":"IM即时通信（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。","k_0k7qoht":"同意任何用户加好友","k_0gyhkp5":"需要验证","k_121ruco":"拒绝任何人加好友","k_003kfai":"未知","k_1kvyskd":"无网络连接，无法修改","k_1j91bvz":"TUIKIT 为你选择一个头像?","k_1wmkneq":"加我为好友时需要验证","k_1eitsd0":"关于腾讯云·通信","k_1919d6m":"隐私条例","k_0wqhgor":"个人信息收集清单","k_12rfxml":"第三方信息共享清单","k_131g7q4":"注销账户","k_03fel2u":"版本号","k_16kts8h":"退出登录","k_129scag":"好友删除成功","k_094phq4":"好友添加失败","k_13spdki":"发送消息","k_1666isy":"清除好友","k_0r8fi93":"好友添加成功","k_02qw14e":"好友申请已发出","k_0n3md5x":"当前用户在黑名单","k_14c600t":"修改备注","k_1f811a4":"支持数字、英文、下划线","k_11z7ml4":"详细资料","k_0003y9x":"无","k_1679vrd":"加为好友","k_1ajt0b1":"获取当前位置失败","k_0lhm9xq":"发起检索成功","k_0fdeled":"发起检索失败","k_1yh0a50":"mapDidLoad-地图加载完成","k_1t2zg6h":"图片验证码校验失败","k_03ibg5h":"星期一","k_03i7hu1":"星期二","k_03iaiks":"星期三","k_03el9pa":"星期四","k_03i7ok1":"星期五","k_03efxyg":"星期六","k_03ibfd2":"星期七","k_0k3uv02":"服务器错误：\$option8","k_1g9o3kz":"请求错误：\$option8","k_003nfx9":"深沉","k_003rvjp":"轻快","k_003rtht":"明媚","k_003qxiw":"梦幻"}''';
}
