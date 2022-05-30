// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class MsgEnum {
  external static dynamic TYPES; // 这个是用作枚举的
}

class MsgType {
  static String MSG_TEXT =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_TEXT, "TIMTextElem");
  static String MSG_IMAGE =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_IMAGE, "TIMImageElem");
  static String MSG_SOUND =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_SOUND, "TIMSoundElem");
  static String MSG_AUDIO =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_AUDIO, "TIMSoundElem");
  static String MSG_VIDEO =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_VIDEO, "TIMVideoFileElem");
  static String MSG_FILE =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_FILE, "TIMFileElem");
  static String MSG_LOCATION =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_LOCATION, "TIMLocationElem");
  static String MSG_CUSTOM =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_CUSTOM, "TIMCustomElem");
  static String MSG_GRP_TIP =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_GRP_TIP, "TIMGroupTipElem");
  static String MSG_GRP_SYS_NOTICE = checkEmptyEnum(
      () => MsgEnum.TYPES.MSG_GRP_SYS_NOTICE, "TIMGroupSystemNoticeElem");
  static String MSG_MERGER =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_MERGER, "TIMRelayElem");
  static String MSG_FACE =
      checkEmptyEnum(() => MsgEnum.TYPES.MSG_FACE, "TIMFaceElem");

  static int convertMsgType(String type) {
    if (type == MSG_TEXT) {
      return MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    }
    if (type == MSG_IMAGE) {
      return MessageElemType.V2TIM_ELEM_TYPE_IMAGE;
    }
    if (type == MSG_AUDIO) {
      return MessageElemType.V2TIM_ELEM_TYPE_SOUND;
    }
    // if (type == MSG_AUDIO) {
    //   return MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    // }
    if (type == MSG_VIDEO) {
      return MessageElemType.V2TIM_ELEM_TYPE_VIDEO;
    }
    if (type == MSG_FILE) {
      return MessageElemType.V2TIM_ELEM_TYPE_FILE;
    }
    if (type == MSG_LOCATION) {
      return MessageElemType.V2TIM_ELEM_TYPE_LOCATION;
    }
    if (type == MSG_CUSTOM) {
      return MessageElemType.V2TIM_ELEM_TYPE_CUSTOM;
    }
    if (type == MSG_GRP_TIP) {
      return MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS;
    }
    if (type == MSG_GRP_SYS_NOTICE) {
      return MessageElemType.V2TIM_ELEM_TYPE_TEXT;
    }
    if (type == MSG_MERGER) {
      return MessageElemType.V2TIM_ELEM_TYPE_MERGER;
    }

    if (type == MSG_FACE) {
      return MessageElemType.V2TIM_ELEM_TYPE_FACE;
    }

    return MessageElemType.V2TIM_ELEM_TYPE_NONE;
  }
}
