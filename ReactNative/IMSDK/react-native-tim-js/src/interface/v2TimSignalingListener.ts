/**
 * @module interface
 */
export interface V2TimSignalingListener {
    onReceiveNewInvitation?: (
        inviteID: string,
        inviter: string,
        groupID: string,
        inviteeList: string[],
        data: string
    ) => void;
    onInviteeAccepted?: (
        inviteID: string,
        invitee: string,
        data: string
    ) => void;
    onInviteeRejected?: (
        inviteID: string,
        invitee: string,
        data: string
    ) => void;
    onInvitationCancelled?: (
        inviteID: string,
        inviter: string,
        data: string
    ) => void;
    onInvitationTimeout?: (inviteID: string, inviteeList: string[]) => void;
}
