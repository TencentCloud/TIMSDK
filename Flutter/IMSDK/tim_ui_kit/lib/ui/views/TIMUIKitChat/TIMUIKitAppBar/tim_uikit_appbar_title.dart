import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';

class TIMUIKitAppBarTitle extends StatelessWidget {
  final Widget? title;
  final String conversationShowName;
  final bool showC2cMessageEditStaus;
  final String fromUser;
  const TIMUIKitAppBarTitle({Key? key, this.title, required this.conversationShowName, required this.showC2cMessageEditStaus, required this.fromUser}) : super(key: key);
  // String conversationShowName;
  @override
  Widget build(BuildContext context) {
    int status = Provider.of<TUIChatViewModel>(context,listen: true).getC2cMessageEditStatus(fromUser);
    if(status == 0){
      if(title!=null){
        return title!;
      }
      return Text(
            conversationShowName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          );
    }else{
      if(showC2cMessageEditStaus){
        return  const Text(
            "对方正在输入中...",
            style:  TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          );
      }else{
        if(title!=null){
        return title!;
      }
      return Text(
            conversationShowName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          );
      }
    }
  }
}