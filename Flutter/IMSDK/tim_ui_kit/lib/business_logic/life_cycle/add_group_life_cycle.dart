import 'package:flutter/cupertino.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class AddGroupLifeCycle {
  /// Before requesting to add or join to a group,
  /// `true` means can add continually, while `false` will not add.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String groupID, String message, [BuildContext? context]) shouldAddGroup;

  AddGroupLifeCycle({
    this.shouldAddGroup = DefaultLifeCycle.defaultAddGroup,
  });
}
