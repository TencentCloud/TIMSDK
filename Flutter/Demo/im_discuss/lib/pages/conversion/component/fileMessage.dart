import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/utils/toast.dart';

class FileMessage extends StatelessWidget {
  final V2TimMessage message;
  const FileMessage(this.message, {Key? key}) : super(key: key);
  isC2CMessage() {
    return message.userID != null;
  }

  getFileName() {
    Utils.log(message.fileElem!.toJson());
    try {
      return Uri.decodeFull(message.fileElem!.fileName!);
    } catch (e) {
      return Uri.encodeComponent(message.fileElem!.fileName!);
    }
  }

  isSelf() {
    return message.isSelf;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Utils.toast("下载功能，业务可自行实现");
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 1,
            style: BorderStyle.solid,
            color: hexToColor("dddddd"),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isSelf() ? const Radius.circular(10) : Radius.zero,
            bottomLeft: const Radius.circular(10),
            topRight: isSelf() ? Radius.zero : const Radius.circular(10),
            bottomRight: const Radius.circular(10),
          ),
        ),
        child: Container(
          color: CommonColors.getWitheColor(),
          child: Row(
            textDirection:
                message.isSelf! ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getFileName(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 16,
                          color: hexToColor("111111"),
                        ),
                      ),
                      Text(
                        "${(message.fileElem!.fileSize! / 1024).ceil()} KB",
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14,
                          color: hexToColor('888888'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.file_present_outlined,
                  color: Colors.red,
                  size: 40,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
