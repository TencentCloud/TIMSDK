import 'dart:ui';

import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/pages/conversion/component/custommessage.dart';
import 'package:discuss/pages/conversion/component/filemessage.dart';
import 'package:discuss/pages/conversion/component/imagemessage.dart';
import 'package:discuss/pages/conversion/component/merge_message.dart';
import 'package:discuss/pages/conversion/component/soundmessage.dart';
import 'package:discuss/pages/conversion/component/videomessage.dart';
import 'package:discuss/provider/historymessagelistprovider.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:discuss/provider/multiselect.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:discuss/utils/const.dart';
// import 'package:flutter_autosize_screen/auto_size_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class CommonMessageContent extends StatefulWidget {
  final V2TimMessage message;
  final String selectedMsgId;
  final void Function(String msgId) setSelectedMsgId;
  const CommonMessageContent(
      {Key? key,
      required this.message,
      required this.selectedMsgId,
      required this.setSelectedMsgId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CommonMessageContentState();
}

class CommonMessageContentState extends State<CommonMessageContent> {
  SuperTooltip? tooltip;
  GlobalKey _globalKey = GlobalKey();
  @override
  initState() {
    super.initState();
    initTools();
  }

  List<Widget> getAction() {
    Color c = hexToColor("444444");
    List<Map<String, dynamic>> origin = [
      {
        "name": '复制',
        "icon": Icon(
          Icons.copy_all_outlined,
          color: c,
        ),
      },
      {
        "name": '多选',
        "icon": Icon(
          Icons.fact_check_outlined,
          color: c,
        ),
      },
      {
        "name": '删除',
        "icon": Icon(
          Icons.delete_sweep_outlined,
          color: c,
        ),
      },
      {
        "name": '引用',
        "icon": Icon(
          Icons.quickreply_outlined,
          color: c,
        ),
      }
    ];
    return origin
        .map(
          (e) => SizedBox(
            width: 50,
            child: InkWell(
              onTap: () {
                handleLongPress(e['name'], context);
              },
              child: Column(
                children: [
                  e['icon'],
                  Text(
                    e['name'],
                    style: TextStyle(
                      color: c,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  String getMessageCanCopy() {
    return "";
  }

  bodyMessage() async {
    if (widget.message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      await Clipboard.setData(ClipboardData(text: getMessageCanCopy()));
      Utils.toast("已复制到剪切板");
    } else {
      Utils.toast("该消息不能复制");
    }
  }

  // 更新打开状态，并直接选中多选框
  openMultiSelector(context) {
    String selectorId;
    String msgID = widget.message.msgID!;
    if (widget.message.groupID != null) {
      selectorId = widget.message.groupID!;
    } else {
      selectorId = widget.message.userID!;
    }
    Provider.of<MultiSelect>(context, listen: false)
        .updateSeletor(selectorId, msgID);
    Provider.of<MultiSelect>(context, listen: false).upateIsOpen(true);
  }

  deleteMessage(context) async {
    String selectId;
    int type = 1;
    if (widget.message.groupID == null) {
      selectId = widget.message.userID!;
    } else {
      selectId = widget.message.groupID!;
      type = 2;
    }
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .deleteMessages(msgIDs: [widget.message.msgID!]);
    if (res.code == 0) {
      Utils.toast("删除成功");
      String key = (type == 1 ? "c2c_$selectId" : "group_$selectId");

      Provider.of<HistoryMessageListProvider>(context, listen: false)
          .deleteMessage(key, [widget.message.msgID!]);
    } else {
      Utils.toast("删除失败 ${res.code} ${res.desc}");
    }
  }

  replyMessage() {
    Provider.of<KeyBoradModel>(context, listen: false)
        .jumpToScrollControllerBottom();
    Provider.of<KeyBoradModel>(context, listen: false).showkeyborad();
    Provider.of<KeyBoradModel>(context, listen: false).keyBoardFocus();
    Provider.of<KeyBoradModel>(context, listen: false).setReplyMessage(
      widget.message,
    );
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  handleLongPress(item, context) {
    switch (item) {
      case "复制":
        bodyMessage();
        break;
      case "多选":
        openMultiSelector(context);
        break;
      case "删除":
        deleteMessage(context);
        break;
      case "引用":
        replyMessage();
        break;
    }
    tooltip!.close();
  }

  initTools() {
    tooltip = SuperTooltip(
      popupDirection: TooltipDirection.up,
      minimumOutSidePadding: 0,
      arrowTipDistance: 10,
      arrowBaseWidth: 10.0,
      arrowLength: 20.0,
      right: widget.message.isSelf! ? 60 : null,
      left: widget.message.isSelf! ? null : 60,
      borderColor: Colors.white,
      backgroundColor: Colors.white,
      shadowColor: Colors.black26,
      hasShadow: true,
      borderWidth: 1.0,
      showCloseButton: ShowCloseButton.none,
      touchThroughAreaShape: ClipAreaShape.rectangle,
      content: SizedBox(
        height: 42,
        width: 200,
        child: Row(
          children: getAction(),
        ),
      ),
    );
  }

  bool isC2CMessage() {
    return widget.message.userID != null;
  }

  String buildTimeString() {
    var nowTime = DateTime.now();
    nowTime = DateTime(nowTime.year, nowTime.month, nowTime.day);
    var ftime =
        DateTime.fromMillisecondsSinceEpoch(widget.message.timestamp! * 1000);
    var preFix = ftime.hour >= 12 ? '下午' : '上午';
    final timeStr = DateFormat('hh:mm').format(ftime);
    // 一年外 年月日 + 上/下午 + 时间 (12小时制)
    if (nowTime.year != ftime.year) {
      return '${DateFormat('yyyy年MM月dd').format(ftime)} $preFix $timeStr';
    }
    // 一年内一周外 月日 + 上/下午 + 时间 (12小时制）
    if (ftime.isBefore(nowTime.subtract(const Duration(days: 7)))) {
      return '${DateFormat('MM月dd').format(ftime)} $preFix $timeStr';
    }
    // 一周内一天外 星期 + 上/下午 + 时间 (12小时制）
    if (ftime.isBefore(nowTime.subtract(const Duration(days: 1)))) {
      return '${Const.weekdayMap[ftime.weekday]} $preFix $timeStr';
    }
    // 昨日 昨天 + 上/下午 + 时间 (12小时制)
    if (nowTime.day != ftime.day) {
      return '昨天 $preFix $timeStr';
    }
    // 同年月日 上/下午 + 时间 (12小时制)
    return '$preFix $timeStr';
  }

  bool isSelf() {
    return widget.message.isSelf!;
  }

  bool needMargin() {
    return !isC2CMessage() && !isSelf();
  }

  double getMaxWidth(isSelect) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return width - (isSelect ? 180 : 130);
  }

  Widget buildTextMessage() {
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(
        minHeight: 40,
      ),
      decoration: BoxDecoration(
        color: isSelf() ? hexToColor("DCEAFD") : hexToColor("ECECEC"),
        borderRadius: BorderRadius.only(
          topLeft: isSelf() ? const Radius.circular(10) : Radius.zero,
          bottomLeft: const Radius.circular(10),
          topRight: isSelf() ? Radius.zero : const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
      ),
      child: Text(widget.message.textElem!.text!),
    );
  }

  Widget buildTimeMessage() {
    return Container(
        constraints: const BoxConstraints(
          minHeight: 40,
        ),
        child: Center(
          child: Text(buildTimeString(),
              style: TextStyle(color: hexToColor("B7B7B7"), fontSize: 12)),
        ));
  }

  Widget buildContentCommon(Widget child) {
    return GestureDetector(
      child: child,
      onLongPress: () {
        if (tooltip == null) {
          Utils.log("tooltips 未初始化好");
        } else {
          Provider.of<KeyBoradModel>(context, listen: false).replyMessage;
          int msgInputHeight = replyMessage == null ? 55 : 100;
          // 组件高度
          final containerHeight = _globalKey.currentContext!.size!.height;

          final renderBox =
              _globalKey.currentContext!.findRenderObject() as RenderBox;

          var dy = renderBox.localToGlobal(Offset.zero).dy;
          // 导航栏高度
          var navigationHeight = MediaQueryData.fromWindow(window).padding.top;
          // 底部区域高度
          var bottomContentHeight =
              MediaQueryData.fromWindow(window).padding.bottom + msgInputHeight;
          // 屏幕高度
          var screenHeight = MediaQuery.of(context).size.height;
          if (dy < 0) {
            tooltip!.popupDirection = TooltipDirection.down;
            // dy > -navigationHeight ? tooltip!.show(context) : "";
          } else {
            tooltip!.popupDirection = TooltipDirection.up;
          }
          tooltip!.show(context);

          print(
              "containerHeight:$containerHeight,dy:$dy,,defaultTop:$navigationHeight,defaultBottom:$bottomContentHeight,screenHeight:$screenHeight");
        }
      },
    );
  }

  Widget buildContent() {
    int type = widget.message.elemType;
    Widget res;
    switch (type) {
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        res = buildContentCommon(
          ImageMessage(
              message: widget.message,
              isSelect: Provider.of<MultiSelect>(context).isopen),
        );
        break;
      // 自定义消息存在cloudCustomData中，回复消息的replyMessage只有文本
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        {
          // 当为TextMessage时
          if (widget.message.cloudCustomData == null ||
              widget.message.cloudCustomData == "") {
            res = buildContentCommon(buildTextMessage());
          } else {
            // 当为回复消息时
            res = buildContentCommon(CustomMessage(
                message: widget.message,
                selectedMsgId: widget.selectedMsgId,
                setSelectedMsgId: widget.setSelectedMsgId));
          }
          break;
        }

      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        res = buildContentCommon(CustomMessage(
            message: widget.message,
            selectedMsgId: widget.selectedMsgId,
            setSelectedMsgId: widget.setSelectedMsgId));
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        res = buildContentCommon(SoundMessage(
            message: widget.message,
            selectedMsgId: widget.selectedMsgId,
            setSelectedMsgId: widget.setSelectedMsgId));
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        res = buildContentCommon(VideoMessage(widget.message));
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        res = buildContentCommon(FileMessage(widget.message));
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        res = buildContentCommon(MergeMessage(
          message: widget.message,
        ));
        break;
      case Const.V2TIM_ELEM_TYPE_TIME:
        res = buildTimeMessage();
        break;
      default:
        res = buildContentCommon(Container());
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    bool isSelect = Provider.of<MultiSelect>(context).isopen;
    return Container(
      key: _globalKey,
      constraints: BoxConstraints(
        maxWidth: getMaxWidth(isSelect),
      ),
      margin: EdgeInsets.only(
        top: needMargin() ? 4 : 0,
        right: 10,
        left: 10,
      ),
      child: buildContent(),
    );
  }
}
