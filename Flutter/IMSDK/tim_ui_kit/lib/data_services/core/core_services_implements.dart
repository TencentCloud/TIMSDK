// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_friendship_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/core/core_services.dart';
import 'package:tim_ui_kit/data_services/core/tim_uikit_config.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';

typedef EmptyAvatarBuilder = Widget Function(BuildContext context);

class LoginInfo {
  final String userID;
  final String userSig;
  final int sdkAppID;
  final V2TimUserFullInfo? loginUser;

  LoginInfo(
      {this.sdkAppID = 0, this.userSig = "", this.userID = "", this.loginUser});
}

class CoreServicesImpl with CoreServices {
  V2TimUserFullInfo? _loginInfo;
  late int _sdkAppID;
  late String _userID;
  late String _userSig;
  ValueChanged<TIMCallback>? onCallback;

  V2TimUserFullInfo? get loginUserInfo {
    return _loginInfo;
  }

  LoginInfo get loginInfo {
    return LoginInfo(
        sdkAppID: _sdkAppID,
        userID: _userID,
        userSig: _userSig,
        loginUser: _loginInfo);
  }

  EmptyAvatarBuilder? _emptyAvatarBuilder;

  EmptyAvatarBuilder? get emptyAvatarBuilder {
    return _emptyAvatarBuilder;
  }

  setEmptyAvatarBuilder(EmptyAvatarBuilder builder) {
    _emptyAvatarBuilder = builder;
  }

  setGlobalConfig(TIMUIKitConfig? config) {
    final TUISelfInfoViewModel selfInfoViewModel =
        serviceLocator<TUISelfInfoViewModel>();
    selfInfoViewModel.globalConfig = config;
  }

  @override
  Future<bool?> init({
    /// Callback from TUIKit invoke, includes IM SDK API error, notify information, Flutter error.
    ValueChanged<TIMCallback>? onTUIKitCallbackListener,
    required int sdkAppID,
    required LogLevelEnum loglevel,
    required V2TimSDKListener listener,
    LanguageEnum? language,
    TIMUIKitConfig? config,
  }) async {
    if (language != null) {
      Future.delayed(const Duration(milliseconds: 1), () {
        I18nUtils(null, language);
      });
    }
    if (onTUIKitCallbackListener != null) {
      onCallback = onTUIKitCallbackListener;
    }
    _sdkAppID = sdkAppID;
    final result = await TencentImSDKPlugin.v2TIMManager.initSDK(
        sdkAppID: sdkAppID,
        loglevel: loglevel,
        listener: V2TimSDKListener(
            onConnectFailed: listener.onConnectFailed,
            onConnectSuccess: listener.onConnectSuccess,
            onConnecting: listener.onConnecting,
            onKickedOffline: listener.onKickedOffline,
            onUserStatusChanged: (List<V2TimUserStatus> userStatusList) {
              updateUserStatusList(userStatusList);
            },
            onSelfInfoUpdated: (V2TimUserFullInfo info) {
              listener.onSelfInfoUpdated(info);
              serviceLocator<TUISelfInfoViewModel>().setLoginInfo(info);
              _loginInfo = info;
            },
            onUserSigExpired: listener.onUserSigExpired));
    setGlobalConfig(config);
    return result.data;
  }

  /// This method is used for init the TUIKit after you initialized the IM SDK from Native SDK.
  @override
  Future<void> setDataFromNative({
    /// Callback from TUIKit invoke, includes IM SDK API error, notify information, Flutter error.
    ValueChanged<TIMCallback>? onTUIKitCallbackListener,
    LanguageEnum? language,
    TIMUIKitConfig? config,
    required String userId,
  }) async {
    if (language != null) {
      Future.delayed(const Duration(milliseconds: 1), () {
        I18nUtils(null, language);
      });
    }
    if (onTUIKitCallbackListener != null) {
      onCallback = onTUIKitCallbackListener;
    }
    setGlobalConfig(config);
    getUsersInfo(userIDList: [userId]).then((res) => {
          if (res.code == 0)
            {
              _loginInfo = res.data![0],
              serviceLocator<TUISelfInfoViewModel>().setLoginInfo(_loginInfo!),
              initDataModel()
            }
          else
            {
              callOnCallback(TIMCallback(
                  type: TIMCallbackType.API_ERROR,
                  errorCode: res.code,
                  errorMsg: res.desc))
            }
        });
  }

