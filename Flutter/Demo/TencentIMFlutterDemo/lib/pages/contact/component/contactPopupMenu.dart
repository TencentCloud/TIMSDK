import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/search/search.dart';

class ContactMenuItem extends StatelessWidget {
  ContactMenuItem(this.name);
  final String name;
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

class ContactPopUpMenu extends StatelessWidget {
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
            child: ContactMenuItem("添加好友"),
            value: "friend",
          ),
          PopupMenuItem<String>(
            height: 30,
            textStyle: TextStyle(
              height: 1,
              color: CommonColors.getTextBasicColor(),
            ),
            child: ContactMenuItem("添加群组"),
            value: "group",
          ),
        ];
      },
      onSelected: (String action) {
        switch (action) {
          case "friend":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => Search(1),
              ),
            );
            break;
          case "group":
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => Search(2),
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
