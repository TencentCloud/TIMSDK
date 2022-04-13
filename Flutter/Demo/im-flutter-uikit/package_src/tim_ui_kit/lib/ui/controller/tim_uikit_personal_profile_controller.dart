import 'package:flutter/cupertino.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_personal_profile_view_model.dart';
import 'package:tim_ui_kit/ui/widgets/text_input_bottom_sheet.dart';

class TIMUIKitPersonalProfileController {
  final TUIPersonalProfileViewModel model = TUIPersonalProfileViewModel();

  changeFriendVerificationMethod(int allowType) {
    model.changeFriendVerificationMethod(allowType);
  }

  showTextInputBottomSheet(
    BuildContext context,
    String title,
    String tips,
    dynamic Function(String) onSubmitted,
  ) {
    TextInputBottomSheet.showTextInputBottomSheet(
        context, title, tips, onSubmitted);
  }

  updateGender(int gender) {
    model.updateGender(gender);
  }

  updateNickName(String nickName) {
    model.updateNickName(nickName);
  }

  updateSelfSignature(String selfSignature) {
    model.updateSelfSignature(selfSignature);
  }

  loadData(String? userID) {
    model.loadData(userID: userID);
  }

  updateSelfInfo(Map<String, dynamic> newSelfInfo) {
    model.updateSelfInfo(newSelfInfo);
  }

  dispose() {
    model.dispose();
  }
}
