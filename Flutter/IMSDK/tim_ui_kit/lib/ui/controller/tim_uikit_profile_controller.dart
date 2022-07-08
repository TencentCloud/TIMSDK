import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_profile_view_model.dart';
import 'package:tim_ui_kit/ui/widgets/text_input_bottom_sheet.dart';

class TIMUIKitProfileController {
  final TUIProfileViewModel model = TUIProfileViewModel();

  /// Remove a user from friend or contact
  Future<V2TimFriendOperationResult?> deleteFriend(String userID) {
    return model.deleteFriend(userID);
  }

  /// pin the conversation to the top
  pinedConversation(bool isPined, String convID) {
    model.pinedConversation(isPined, convID);
  }

  /// add a user to block list
  addUserToBlackList(bool shouldAdd, String userID) {
    model.addToBlackList(shouldAdd, userID);
  }

  /// Change the friend adding request verification method,
  /// 0 represents "Accept all friend request",
  /// 1 represents "Require approval for friend requests",
  /// 2 represents "reject all friend requests".
  changeFriendVerificationMethod(int allowType) {
    model.changeFriendVerificationMethod(allowType);
  }

  /// update the remarks for other users,
  Future<V2TimCallback> updateRemarks(String userID, String remark) {
    return model.updateRemarks(userID, remark);
  }

  /// set the message from a specific user as not disturb, mute notification
  setMessageDisturb(String userID, bool isDisturb) {
    model.setMessageDisturb(userID, isDisturb);
  }

  /// Show the text input bottom sheet
  showTextInputBottomSheet(
    BuildContext context,
    String title,
    String tips,
    void Function(String) onSubmitted,
  ) {
    TextInputBottomSheet.showTextInputBottomSheet(
        context, title, tips, onSubmitted);
  }

  /// Load the profile data
  loadData(String userID) {
    model.loadData(userID: userID);
  }

  dispose() {
    model.dispose();
  }

  /// Add a user as friend or contact
  Future<V2TimFriendOperationResult?> addFriend(String userID) {
    return model.addFriend(userID);
  }
}
