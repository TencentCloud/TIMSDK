import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class NewContactLifeCycle {
  /// Before accepting a friend or contact requirement from other user,
  /// `true` means can accept continually, while `false` will not accept.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String userID) shouldAcceptContactApplication;

  /// Before refusing a friend or contact requirement from other user,
  /// `true` means can refuse continually, while `false` will not refuse.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String userID) shouldRefuseContactApplication;

  NewContactLifeCycle({
    this.shouldAcceptContactApplication =
        DefaultLifeCycle.defaultBooleanSolution,
    this.shouldRefuseContactApplication =
        DefaultLifeCycle.defaultBooleanSolution,
  });
}
