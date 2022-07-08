import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class FriendListLifeCycle {
  /// Before friend list (contacts list) will mount or update to contacts page.
  FriendListFunction friendListWillMount;

  FriendListLifeCycle({
    this.friendListWillMount = DefaultLifeCycle.defaultFriendListSolution,
  });
}
