import 'package:flutter/cupertino.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_group_profile_model.dart';

class SharedDataWidget extends InheritedWidget {
  final TUIGroupProfileModel model;

  const SharedDataWidget({Key? key, required Widget child, required this.model})
      : super(key: key, child: child);

  // Define a method to get the shared data from sub-tree
  static SharedDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SharedDataWidget>();
  }

  @override
  bool updateShouldNotify(covariant SharedDataWidget oldWidget) {
    return oldWidget.model != model;
  }
}
