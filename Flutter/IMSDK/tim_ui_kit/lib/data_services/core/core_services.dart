import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/data_services/core/tim_uikit_config.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

enum AppStatus { foreground, background }

abstract class CoreServices {
  Future<bool?> init({
    required int sdkAppID,
    required LogLevelEnum loglevel,
    required V2TimSDKListener listener,

    /// Callback from TUIKit invoke, includes IM SDK API error, notify information, Flutter error.
    ValueChanged<TIMCallback>? onTUIKitCallbackListener,
    TIMUIKitConfig? config,

    /// only support "en" and "zh" temporally
    LanguageEnum? language,
  });

  Future<void> setDataFromNative({
    required String userId,

    /// Callback from TUIKit invoke, includes IM SDK API error, notify information, Flutter error.
    ValueChanged<TIMCallback>? onTUIKitCallbackListener,
    TIMUIKitConfig? config,

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

  // 注意：uikit的离线推送不支持TPNS
  // Note: uikit's offline push do not supports TPNS
  Future<V2TimCallback> setOfflinePushConfig({
    bool isTPNSToken = false,
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

  setTheme({required TUITheme theme});

  setDarkTheme();

  setLightTheme();
}
