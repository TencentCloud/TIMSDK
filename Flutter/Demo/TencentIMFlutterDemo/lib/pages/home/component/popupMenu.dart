import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/contact/chooseContact.dart';

class MenuItem extends StatelessWidget {
  String name;
  MenuItem(this.name);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: CommonColors.getBorderColor(),
            style: BorderStyle.solid,
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image(
              image: AssetImage('images/person.png'),
              width: 18,
            ),
          ),
          Text(
            name,
            textAlign: TextAlign.start,
            style: TextStyle(
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }
}

class MessagePopUpMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.add),
      padding: EdgeInsets.all(0),
      offset: Offset(0, 32),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<String>>[
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: MenuItem("发起会话"),
            value: "conversation",
          ),
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: MenuItem("创建好友工作群(Work)"),
            value: "group",
          ),
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: MenuItem("创建陌生人社交群(Public)"),
            value: "chatgroup",
          ),
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: MenuItem("创建临时会议群(Meeting)"),
            value: "chatroom",
          ),
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: MenuItem("创建直播群(AVChatRoom)"),
            value: "live",
          ),
        ];
      },
      onSelected: (String action) {
        switch (action) {
          case "conversation":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => ChooseContact(1, null),
              ),
            );
            break;
          case "group":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => ChooseContact(2, null),
              ),
            );
            break;
          case "chatgroup":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => ChooseContact(3, null),
              ),
            );
            break;
          case "chatroom":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => ChooseContact(4, null),
              ),
            );
            break;
          case "live":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => ChooseContact(5, null),
              ),
            );
            break;
        }
      },
      onCanceled: () {
        print("onCanceled");
      },
    );
  }
}