  callOnCallback(TIMCallback callbackValue) {
    if (onCallback != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        onCallback!(callbackValue);
      });
    } else {
      print("TUIKit Callback: ${callbackValue.type}");
    }
  }

  initDataModel() {
    final TUIFriendShipViewModel tuiFriendShipViewModel =
        serviceLocator<TUIFriendShipViewModel>();
    final TUIConversationViewModel tuiConversationViewModel =
        serviceLocator<TUIConversationViewModel>();

    tuiFriendShipViewModel.initFriendShipModel();
    tuiConversationViewModel.initConversation();
  }

  updateUserStatusList(List<V2TimUserStatus> newUserStatusList) {
    try {
      final TUISelfInfoViewModel selfInfoViewModel =
          serviceLocator<TUISelfInfoViewModel>();
      if (selfInfoViewModel.globalConfig?.isShowOnlineStatus == false) {
        return;
      }

      final TUIFriendShipViewModel tuiFriendShipViewModel =
          serviceLocator<TUIFriendShipViewModel>();
      final currentUserStatusList = tuiFriendShipViewModel.userStatusList;

      for (int i = 0; i < newUserStatusList.length; i++) {
        final int indexInCurrentUserList = currentUserStatusList.indexWhere(
            (element) => element.userID == newUserStatusList[i].userID);
        if (indexInCurrentUserList == -1) {
          currentUserStatusList.add(newUserStatusList[i]);
        } else {
          currentUserStatusList[indexInCurrentUserList] = newUserStatusList[i];
        }
      }

      tuiFriendShipViewModel.userStatusList = currentUserStatusList;
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    _userID = userID;
    _userSig = userSig;
    V2TimCallback result = await TencentImSDKPlugin.v2TIMManager
        .login(userID: userID, userSig: userSig);
    if (result.code == 0) {
      initDataModel();
      getUsersInfo(userIDList: [userID]).then((res) => {
            if (res.code == 0)
              {
                _loginInfo = res.data![0],
                serviceLocator<TUISelfInfoViewModel>().setLoginInfo(_loginInfo!)
              }
          });
    } else {
      callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorCode: result.code,
          errorMsg: result.desc));
    }
    return result;
  }

  @override
  Future<V2TimCallback> logout() async {
    final result = await TencentImSDKPlugin.v2TIMManager.logout();
    return result;
  }

  @override
  Future unInit() async {
    final result = await TencentImSDKPlugin.v2TIMManager.unInitSDK();
    return result;
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) {
    return TencentImSDKPlugin.v2TIMManager.getUsersInfo(userIDList: userIDList);
  }

  @override
  Future<V2TimCallback> setOfflinePushConfig({
    // ignore: todo
    required String token,
    bool isTPNSToken = false,
    int? businessID,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getOfflinePushManager()
        .setOfflinePushConfig(
          businessID: businessID?.toDouble() ?? 0,
          token: token,
          isTPNSToken: isTPNSToken,
        );
  }

  @override
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .setSelfInfo(userFullInfo: userFullInfo);
  }

  @override
  setTheme({required TUITheme theme}) {
    // 合并传入Theme和默认Theme
    final TUIThemeViewModel _theme = serviceLocator<TUIThemeViewModel>();
    Map<String, Color?> jsonMap = Map.from(CommonColor.defaultTheme.toJson());
    Map<String, Color?> jsonInputThemeMap = Map.from(theme.toJson());

    jsonInputThemeMap.forEach((key, value) {
      if (value != null) {
        jsonMap.update(key, (v) => value);
      }
    });
    _theme.theme = TUITheme.fromJson(jsonMap);
  }

  @override
  setDarkTheme() {
    final TUIThemeViewModel _theme = serviceLocator<TUIThemeViewModel>();
    _theme.theme = TUITheme.dark; //Dark
  }

  @override
  setLightTheme() {
    final TUIThemeViewModel _theme = serviceLocator<TUIThemeViewModel>();
    _theme.theme = TUITheme.light; //Light
  }

  @override
  Future<V2TimCallback> setOfflinePushStatus(
      {required AppStatus status, int? totalCount}) {
    if (status == AppStatus.foreground) {
      return TencentImSDKPlugin.v2TIMManager
          .getOfflinePushManager()
          .doForeground();
    } else {
      return TencentImSDKPlugin.v2TIMManager
          .getOfflinePushManager()
          .doBackground(unreadCount: totalCount ?? 0);
    }
  }
}
