import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin_example/provider/keybooadshow.dart';

class VoiceMsg extends StatefulWidget {
  VoiceMsg(this.toUser, this.type);
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

  void initState() {
    this.toUser = widget.toUser;
    this.type = widget.type;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool show = Provider.of<KeyBoradModel>(context).show;
    return Container(
      width: 56,
      height: 56,
      child: InkWell(
        child: Icon(
          show ? Icons.keyboard_voice : Icons.keyboard,
          size: 28,
          color: Colors.black,
        ),
        onTap: () {
          toggleKeyBord();
        },
      ),
    );
  }
}
