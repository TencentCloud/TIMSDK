import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin_example/common/arrowRight.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/pages/friendNotice/friendNotice.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friendApplication.dart';

class FrientNotice extends StatelessWidget {
  Widget build(BuildContext context) {
    List<V2TimFriendApplication>? applicationList =
        Provider.of<FriendApplicationModel>(context).friendApplicationList;
    print("重新渲染好友申请");
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => NewFriendOrGroupNotice(1),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 55,
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: Text(
                  "我的好友通知",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(int.parse('111111', radix: 16)).withAlpha(255),
                  ),
                ),
              ),
            ),
            Container(
              // color: Colors.green,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      width: 180,
                      height: 55,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: (applicationList == null ||
                                applicationList.length == 0)
                            ? []
                            : applicationList.map(
                                (e) {
                                  if (e.type == 1) {
                                    return Container(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Avatar(
                                        width: 24,
                                        height: 24,
                                        radius: 2,
                                        avtarUrl:
                                            e.faceUrl == '' || e.faceUrl == null
                                                ? 'images/logo.png'
                                                : e.faceUrl,
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ).toList(),
                      ),
                    ),
                  ),
                  Container(
                    height: 55,
                    width: 20,
                    child: ArrowRight(),
                  )
                ],
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
            width: 1,
            style: BorderStyle.solid,
          )),
        ),
        color: Colors.amber[777],
      ),
    );
  }
}
