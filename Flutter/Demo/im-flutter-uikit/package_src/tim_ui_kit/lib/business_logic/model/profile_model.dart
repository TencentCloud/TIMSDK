import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class UserProfile {
  late V2TimFriendInfo? friendInfo;
  late V2TimConversation? conversation;

  UserProfile({required this.friendInfo, required this.conversation});
}
