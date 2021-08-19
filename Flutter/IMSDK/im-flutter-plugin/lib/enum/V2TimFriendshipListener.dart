// void 	onFriendApplicationListAdded (List< V2TIMFriendApplication > applicationList)

// void 	onFriendApplicationListDeleted (List< String > userIDList)

// void 	onFriendApplicationListRead ()

// void 	onFriendListAdded (List< V2TIMFriendInfo > users)

// void 	onFriendListDeleted (List< String > userList)

// void 	onBlackListAdd (List< V2TIMFriendInfo > infoList)

// void 	onBlackListDeleted (List< String > userList)

// void 	onFriendInfoChanged (List< V2TIMFriendInfo > infoList)
//
import 'package:tencent_im_sdk_plugin/enum/callbacks.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class V2TimFriendshipListener {
  OnFriendApplicationListAddedCallback onFriendApplicationListAdded = (
    List<V2TimFriendApplication> applicationList,
  ) {};
  OnFriendApplicationListDeletedCallback onFriendApplicationListDeleted = (
    List<String> userIDList,
  ) {};
  OnFriendApplicationListReadCallback onFriendApplicationListRead = () {};
  OnFriendListAddedCallback onFriendListAdded = (
    List<V2TimFriendInfo> users,
  ) {};
  OnFriendListDeletedCallback onFriendListDeleted = (
    List<String> userList,
  ) {};
  OnBlackListAddCallback onBlackListAdd = (
    List<V2TimFriendInfo> infoList,
  ) {};
  OnBlackListDeletedCallback onBlackListDeleted = (
    List<String> userList,
  ) {};
  OnFriendInfoChangedCallback onFriendInfoChanged = (
    List<V2TimFriendInfo> infoList,
  ) {};

  V2TimFriendshipListener({
    OnFriendApplicationListAddedCallback? onFriendApplicationListAdded,
    OnFriendApplicationListDeletedCallback? onFriendApplicationListDeleted,
    OnFriendApplicationListReadCallback? onFriendApplicationListRead,
    OnFriendListAddedCallback? onFriendListAdded,
    OnFriendListDeletedCallback? onFriendListDeleted,
    OnBlackListAddCallback? onBlackListAdd,
    OnBlackListDeletedCallback? onBlackListDeleted,
    OnFriendInfoChangedCallback? onFriendInfoChanged,
  }) {
    if (onFriendApplicationListAdded != null) {
      this.onFriendApplicationListAdded = onFriendApplicationListAdded;
    }
    if (onFriendApplicationListDeleted != null) {
      this.onFriendApplicationListDeleted = onFriendApplicationListDeleted;
    }
    if (onFriendApplicationListRead != null) {
      this.onFriendApplicationListRead = onFriendApplicationListRead;
    }
    if (onFriendListAdded != null) {
      this.onFriendListAdded = onFriendListAdded;
    }
    if (onFriendListDeleted != null) {
      this.onFriendListDeleted = onFriendListDeleted;
    }
    if (onBlackListAdd != null) {
      this.onBlackListAdd = onBlackListAdd;
    }
    if (onBlackListDeleted != null) {
      this.onBlackListDeleted = onBlackListDeleted;
    }
    if (onFriendInfoChanged != null) {
      this.onFriendInfoChanged = onFriendInfoChanged;
    }
  }
}
