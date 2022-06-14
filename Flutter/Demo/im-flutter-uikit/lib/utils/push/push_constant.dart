// ignore_for_file: constant_identifier_names

import 'package:tim_ui_kit_push_plugin/model/appInfo.dart';

class PushConfig{

  // Business ID for HUAWEI
  static const HWPushBuzID = 0;

  // Business ID for XiaoMi
  static const XMPushBuzID = 0;

  // APP Info of XiaoMi
  static const String XMPushAPPID = "";
  static const String XMPushAPPKEY = "";

  // Business ID for Meizu
  static const MZPushBuzID = 0;

  // APP Info of Meizu
  static const String MZPushAPPID = "";
  static const String MZPushAPPKEY = "";

  // Business ID for Vivo
  static const VIVOPushBuzID = 0;

  // Business ID for Google FCM
  static const GOOGLEFCMPushBuzID = 0;

  // Business ID for OPPO
  static const OPPOPushBuzID = 0;

  // APP Info of OPPO
  static const String OPPOPushAPPKEY = "";
  static const String OPPOPushAPPSECRET = "";
  static const String OPPOPushAPPID = "";
  static const String OPPOChannelID = "new_message";
  
  // Business ID for Apple APNS
  static const ApplePushBuzID = 0;

  static final PushAppInfo appInfo = PushAppInfo(
      hw_buz_id: PushConfig.HWPushBuzID,
      mi_app_id: PushConfig.XMPushAPPID,
      mi_app_key: PushConfig.XMPushAPPKEY,
      mi_buz_id: PushConfig.XMPushBuzID,
      mz_app_id: PushConfig.MZPushAPPID,
      mz_app_key: PushConfig.MZPushAPPKEY,
      mz_buz_id: PushConfig.MZPushBuzID,
      vivo_buz_id: PushConfig.VIVOPushBuzID,
      oppo_app_key: PushConfig.OPPOPushAPPKEY,
      oppo_app_secret: PushConfig.OPPOPushAPPSECRET,
      oppo_buz_id: PushConfig.OPPOPushBuzID,
      oppo_app_id: PushConfig.OPPOPushAPPID,
      google_buz_id: PushConfig.GOOGLEFCMPushBuzID,
      apple_buz_id: PushConfig.ApplePushBuzID
  );
}
