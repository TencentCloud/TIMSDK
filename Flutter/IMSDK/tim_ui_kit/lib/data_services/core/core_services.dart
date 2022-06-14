import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

import 'package:tim_ui_kit/i18n/i18n_utils.dart';

enum AppStatus { foreground, background }

abstract class CoreServices {
  Future<bool?> init({
    required int sdkAppID,
    required LogLevelEnum loglevel,
    required V2TimSDKListener listener,

    /// only support "en" and "zh" temporally
    LanguageEnum? language,
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
    required bool isTPNSToken,
    int businessID,
    required String token,
  });

  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  });

  Future<V2TimCallback> setOfflinePushStatus({
    required AppStatus status,
    int? totalCount,
  });

  Future<void> setDataFromNative({required String userId});

  setTheme({required TUITheme theme});

  setDarkTheme();

  setLightTheme();
}
