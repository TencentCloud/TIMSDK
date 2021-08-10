import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';

class CustomerFieldDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CustomerFieldDialogState();
}

class CustomerFieldDialogState extends State<CustomerFieldDialog> {
  String fieldKey = '';
  String fieldValue = '';

  Future<void> handleSetFieldValue() async {
    if (fieldKey == '') {
      await showOkAlertDialog(
        context: context,
        title: "提示",
        message: "字段名不能为空",
      );
      return;
    }
    Map<String, String> result = new Map();
    result[fieldKey] = fieldValue;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('自定义字段'),
      content: Container(
        height: 150,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "字段名",
                hintText: "请在控制台查看",
              ),
              onChanged: (res) {
                setState(() {
                  fieldKey = res.trim();
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "字段值",
                hintText: "",
              ),
              onChanged: (res) {
                setState(() {
                  fieldValue = res.trim();
                });
              },
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text("取消")),
        TextButton(onPressed: handleSetFieldValue, child: Text("确定"))
      ],
    );
  }
}
