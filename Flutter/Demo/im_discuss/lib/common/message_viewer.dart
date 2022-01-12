import 'package:discuss/pages/conversion/component/conversationinner.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class MessageViewer extends StatefulWidget {
  final List<V2TimMessage> messageList;
  const MessageViewer({
    Key? key,
    required this.messageList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MessageViewerState();
}

class MessageViewerState extends State<MessageViewer> {
  ScrollController scrollController =
      ScrollController(initialScrollOffset: 0.0);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: SingleChildScrollView(
          controller: scrollController,
          reverse: false, //注意设置为反向
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: MessageList(
            currentMessageList: widget.messageList,
          ),
        ),
      ),
    );
  }
}
