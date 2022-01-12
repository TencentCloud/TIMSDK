import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:discuss/provider/keybooadshow.dart';

class VoiceMsg extends StatefulWidget {
  const VoiceMsg(this.toUser, this.type, {Key? key}) : super(key: key);
  final String toUser;
  final int type;
  @override
  State<StatefulWidget> createState() => VoiceMsgState();
}

class VoiceMsgState extends State<VoiceMsg> {
  String? toUser;
  int? type;
  bool keybordshow = true;
  toggleKeyBord() {
    setState(() {
      keybordshow = !keybordshow;
    });
    Provider.of<KeyBoradModel>(context, listen: false).setStatus(keybordshow);
  }

  @override
  void initState() {
    toUser = widget.toUser;
    type = widget.type;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboradshow = Provider.of<KeyBoradModel>(context).show;
    return SizedBox(
      width: 56,
      height: 56,
      child: InkWell(
        child: Icon(
          isKeyboradshow ? Icons.keyboard_voice : Icons.keyboard,
          size: 28,
          color: hexToColor("444444"),
        ),
        // 显示键盘还是语音图标的切换
        // 点击切换键盘时
        onTap: () {
          print("你可是当显示点击图标$keybordshow");
          // 当显示的是键盘逻辑走这个
          if (!keybordshow) {
            print("你可是当显示的是键盘图标时");
            Provider.of<KeyBoradModel>(context, listen: false).keyBoardFocus();
            Provider.of<KeyBoradModel>(context, listen: false)
                .setBottomConToKeyBoard();
          } else {
            //当显示的是语音图标时走这个

            Provider.of<KeyBoradModel>(context, listen: false)
                .keyBoardUnfocus();
            Provider.of<KeyBoradModel>(context, listen: false)
                .setBottomConToEmpty();
          }
          toggleKeyBord();
        },
      ),
    );
  }
}
