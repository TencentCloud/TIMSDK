import 'package:flutter/material.dart';
import 'package:discuss/common/arrowright.dart';
import 'package:discuss/pages/profile/component/TextWithCommonStyle.dart';
import 'package:discuss/pages/testapi/testapi.dart';

class TestApiList extends StatelessWidget {
  const TestApiList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TestApi(),
          ),
        );
      },
      child: Container(
        height: 55,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
            const TextWithCommonStyle(
              "接口测试",
            ),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: const [
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
