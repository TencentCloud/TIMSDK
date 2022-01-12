import 'package:discuss/provider/keybooadshow.dart';

import 'package:flutter/material.dart';
import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/models/emoji/emoji.dart';
import 'package:discuss/utils/emojidata.dart';
import 'package:provider/provider.dart';

class FaceMsg extends StatelessWidget {
  const FaceMsg(this.toUser, this.type, {Key? key}) : super(key: key);
  final String toUser;
  final int type;

  Future<int?> openPanel(context) {
    close() {
      Navigator.pop(context);
    }

    Widget faceContainer(BuildContext context) {
      return Container(
        height: 246,
        color: hexToColor('ededed'),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1,
          ),
          children: emojiData.map(
            (e) {
              var item = Emoji.fromJson(e);
              return EmojiItem(
                name: item.name,
                unicode: item.unicode,
                toUser: toUser,
                type: type,
                close: close,
              );
            },
          ).toList(),
        ),
      );
    }

    return showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return faceContainer(context);
      },
    );
  }

  showFaceContainer(
    BuildContext context,
  ) {
    Provider.of<KeyBoradModel>(context, listen: false).setBottomConToFace();
    Provider.of<KeyBoradModel>(context, listen: false).keyBoardUnfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton(
          icon: Icon(
            Icons.tag_faces,
            size: 28,
            color: hexToColor("444444"),
          ),
          onPressed: () async {
            Provider.of<KeyBoradModel>(context, listen: false)
                .jumpToScrollControllerBottom();
            showFaceContainer(context);
            // 为了显示输入框
            Provider.of<KeyBoradModel>(context, listen: false).setStatus(true);
            // await openPanel(context);
          }),
    );
  }
}
