import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/common/arrowRight.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/TextWithCommonStyle.dart';
import 'package:tencent_im_sdk_plugin_example/pages/testapi/testapi.dart';

class TestApiList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => TestApi(),
          ),
        );
      },
      child: Container(
        height: 55,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Row(
          children: [
            TextWithCommonStyle(
              text: "接口测试",
            ),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  ArrowRight(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
