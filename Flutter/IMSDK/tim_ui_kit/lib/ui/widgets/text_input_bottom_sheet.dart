import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TextInputBottomSheet {
  static showTextInputBottomSheet(BuildContext context, String title,
      String tips, Function(String text) onSubmitted) {
    final CoreServicesImpl _coreService = serviceLocator<CoreServicesImpl>();
    TextEditingController _selectionController = TextEditingController();

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
                        // if (text == "") {
                        //   _coreService.callOnCallback(TIMCallback(
                        //       type: TIMCallbackType.INFO,
                        //       infoRecommendText: TIM_t("输入不能为空"),
                        //       infoCode: 6661401));
                        //   return;
                        // }
                        onSubmitted(text);
                        Navigator.pop(context);
                      },
                      child: Text(TIM_t("确定"))),
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
