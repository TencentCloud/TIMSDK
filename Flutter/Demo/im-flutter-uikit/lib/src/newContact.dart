import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class NewContact extends StatelessWidget {
  const NewContact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            imt("新的联系人"),
            style: TextStyle(color: Colors.black),
          ),
          shadowColor: Colors.white,
          backgroundColor: hexToColor("EBF0F6"),
          iconTheme: const IconThemeData(
            color: Colors.black,
          )),
      body: const TIMUIKitNewContact(),
    );
  }
}
