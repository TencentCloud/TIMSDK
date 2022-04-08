import 'dart:convert';

import 'package:im_api_example/i18n/strings.g.dart';

final I18nUtils ttBuild = I18nUtils();
String imt(String value) => ttBuild._imt(value);
Function imt_para(String template, String value) => ttBuild._imt_parameter(template, value);

class I18nUtils {
  I18nUtils._internal(){
    _init();
  }
  factory I18nUtils() => _instance;
  static late final I18nUtils _instance = I18nUtils._internal();

  Map<String, dynamic> zhMap = {};
  Map zhMapRevert = {};
  RegExp expForParameterOut = new RegExp(r"{{[^]+}}");
  RegExp expForParameter = new RegExp(r"(?<=\{{)[^}]*(?=\}})");

  void _init(){
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
    final originTemplate = template.replaceAllMapped(expForParameterOut, (Match m) => replaceParameterForTemplate(m));
    final originKey = zhMapRevert[originTemplate] ?? getKeyFromMap(zhMap, originTemplate) ?? "";
    final Function translatedValueFunction = t[originKey] ?? textErrorFunction;
    return translatedValueFunction;
  }

  String replaceParameterForTemplate(Match value){
    final String? parameter = expForParameter.stringMatch(value[0] ?? "");
    return "\$$parameter";
  }

  static String textErrorFunction ([String? option]){
    return "文本错误";
  }

  static String getKeyFromMap(Map map, String key){
    String currentKey = "";
    for(String tempKey in map.keys){
      if(map[tempKey] == key){
        currentKey = tempKey;
        break;
      }
    }
    return currentKey;
  }

  static Map revertMap(Map map){
    final Map<String, String> newMap = new Map();
    for(String tempKey in map.keys){
      newMap[map[tempKey]] = tempKey;
    }
    return newMap;
  }

  static int getHashValue(String text){
    "use strict";

    var hash = 5381,
        index = text.length;

    while (index > 0) {
      hash = (hash * 33) ^ text.codeUnitAt(--index);
    }

    return hash;
  }

