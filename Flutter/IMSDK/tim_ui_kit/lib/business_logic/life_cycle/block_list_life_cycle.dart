import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class BlockListLifeCycle {
  /// Before requesting to delete a user from block list,
  /// `true` means can delete continually, while `false` will not delete.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(List<String> userIDList) shouldDeleteFromBlockList;

  BlockListLifeCycle({
    this.shouldDeleteFromBlockList = DefaultLifeCycle.defaultBooleanSolution,
  });
}
