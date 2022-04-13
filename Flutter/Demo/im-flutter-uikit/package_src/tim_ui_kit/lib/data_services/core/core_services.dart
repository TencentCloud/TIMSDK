import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

abstract class CoreServices {
  Future<bool?> init({
    required int sdkAppID,
    required LogLevelEnum loglevel,
    required V2TimSDKListener listener,
  });

  Future login({
    required String userID,
    required String userSig,
  });

  Future logout();

  Future unInit();

  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  });

  // 注意：uikit的离线推送只支持tpns
  // Note: uikit's offline push only supports tpns
  //
  Future<V2TimCallback> setOfflinePushConfig({
    required String token,
  });

  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  });

  setTheme({required TUITheme theme});

  setDarkTheme();

  setLightTheme();
}
