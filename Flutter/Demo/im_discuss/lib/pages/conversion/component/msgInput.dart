import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/provider/keybooadshow.dart';
import 'package:flutter/widgets.dart';
import 'package:discuss/pages/conversion/component/addadvancemsg.dart';
import 'package:discuss/pages/conversion/component/addfacemsg.dart';
import 'package:discuss/pages/conversion/component/addtextmsg.dart';
import 'package:discuss/pages/conversion/component/addvoicemsg.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MsgInput extends StatelessWidget {
  MsgInput(this.toUser, this.type, this.recordBackStatus,
      {this.lastDraftText, Key? key})
      : super(key: key);
  final String toUser;
  final int type;
  final bool recordBackStatus;
  String? lastDraftText;

  @override
  Widget build(BuildContext context) {
    V2TimMessage? replyMessage =
        Provider.of<KeyBoradModel>(context).replyMessage;
    return Container(
      height: replyMessage == null ? 55 : 100,
      decoration: BoxDecoration(
        color: hexToColor("EBF0F6"),
        border: Border(
          top: BorderSide(
            color: hexToColor("dddddd"),
          ),
        ),
      ),
      child: Row(
        children: [
          VoiceMsg(toUser, type),
          TextMsg(toUser, type, recordBackStatus, lastDraftText: lastDraftText),
          FaceMsg(toUser, type),
          AdvanceMsg(toUser, type),
        ],
      ),
    );
  }
}
