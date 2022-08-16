import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_personal_profile_view_model.dart';
import 'package:tim_ui_kit/ui/widgets/text_input_bottom_sheet.dart';

class TIMUIKitPersonalProfileController {
  final TUIPersonalProfileViewModel model = TUIPersonalProfileViewModel();

  Future<V2TimCallback> changeFriendVerificationMethod(int allowType) {
    return model.changeFriendVerificationMethod(allowType);
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

  Future<V2TimCallback> updateGender(int gender) {
    return model.updateGender(gender);
  }

  Future<V2TimCallback> updateNickName(String nickName) {
    return model.updateNickName(nickName);
  }

  Future<V2TimCallback> updateSelfSignature(String selfSignature) {
    return model.updateSelfSignature(selfSignature);
  }

  loadData(String? userID) {
    model.loadData(userID: userID);
  }

  Future<V2TimCallback> updateSelfInfo(Map<String, dynamic> newSelfInfo) {
    return model.updateSelfInfo(newSelfInfo);
  }

  dispose() {
    model.dispose();
  }
}
