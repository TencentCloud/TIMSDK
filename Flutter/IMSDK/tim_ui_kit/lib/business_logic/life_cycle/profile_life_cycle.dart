import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class ProfileLifeCycle {
  /// Before adding a contact to block list,
  /// `true` means can add continually, while `false` will not add.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String userID) shouldAddToBlockList;

  /// Before deleting a contact or friend,
  /// `true` means can delete continually, while `false` will not delete.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String userID) shouldDeleteFriend;

  /// Before requesting to add a user as friend or a contact,
  /// `true` means can add continually, while `false` will not add.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String userID) shouldAddFriend;

  /// After getting the user info of friend or contact,
  /// and before rendering it to the profile page.
  FriendInfoFunction didGetFriendInfo;

  ProfileLifeCycle({
    this.didGetFriendInfo = DefaultLifeCycle.defaultFriendInfoSolution,
    this.shouldAddToBlockList = DefaultLifeCycle.defaultBooleanSolution,
    this.shouldAddFriend = DefaultLifeCycle.defaultBooleanSolution,
    this.shouldDeleteFriend = DefaultLifeCycle.defaultBooleanSolution,
  });
}
