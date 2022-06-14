import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_profile_view_model.dart';
import 'package:tim_ui_kit/ui/widgets/text_input_bottom_sheet.dart';

class TIMUIKitProfileController {
  final TUIProfileViewModel model = TUIProfileViewModel();

  Future<V2TimFriendOperationResult?> deleteFriend(String userID) {
    return model.deleteFriend(userID);
  }

  /// 会话置顶
  pinedConversation(bool isPined, String convID) {
    model.pinedConversation(isPined, convID);
  }

  /// 添加好友至黑名单
  addUserToBlackList(bool shouldAdd, String userID) {
    model.addToBlackList(shouldAdd, userID);
  }

  /// 更改好友验证方式, `0`为ttBuild.imt("同意任何用户添加好友")、`1`为ttBuild.imt("需要验证")、`2`为ttBuild.imt("拒绝任何人加好友").
  changeFriendVerificationMethod(int allowType) {
    model.changeFriendVerificationMethod(allowType);
  }

  /// 更新好友备注,
  Future<V2TimCallback> updateRemarks(String userID, String remark) {
    return model.updateRemarks(userID, remark);
  }

  /// 设置消息免打扰
  setMessageDisturb(String userID, bool isDisturb) {
    model.setMessageDisturb(userID, isDisturb);
  }

  showTextInputBottomSheet(
    BuildContext context,
    String title,
    String tips,
    void Function(String) onSubmitted,
  ) {
    TextInputBottomSheet.showTextInputBottomSheet(
        context, title, tips, onSubmitted);
  }

  /// 加载数据
  loadData(String userID) {
    model.loadData(userID: userID);
  }

  dispose() {
    model.dispose();
  }

  Future<V2TimFriendOperationResult?> addFriend(String userID) {
    return model.addFriend(userID);
  }
}
