import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MergeMessage extends StatefulWidget {
  final V2TimMessage message;

  const MergeMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MergeMessageState();
}

class MergeMessageState extends State<MergeMessage> {
  @override
  initState() {
    Utils.log("merge message ${widget.message.toJson()}");
    super.initState();
  }

  isSelf() {
    return widget.message.isSelf;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isSelf() ? const Radius.circular(10) : Radius.zero,
          bottomLeft: const Radius.circular(10),
          topRight: isSelf() ? Radius.zero : const Radius.circular(10),
          bottomRight: const Radius.circular(10),
        ),
        border: Border.all(
          color: hexToColor("dddddd"),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          await TencentImSDKPlugin.v2TIMManager
              .getMessageManager()
              .downloadMergerMessage(
                msgID: widget.message.msgID!,
              );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message.mergerElem!.title!,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: widget.message.mergerElem!.abstractList!
                    .map(
                      (e) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              e,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: hexToColor("dddddd"),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "聊天记录",
                    style: TextStyle(
                      color: hexToColor("888888"),
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
