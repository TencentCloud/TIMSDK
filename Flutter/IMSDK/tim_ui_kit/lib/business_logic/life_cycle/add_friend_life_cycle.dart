import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class AddFriendLifeCycle {
  /// Before requesting to add a user as friend or a contact,
  /// `true` means can add continually, while `false` will not add.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String userID, String? remark, String? friendGroup,
      String? addWording) shouldAddFriend;

  AddFriendLifeCycle({
    this.shouldAddFriend = DefaultLifeCycle.defaultAddFriend,
  });
}