  final zhJson = '''{"k_0fdrjph":"事件回调","k_15b7vxl":"基础模块","k_1f157p5":"初始化SDK","k_06n8uqh":"sdk 初始化","k_05a3xy6":"添加事件监听","k_1opua40":"事件监听应先于登录方法前添加，以防漏消息","k_0ptv10l":"获取服务端时间","k_02r2v09":"sdk 获取服务端时间","k_003r6vf":"登录","k_0z9427p":"sdk 登录接口，先初始化","k_003ph6s":"登出","k_1wu4tcs":"发送C2C文本消息（3.6版本已弃用）","k_1t6awxa":"发送C2C自定义消息（3.6版本已弃用）","k_0pwzyvl":"发送Group文本消息（3.6版本已弃用）","k_1ntp677":"发送Group自定义消息（3.6版本已弃用）","k_1j35r5o":"获取 SDK 版本","k_0kt7otn":"获取当前登录用户","k_1v7brb7":"获取当前登录状态","k_0x1tylx":"获取用户信息","k_0elsjm2":"创建群聊","k_0elrwzy":"加入群聊","k_0elt2dt":"退出群聊","k_0em2iiz":"解散群聊","k_0qq6zvv":"设置个人信息","k_11deha5":"试验性接口","k_15a012s":"会话模块","k_1xdajb0":"获取会话列表","k_1rgdedc":"获取会话详情","k_0glns86":"删除会话","k_0xzd96m":"设置会话为草稿","k_0dg9tmi":"会话置顶","k_1vmox4p":"获取会话未读总数","k_15b6qz8":"消息模块","k_1yns1w9":"发送文本消息","k_0zq67yj":"发送自定义消息","k_1um4zaj":"发送图片消息","k_0bgy5ol":"发送视频消息","k_05gsxdv":"发送文件消息","k_0axzzec":"发送录音消息","k_02blxws":"发送文本At消息","k_1um3h9j":"发送地理位置消息","k_1x28z5r":"发送表情消息","k_0310ebw":"发送合并消息","k_00afgq7":"发送转发消息","k_13sdbcu":"重发消息","k_12w209p":"修改本地消息（String）","k_199jsqj":"修改本地消息（Int）","k_0ktebqj":"修改云端消息（String-已弃用）","k_0k6jqud":"获取C2C历史消息","k_0bf7otk":"获取Group历史消息","k_1fbo5v2":"获取历史消息高级接口","k_1asy1yf":"获取历史消息高级接口（不格式化）","k_13sdxko":"撤回消息","k_1vlsgoe":"标记C2C会话已读","k_17fh8gz":"标记Group会话已读","k_16sb1e7":"标记所有消息为已读","k_01q04pm":"删除本地消息","k_13sqfye":"删除消息","k_1saxzrf":"向group中插入一条本地消息","k_075u68x":"向c2c会话中插入一条本地消息","k_16tukku":"清空单聊本地及云端的消息","k_13z9nvj":"获取用户消息接收选项","k_182b8ni":"清空群组单聊本地及云端的消息","k_01qv9eo":"搜索本地消息","k_0bfyrre":"查询指定会话中的本地消息","k_0mz8nlf":"好友关系链模块","k_10ig2ml":"获取好友列表","k_0q5feak":"获取好友信息","k_16758qw":"添加好友","k_0q5kkj1":"设置好友信息","k_1666obb":"删除好友","k_167fad4":"检测好友","k_15gn1d5":"获取好友申请列表","k_05576s4":"同意好友申请","k_055cno8":"拒绝好友申请","k_0m517oy":"获取黑名单列表","k_042sv53":"添加到黑名单","k_1oybli5":"从黑名单移除","k_05jmpkg":"创建好友分组","k_05jnyuo":"获取好友分组","k_05jcbyt":"删除好友分组","k_14xxze4":"重命名好友分组","k_14kqmvu":"添加好友到分组","k_00mp87q":"从分组中删除好友","k_167cp0t":"搜索好友","k_15b6vqr":"群组模块","k_1j2fn17":"高级创建群组","k_16mti73":"获取加群列表","k_0suniq6":"获取群信息","k_0supwn3":"设置群信息","k_1ojrrgd":"获取群在线人数","k_1pb3f1z":"获取群成员列表","k_1gx3i86":"获取群成员信息","k_1gwzvg7":"设置群成员信息","k_0h1ttfs":"禁言群成员","k_0c9tkhn":"邀请好友进群","k_11yzdz7":"踢人出群","k_0uupir5":"设置群角色","k_18pxx1p":"转移群主","k_0r4h8ww":"搜索群列表","k_0h1m7ef":"搜索群成员","k_15az05y":"信令模块","k_0gzsnbo":"发起邀请","k_1ifjitt":"在群组中发起邀请","k_0qr6nnz":"获取信令信息","k_0hsgjrg":"添加邀请信令","k_1499er2":"添加邀请信令（可以用于群离线推送消息触发的邀请信令）","k_1rmuiim":"离线推送模块","k_1uobs68":"上报推送配置","k_18ufun0":"注册事件","k_0dyrkl5":"注销simpleMsgListener事件","k_1q2xs9c":"注销所有simpleMsgListener事件","k_0fyg1xs":"注销advanceMsgListener","k_0awkp15":"注销所有advanceMsgListener","k_12oryz1":"注销signalingListener","k_1xb912c":"注销所有signalingListener","k_1r092x8":"注销gruopListener","k_1ec07ke":"被添加好友ID","k_14bwl8c":"好友备注","k_121555d":"好友分组","k_0qbtor0":"好友分组，首先得有这个分组","k_0gavw6m":"添加简述","k_15ihgoz":"好友类型","k_1675qge":"双向好友","k_1675qk7":"单向好友","k_1eopfpu":"选择优先级","k_0socms9":"已选：\$addType","k_03c51e7":"未选择","k_0ethd0p":"添加信令信息（选择已有的信令信息进行测试）","k_15i526p":"删除类型","k_1ciwziu":"同意添加双向好友","k_19iuz0v":"同意添加单向好友","k_0ix65gm":"选择同意类型类型","k_14awofe":"已选：\$friendType","k_0gw88si":"同意申请","k_0xxojzb":"收到的事件回调","k_0quw2i5":"单选只能选一个呀","k_002r2pl":"单选","k_002r1h2":"多选","k_0w8a6yi":"黑名单好友选择（\$chooseType）","k_002v9zj":"确认","k_003nevv":"取消","k_03mgr50":"请先在好友关系链模块中添加好友","k_1ic4dp6":"选择黑名单好友","k_161zzkm":"请输入用户名","k_00alow4":"调用实验性接口：初始化本地数据库（您可以在SDK中自行尝试其他接口）","k_1xogzdp":"调用实验性接口","k_15ijita":"检测类型","k_0y8ersu":"选择检测类型","k_1e74ake":"已选：\$checkType","k_0iilkht":"清空单聊本地及云端的消息（不删除会话）","k_0szs46i":"获取群组信息","k_1pli0aq":"会话选择（\$chooseType）","k_0hqslym":"暂无会话信息","k_0gmqf8i":"选择会话","k_03eu3my":"分组名","k_03768rw":"群ID","k_1vjwjey":"选填（如填，则自定义群ID）","k_03agq58":"群名称","k_0kg1wsx":"选择群类型","k_0lzvumx":"Work 工作群","k_0mbokjw":"Public 公开群","k_028lr1o":"Meeting 会议群","k_1te7y0e":"AVChatRoom 直播群","k_0itcz3b":"已选：\$groupType","k_03avhuo":"创建群","k_03es1ox":"群类型","k_0wqztai":"群类型：Work","k_0shjk7e":"群类型：Public","k_1qrpwz6":"群类型：Meeting","k_0jmohdb":"群类型r：AVChatRoom","k_03f295d":"群通告","k_03i9mfe":"群简介","k_03fchyy":"群头像","k_11msgmy":"选择群头像","k_1gyj2yl":"是否全员禁言","k_0zo1d5d":"选择加群类型","k_0o7jsdm":"已选：\$addOpt","k_18epku7":"高级创建群","k_0m7f240":"从黑名单中移除","k_0m3mh75":"选择删除类型","k_0is52zl":"已选：\$deleteType","k_11vvszp":"解散群组","k_0q8ddw7":"好友申请选择（\$chooseType）","k_1pyaxto":"目前没有好友申请","k_0556th3":"选择好友申请","k_1pm8o4n":"分组选择（\$chooseType）","k_121ewqv":"选择分组","k_1pmg14j":"好友选择（\$chooseType）","k_167dvo3":"选择好友","k_0q9n4ea":"要查询的用户: \$userStr","k_1qdxkv0":"查询针对某个用户的 C2C 消息接收选项（免打扰状态）","k_13v2x0e":"获取好友分组信息","k_0v51dmo":"已选：\$filter","k_0rnrkt5":"获取在线人数","k_0jd2nod":"选择type","k_1laca48":"已选：\$type","k_1mm5bjo":"获取历史消息高级接口（格式化数据）","k_1b1tzii":"获取native sdk版本号","k_0h1otop":"选择群成员","k_1pm8vid":"群组选择（\$chooseType）","k_1ksi75r":"请先加入群组","k_11vv63p":"选择群组","k_03fglvp":"初始化","k_0xpwna0":"要查询的用户: \$senderStr","k_132xs0u":"发送文本","k_17argoi":"文本内容","k_1qjjcx0":"是否仅在线用户接受到消息","k_002ws2a":"邀请","k_1bc6l5x":"进群打招呼Message","k_11vsj5s":"加入群组","k_0812nh1":"踢群成员出群","k_1uz99pq":"标记c2c会话已读","k_17fhxqb":"标记group会话已读","k_13sbhj6":"选择消息","k_1gw84h2":"禁言群成员信息","k_0mf7epf":"会话置顶/取消置顶","k_11vsa3j":"退出群组","k_0stba5l":"别人发给我的","k_09ezm4w":"我发别人的","k_0w3vj1s":"请求类型类型","k_16cx0kq":"别人发给我的加好友请求","k_07d9n7u":"我发给别人的加好友请求","k_15ilfmd":"选择类型","k_17zxeit":"已选：\$chooseType","k_0gw8cb2":"拒绝申请","k_15khfil":"旧分组名","k_15khfh6":"新分组名","k_1cgc6p5":"搜索关键字列表，最多支持5个","k_1csi4tv":"关键字(example只有设置了一个关键字)","k_0q9wh26":"设置是否搜索userID","k_1p7cxk7":"是否设置搜索昵称","k_14mm3m5":"设置是否搜索备注","k_03g1hin":"关键字","k_0xtvoya":"设置是否搜索群成员 userID","k_0musqvf":"设置是否搜索群成员昵称","k_0v2tnyc":"设置是否搜索群成员名片","k_0fgvqsh":"设置是否搜索群成员备注","k_0di7h2o":"搜索关键字(最多支持五个，example只支持一个)","k_139zdqj":"设置是否搜索群 ID","k_0rbflyz":"设置是否搜索群名称","k_0t9qj8k":"搜索Group","k_03rrahs":"关键字(必填)","k_0vl6shl":"关键字（接口支持5个，example支持一个）","k_1p5f8xt":"查询本地消息(不指定会话不返回messageList)","k_0wmcksi":"自定义数据","k_1wjd1o3":"发送C2C自定义消息（弃用）","k_0qqamgs":"发送C2C文本消息（已经弃用）","k_17ix8wi":"自定义数据data","k_01cqw1f":"自定义数据desc","k_0gmtcyj":"自定义数据extension","k_03b2yxe":"优先级","k_1qkm7de":"已选：\$priority","k_1wmh4z7":"发送消息是否不计入未读数","k_02nlunm":"自定义localCustomData","k_121pu0b":"表情位置","k_13mefja":"表情信息","k_1krj2k5":"自定义localCustomData(File)","k_18ni1o4":"选择文件","k_1bbh6rj":"自定义localCustomData(sendForwardMessage)","k_13sda1r":"转发消息","k_08lezoy":"发送自定义数据","k_05wotoe":"发送Group自定义消息(弃用)","k_0ayxzy6":"发送Group文本消息（已弃用）","k_0kotqjn":"自定义localCustomData(sendImageMessage)","k_111hdgc":"选择图片","k_060rdwo":"地理位置消息描述","k_0lbz4k9":"自定义localCustomData(sendLocationMessage)","k_1qpk5nl":"获取当前地理位置信息","k_0yn59ns":"XXX与XXX的会话","k_1k1pnl2":"低版本不支持会会收到文本消息","k_07uflzi":"自定义localCustomData(sendMergerMessage)","k_13sgi0s":"合并消息","k_09inq13":"自定义localCustomData(sendSoundMessage)","k_0svi3rz":"删除文件成功","k_0bt4pm7":"结束录音","k_0bt6ctk":"开始录音","k_03eztxo":"未录制","k_19xq0ad":"自定义localCustomData(sendVideoMessage)","k_0d6yawi":"选择视频","k_13qknk5":"云端数据","k_0wnmtb3":"云端修改消息（String）","k_09qx4fw":"草稿内容，null为取消","k_1y65mf8":"设置草稿/取消草稿","k_1f4rg84":"设置会话草稿","k_02my10h":"群角色","k_0uuoz6p":"选择群角色","k_16owmwk":"已选：\$role","k_1qe4r7d":"设置群成员角色","k_0wng8yl":"本地修改消息（String）","k_1go5et7":"本地修改消息（Int）","k_15wdhxq":"注册成功","k_0yj1my7":"证书id","k_18e393e":"控制台上传证书返回的id","k_0003v6a":"男","k_00043x2":"女","k_0ghstt4":"允许所有人加我好友","k_1b3mn6t":"不允许所有人加我好友","k_1mo5v9d":"加我好友许我确认","k_003lhvk":"昵称","k_003q1na":"签名","k_1hgdu7c":"生日(int类型，不要输入字符串)","k_003m6hr":"生日","k_003qgkp":"性别","k_15xu6ax":"选择性别","k_1pgjz7s":"加好友验证方式","k_0r291dl":"加我好友需我确认","k_16vvwv0":"已选：\$chooseAllowType","k_003qk66":"头像","k_161i8im":"选择头像","k_003l8z3":"提示","k_142aglh":"检测到您还未配置应用信息，请先配置","k_03bd50d":"去配置","k_13m956w":"配置信息","k_1prb9on":"sdkappid，控制台去申请","k_1fen6m9":"secret，控制台去申请","k_1xp25m6":"userID，随便填","k_12clf4v":"确认设置","k_0um8vqm":"清除所有配置","k_152jijg":"添加字段","k_0jbia4f":"已设置字段：","k_0md2ud6":"字段名不能为空","k_05nspni":"自定义字段","k_03eyrxm":"字段名","k_181l8gl":"请在控制台查看","k_03fj93v":"字段值","k_003rzap":"确定","k_0f2heqk":"code=0 业务成功 code!=0 业务失败，请在腾讯云即时通信文档文档查看对应的错误码信息。\\n","k_0hzbevw":"\$type触发\\n"}''';

}