import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TIMUIKitState<T extends StatefulWidget> extends TIMState<T> {
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();

  @override
  initState() {
    super.initState();
  }

  @override
  void onTIMCallback(TIMCallback callbackValue) {
    super.onTIMCallback(callbackValue);
    _coreServices.callOnCallback(callbackValue);
  }

  @override
  Widget timBuild(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
      ],
      builder: (BuildContext context, Widget? w) {
        final theme = Provider.of<TUIThemeViewModel>(context).theme;
        final value = TUIKitBuildValue(theme: theme);
        return tuiBuild(context, value);
      },
    );
  }

  @required
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return Container();
  }
}
