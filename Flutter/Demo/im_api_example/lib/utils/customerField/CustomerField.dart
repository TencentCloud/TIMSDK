import 'package:flutter/material.dart';
import 'package:im_api_example/utils/customerField/CustomerFieldDialog.dart';

typedef CallbackAction = void Function(Map<String, String>);

class CustomerField extends StatefulWidget {
  CustomerField({required this.onSetField, this.maxSetCount = 5});

  final onSetField;
  final int maxSetCount;

  @override
  State<StatefulWidget> createState() =>
      CustomerFieldState(onSetField: onSetField, maxSetCount: maxSetCount);
}

class CustomerFieldState extends State<CustomerField> {
  CustomerFieldState({required this.onSetField, required this.maxSetCount});

  final CallbackAction onSetField;
  final int maxSetCount;

  Map<String, String> customeInfo = {};

  handleDialogClose(BuildContext context) async {
    if (customeInfo.keys.length >= maxSetCount) return;
    Map<String, String> res = await showDialog(
        context: context,
        builder: (BuildContext context) => CustomerFieldDialog());
    setState(() {
      customeInfo = {
        ...customeInfo,
        ...res,
      };
      onSetField(customeInfo);
    });
  }

  void deleteField(String key) {
    setState(() {
      customeInfo.remove(key);
      onSetField(customeInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black45))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  child: Icon(
                    Icons.person,
                    color: Colors.black45,
                  ),
                  margin: EdgeInsets.only(left: 12),
                ),
                Container(
                  child: ElevatedButton(
                      child: const Text('添加字段'),
                      onPressed: customeInfo.keys.length >= maxSetCount
                          ? null
                          : () => handleDialogClose(context)),
                  margin: EdgeInsets.only(left: 12),
                ),
              ],
            ),
            Text('已设置字段：'),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: customeInfo.entries
                    .map((item) => Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.key}: ${item.value}'),
                              Container(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.black45,
                                  ),
                                  onPressed: () => deleteField(item.key),
                                ),
                                margin: EdgeInsets.only(left: 12),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(left: 12),
                        ))
                    .toList())
          ],
        ));
  }
}
