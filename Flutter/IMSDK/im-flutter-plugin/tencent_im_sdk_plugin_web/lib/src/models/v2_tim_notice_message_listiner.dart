import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info.dart';

class NoticeMessageListenner {
  String listennerName;
  String groupID;
  late V2TimGroupMemberInfo opUser = V2TimGroupMemberInfo(
      faceUrl: '', userID: '', nickName: '', nameCard: '', friendRemark: '');
  late bool isAgreeJoin;
  late String opReason;
  late String customData;

  NoticeMessageListenner(
      {required this.listennerName,
      required this.groupID,
      this.isAgreeJoin = false,
      required this.opUser,
      this.customData = '',
      this.opReason = ''});
}
