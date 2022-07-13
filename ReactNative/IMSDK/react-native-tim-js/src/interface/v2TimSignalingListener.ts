/**
 * @module interface
 */
interface V2TimSignalingListener {
    onReceiveNewInvitation?: (
        inviteID: String,
        inviter: String,
        groupID: String,
        inviteeList: String[],
        data: String
    ) => void;
    onInviteeAccepted?: (
        inviteID: String,
        invitee: String,
        data: String
    ) => void;
    onInviteeRejected?: (
        inviteID: String,
        invitee: String,
        data: String
    ) => void;
    onInvitationCancelled?: (
        inviteID: String,
        inviter: String,
        data: String
    ) => void;
    onInvitationTimeout?: (inviteID: String, inviteeList: String[]) => void;
}

export default V2TimSignalingListener;
