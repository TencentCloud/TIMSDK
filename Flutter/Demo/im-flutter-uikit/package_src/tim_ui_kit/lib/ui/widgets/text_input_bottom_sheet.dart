import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../i18n/i18n_utils.dart';

class TextInputBottomSheet {
  static showTextInputBottomSheet(BuildContext context, String title,
      String tips, Function(String text) onSubmitted) {
    TextEditingController _selectionController = TextEditingController();
    final I18nUtils ttBuild = I18nUtils(context);
    showModalBottomSheet(
        isScrollControlled: true, // !important
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.only(
              top: 12,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 15)),
                TextField(
                  controller: _selectionController,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      height: 40,
                      child: Text(
                        tips,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                      ),
                      onPressed: () {
                        String text = _selectionController.text;
                        if (text == "") {
                          Fluttertoast.showToast(msg: ttBuild.imt("输入不能为空"));
                          return;
                        }
                        onSubmitted(text);
                        Navigator.pop(context);
                      },
                      child: Text(ttBuild.imt("确定"))),
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
          ));
        });
  }
}
