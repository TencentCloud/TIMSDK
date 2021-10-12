import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:im_api_example/utils/toast.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

typedef OnSelect(List<String> data);
typedef OnSelectItemChange(String conversationID);

class ConversationSelector extends StatefulWidget {
  final OnSelect onSelect;
  final bool switchSelectType;
  final List<String> value;
  ConversationSelector(
      {required this.onSelect,
      this.switchSelectType = true,
      required this.value});

  @override
  State<StatefulWidget> createState() => ConversationSelectorState();
}

class ConversationItem extends StatefulWidget {
  final bool switchSelectType;
  final OnSelectItemChange onSelectItemChange;
  final V2TimConversation info;
  final List<String> selected;
  ConversationItem(
    this.switchSelectType,
    this.info,
    this.selected, {
    required this.onSelectItemChange,
  });

  @override
  State<StatefulWidget> createState() => ConversationItemState();
}

class ConversationItemState extends State<ConversationItem> {
  bool itemSelect = false;
  List<String> selected = List.empty(growable: true);
  void initState() {
    super.initState();
    setState(() {
      selected = widget.selected;
      itemSelect = widget.selected.contains(widget.info.conversationID);
    });
  }

  onItemTap(String conversationID, [bool? data]) {
    if (widget.switchSelectType) {
      // 单选
      if (widget.selected.length > 0) {
        String selectedconversationID = widget.selected.first;
        if (selectedconversationID != conversationID) {
          Utils.toast("单选只能选一个呀");
          return;
        }
      }
    }
    if (data != null) {
      this.setState(() {
        itemSelect = data;
      });
    } else {
      this.setState(() {
        itemSelect = !itemSelect;
      });
    }
    widget.onSelectItemChange(conversationID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: InkWell(
        onTap: () {
          onItemTap(widget.info.conversationID);
        },
        child: Row(
          children: [
            Checkbox(
              value: itemSelect,
              onChanged: (data) {
                onItemTap(widget.info.conversationID, data);
              },
            ),
            Expanded(
              child: Text("ID:${widget.info.conversationID}"),
            )
          ],
        ),
      ),
    );
  }
}

class ConversationList extends StatefulWidget {
  final bool switchSelectType;
  final List<V2TimConversation?>? conversation;
  final OnSelect onSelect;
  final List<String> value;
  ConversationList(
      this.switchSelectType, this.conversation, this.onSelect, this.value);
  @override
  State<StatefulWidget> createState() => ConversationListState();
}

class ConversationListState extends State<ConversationList> {
  void initState() {
    super.initState();
    setState(() {
      selected = widget.value;
    });
  }

  List<String> selected = List.empty(growable: true);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: new ListView.builder(
        primary: true,
        shrinkWrap: true,
        itemCount: widget.conversation!.length,
        itemBuilder: (context, index) {
          return ConversationItem(
            widget.switchSelectType,
            widget.conversation![index]!,
            selected,
            onSelectItemChange: (conversationID) {
              if (selected.contains(conversationID)) {
                selected.remove(conversationID);
              } else {
                selected.add(conversationID);
              }
              widget.onSelect(selected);
            },
          );
        },
      ),
    );
  }
}

class ConversationSelectorState extends State<ConversationSelector> {
  void initState() {
    super.initState();
    setState(() {
      selected = widget.value;
    });
  }

  List<String> selected = List.empty(growable: true);
  List<V2TimConversation?>? conversationList = List.empty();

  Future<List<V2TimConversation?>?> getConversationList() async {
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    V2TimValueCallback<V2TimConversationResult> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(nextSeq: "0", count: 300);
    EasyLoading.dismiss();
    if (res.code != 0) {
      Utils.toastError(res.code, res.desc);
    } else {
      setState(() {
        conversationList = res.data!.conversationList;
      });
      return res.data!.conversationList;
    }
  }

  AlertDialog dialogShow(context) {
    AlertDialog dialog = AlertDialog(
      title: Text('会话选择（${widget.switchSelectType ? '单选' : '多选'}）'),
      contentPadding: EdgeInsets.zero,
      content:
          ConversationList(widget.switchSelectType, conversationList, (data) {
        setState(() {
          selected = data;
        });
      }, selected),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onSelect(selected);
            Navigator.pop(context);
          },
          child: Text('确认'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
      ],
    );
    return dialog;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        List<V2TimConversation?>? fl = await this.getConversationList();
        if (fl != null) {
          if (fl.length > 0) {
            showDialog<void>(
              context: context,
              builder: (context) => dialogShow(context),
            );
          } else {
            Utils.toast("暂无会话信息");
          }
        }
      },
      child: Text("选择会话"),
    );
  }
}
