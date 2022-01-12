import 'package:flutter/material.dart';
import 'package:discuss/common/arrowright.dart';
import 'package:discuss/pages/profile/component/TextWithCommonStyle.dart';
import 'package:discuss/pages/profile/component/contactpage.dart';

class Contact extends StatelessWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContactPage(),
          ),
        );
      },
      child: Container(
        height: 50,
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
              "联系我们",
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
