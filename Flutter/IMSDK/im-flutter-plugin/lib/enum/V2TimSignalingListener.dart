// void 	onReceiveNewInvitation (String inviteID, String inviter, String groupID, List< String > inviteeList, String data)

// void 	onInviteeAccepted (String inviteID, String invitee, String data)

// void 	onInviteeRejected (String inviteID, String invitee, String data)

// void 	onInvitationCancelled (String inviteID, String inviter, String data)

// void 	onInvitationTimeout (String inviteID, List< String > inviteeList)
//
import 'callbacks.dart';

class V2TimSignalingListener {
  OnReceiveNewInvitationCallback onReceiveNewInvitation = (
    String inviteID,
    String inviter,
    String groupID,
    List<String> inviteeList,
    String data,
  ) {};
  OnInviteeAcceptedCallback onInviteeAccepted = (
    String inviteID,
    String invitee,
    String data,
  ) {};
  OnInviteeRejectedCallback onInviteeRejected = (
    String inviteID,
    String invitee,
    String data,
  ) {};
  OnInvitationCancelledCallback onInvitationCancelled = (
    String inviteID,
    String inviter,
    String data,
  ) {};
  OnInvitationTimeoutCallback onInvitationTimeout = (
    String inviteID,
    List<String> inviteeList,
  ) {};
  V2TimSignalingListener({
    OnReceiveNewInvitationCallback? onReceiveNewInvitation,
    OnInviteeAcceptedCallback? onInviteeAccepted,
    OnInviteeRejectedCallback? onInviteeRejected,
    OnInvitationCancelledCallback? onInvitationCancelled,
    OnInvitationTimeoutCallback? onInvitationTimeout,
  }) {
    if (onReceiveNewInvitation != null) {
      this.onReceiveNewInvitation = onReceiveNewInvitation;
    }
    if (onInviteeAccepted != null) {
      this.onInviteeAccepted = onInviteeAccepted;
    }
    if (onInviteeRejected != null) {
      this.onInviteeRejected = onInviteeRejected;
    }
    if (onInvitationCancelled != null) {
      this.onInvitationCancelled = onInvitationCancelled;
    }
    if (onInvitationTimeout != null) {
      this.onInvitationTimeout = onInvitationTimeout;
    }
  }
}
