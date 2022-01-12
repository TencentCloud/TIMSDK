import 'package:flutter/material.dart';
import 'package:discuss/common/hextocolor.dart';

class DeleteFriend extends StatelessWidget {
  const DeleteFriend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            "删除好友",
            style: TextStyle(
              fontSize: 18,
              color: hexToColor('FA5151'),
            ),
          )
        ],
      ),
    );
  }
}
