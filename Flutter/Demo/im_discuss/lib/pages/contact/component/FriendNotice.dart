import 'package:discuss/utils/commonUtils.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:discuss/common/arrowright.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/pages/friendNotice/friendNotice.dart';
import 'package:discuss/provider/friendapplication.dart';

class FrientNotice extends StatelessWidget {
  const FrientNotice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<V2TimFriendApplication?>? applicationList =
        Provider.of<FriendApplicationModel>(context).friendApplicationList;
    Utils.log("重新渲染好友申请");
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewFriendOrGroupNotice(1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "我的好友通知",
                style: TextStyle(
                  fontSize: CommonUtils.adaptFontSize(32),
                  color: Color(int.parse('111111', radix: 16)).withAlpha(255),
                ),
              ),
            ),
            SizedBox(
              // color: Colors.green,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 180,
                      height: 55,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: (applicationList == null ||
                                applicationList.isEmpty)
                            ? []
                            : applicationList.map(
                                (e) {
                                  if (e!.type == 1) {
                                    return Container(
                                      padding: const EdgeInsets.only(left: 4),
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
                  const SizedBox(
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
