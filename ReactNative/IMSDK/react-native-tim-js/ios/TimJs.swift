@objc(TimJs)
class TimJs: RCTEventEmitter {
    public static var shared:TimJs?

	var sdkManager: SDKManager = SDKManager();
    var groupManager: GroupManager = GroupManager();
    var friendManager: FriendManager = FriendManager();
    var messageManager: MessageManager = MessageManager();
    var conversationManager: ConversationManager = ConversationManager();
    var signalingManager: SignalingManager = SignalingManager();

    override init() {
        super.init()
        TimJs.shared = self
    }

    override func supportedEvents() -> [String]! {
        return ["logFromNative", "sdkListener", "simpleMsgListener", "groupListener", "friendListener", "conversationListener", "signalingListener", "messageListener"]
    }

    public func logFromNative(data: Any) {
        self.sendEvent(withName: "logFromNative", body: data);
    }

    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        resolve(a*b)
    }

    @objc(call:withMethodName:withArguments:withResolver:withRejecter:)
    func call(manager: String, methodName: String, arguments: [String:Any], resolve:@escaping RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        		CommonUtils.logFromNative(message: "Swift Resqust，方法名\(methodName)，参数：\(arguments)");
        switch methodName {
        case "initSDK":
            sdkManager.initSDK(param: arguments, resolve: resolve);
            break;
        case "login":
            sdkManager.login(param: arguments, resolve: resolve);
            break;
        case "unInitSDK":
            sdkManager.unInitSDK(resolve: resolve);
            break;
        case "getVersion":
            sdkManager.getVersion(resolve: resolve);
            break;
        case "getServerTime":
            sdkManager.getServerTime(resolve: resolve);
            break;
        case "logout":
            sdkManager.logout(resolve: resolve);
            break;
        case "getLoginUser":
            sdkManager.getLoginUser(resolve: resolve);
            break;
        case "getLoginStatus":
            sdkManager.getLoginStatus(resolve: resolve);
            break;
        case "sendC2CTextMessage":
            sdkManager.sendC2CTextMessage(param: arguments, resolve: resolve);
            break;
        case "sendC2CCustomMessage":
            sdkManager.sendC2CCustomMessage(param: arguments, resolve: resolve);
            break;
        case "sendGroupTextMessage":
            sdkManager.sendGroupTextMessage(param: arguments, resolve: resolve);
            break;
        case "sendGroupCustomMessage":
            sdkManager.sendGroupCustomMessage(param: arguments, resolve: resolve);
            break;
        case "createGroup":
            groupManager.createGroup(param: arguments, resolve: resolve);
            break;
        case "joinGroup":
            groupManager.joinGroup(param: arguments, resolve: resolve);
            break;
        case "quitGroup":
            groupManager.quitGroup(param: arguments, resolve: resolve);
            break;
        case "dismissGroup":
            groupManager.dismissGroup(param: arguments, resolve: resolve);
            break;
		case "searchGroups":
			groupManager.searchGroups(param: arguments, resolve: resolve);
			break;
		case "searchGroupMembers":
			groupManager.searchGroupMembers(param: arguments, resolve: resolve);
			break;
        case "getUsersInfo":
            sdkManager.getUsersInfo(param: arguments, resolve: resolve);
            break;
        case "setSelfInfo":
            sdkManager.setSelfInfo(param: arguments, resolve: resolve);
            break;
        case "callExperimentalAPI":
            sdkManager.callExperimentalAPI(param: arguments, resolve: resolve);
            break;
        case "addSimpleMsgListener":
            sdkManager.addSimpleMsgListener(param: arguments, resolve: resolve);
            break;
        case "removeSimpleMsgListener":
            sdkManager.removeSimpleMsgListener(param: arguments, resolve: resolve);
            break;
        case "addGroupListener":
            sdkManager.addGroupListener(param: arguments, resolve: resolve);
            break;
        case "removeGroupListener":
            sdkManager.removeGroupListener(param: arguments, resolve: resolve);
            break;
        case "setAPNSListener":
            sdkManager.setAPNSListener(param: arguments, resolve: resolve);
            break;
        case "setSelfStatus":
            sdkManager.setSelfStatus(param: arguments, resolve: resolve);
            break;
        case "getUserStatus":
            sdkManager.getUserStatus(param: arguments, resolve: resolve);
            break;
        case "addFriendListener":
            friendManager.addFriendListener(param: arguments, resolve: resolve);
            break;
        case "removeFriendListener":
            friendManager.removeFriendListener(param: arguments, resolve: resolve);
            break;
        case "getFriendList":
            friendManager.getFriendList(param: arguments, resolve: resolve);
            break;
        case "getFriendsInfo":
            friendManager.getFriendsInfo(param: arguments, resolve: resolve);
            break;
        case "setFriendInfo":
            friendManager.setFriendInfo(param: arguments, resolve: resolve);
            break;
        case "addFriend":
            friendManager.addFriend(param: arguments, resolve: resolve);
            break;
        case "deleteFromFriendList":
            friendManager.deleteFromFriendList(param: arguments, resolve: resolve);
            break;
        case "checkFriend":
            friendManager.checkFriend(param: arguments, resolve: resolve);
            break;
        case "getFriendApplicationList":
            friendManager.getFriendApplicationList(param: arguments, resolve: resolve);
            break;
        case "acceptFriendApplication":
            friendManager.acceptFriendApplication(param: arguments, resolve: resolve);
            break;
        case "refuseFriendApplication":
            friendManager.refuseFriendApplication(param: arguments, resolve: resolve);
            break;
        case "deleteFriendApplication":
            friendManager.deleteFriendApplication(param: arguments, resolve: resolve);
            break;
        case "addToBlackList":
            friendManager.addToBlackList(param: arguments, resolve: resolve);
            break;
        case "deleteFromBlackList":
            friendManager.deleteFromBlackList(param: arguments, resolve: resolve);
            break;
        case "getBlackList":
            friendManager.getBlackList(param: arguments, resolve: resolve);
            break;
        case "createFriendGroup":
            friendManager.createFriendGroup(param: arguments, resolve: resolve);
            break;
        case "getFriendGroups":
            friendManager.getFriendGroups(param: arguments, resolve: resolve);
            break;
        case "deleteFriendGroup":
            friendManager.deleteFriendGroup(param: arguments, resolve: resolve);
            break;
        case "renameFriendGroup":
            friendManager.renameFriendGroup(param: arguments, resolve: resolve);
            break;
        case "addFriendsToFriendGroup":
            friendManager.addFriendsToFriendGroup(param: arguments, resolve: resolve);
            break;
        case "deleteFriendsFromFriendGroup":
            friendManager.deleteFriendsFromFriendGroup(param: arguments, resolve: resolve);
            break;
        case "searchFriends":
            friendManager.searchFriends(param: arguments, resolve: resolve);
            break;
        case "getJoinedGroupList":
            groupManager.getJoinedGroupList(param: arguments, resolve: resolve);
            break;
        case "getGroupsInfo":
            groupManager.getGroupsInfo(param: arguments, resolve: resolve);
            break;
        case "setGroupInfo":
            groupManager.setGroupInfo(param: arguments, resolve: resolve);
            break;
        case "initGroupAttributes":
            groupManager.initGroupAttributes(param: arguments, resolve: resolve);
            break;
        case "setGroupAttributes":
            groupManager.setGroupAttributes(param: arguments, resolve: resolve);
            break;
        case "deleteGroupAttributes":
            groupManager.deleteGroupAttributes(param: arguments, resolve: resolve);
            break;
        case "getGroupAttributes":
            groupManager.getGroupAttributes(param: arguments, resolve: resolve);
            break;
        case "getGroupOnlineMemberCount":
            groupManager.getGroupOnlineMemberCount(param: arguments, resolve: resolve);
            break;
		case "getGroupMemberList":
			groupManager.getGroupMemberList(param: arguments, resolve: resolve)
			break
		case "getGroupMembersInfo":
			groupManager.getGroupMembersInfo(param: arguments, resolve: resolve)
			break
		case "setGroupMemberInfo":
			groupManager.setGroupMemberInfo(param: arguments, resolve: resolve)
			break
		case "muteGroupMember":
			groupManager.muteGroupMember(param: arguments, resolve: resolve)
			break
		case "inviteUserToGroup":
			groupManager.inviteUserToGroup(param: arguments, resolve: resolve)
			break
		case "kickGroupMember":
			groupManager.kickGroupMember(param: arguments, resolve: resolve)
			break
		case "setGroupMemberRole":
			groupManager.setGroupMemberRole(param: arguments, resolve: resolve)
			break
		case "transferGroupOwner":
			groupManager.transferGroupOwner(param: arguments, resolve: resolve)
			break
		case "getGroupApplicationList":
			groupManager.getGroupApplicationList(param: arguments, resolve: resolve)
			break
		case "acceptGroupApplication":
			groupManager.acceptGroupApplication(param: arguments, resolve: resolve)
			break
		case "refuseGroupApplication":
			groupManager.refuseGroupApplication(param: arguments, resolve: resolve)
			break
		case "setGroupApplicationRead":
			groupManager.setGroupApplicationRead(param: arguments, resolve: resolve)
			break
        case "sendMessage":
            messageManager.sendMessage(param: arguments, resolve: resolve)
		case "createTargetedGroupMessage":
			messageManager.createTargetedGroupMessage(param: arguments, resolve: resolve)
		case "createTextMessage":
			messageManager.createTextMessage(param: arguments, resolve: resolve, type: 1)
			break
		case "createCustomMessage":
			messageManager.createCustomMessage(param: arguments, resolve: resolve, type: 2)
			break
		case "createImageMessage":
			messageManager.createImageMessage(param: arguments, resolve: resolve, type: 3)
			break
		case "createSoundMessage":
			messageManager.createSoundMessage(param: arguments, resolve: resolve, type: 4)
			break
		case "createVideoMessage":
			messageManager.createVideoMessage(param: arguments, resolve: resolve, type: 5)
			break
		case "createFileMessage":
			messageManager.createVideoMessage(param: arguments, resolve: resolve, type: 6)
			break
		case "createTextAtMessage":
			messageManager.createTextAtMessage(param: arguments, resolve: resolve, type: 1)
			break
		case "createLocationMessage":
			messageManager.createLocationMessage(param: arguments, resolve: resolve, type: 7)
			break
		case "createFaceMessage":
			messageManager.createFaceMessage(param: arguments, resolve: resolve, type: 8)
			break	
		case "createMergerMessage":
			messageManager.createMergerMessage(param: arguments, resolve: resolve)
			break
		case "createForwardMessage":
			messageManager.createForwardMessage(param: arguments, resolve: resolve)
			break
		case "sendTextMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 1)
			break
		case "sendTextAtMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 1)
			break
		case "sendCustomMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 2)
			break
		case "sendImageMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 3)
			break
		case "sendSoundMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 4)
			break
		case "sendVideoMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 5)
			break
		case "sendFileMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 6)
			break
		case "sendLocationMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 7)
			break
		case "sendFaceMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 8)
			break
		// 无creatGroupTipsMessage
		case "sendGroupTipsMessage":
			messageManager.sendMessageOldEdition(param: arguments, resolve: resolve, type: 9)
			break
		case "downloadMergerMessage":
			messageManager.downloadMergerMessage(param: arguments, resolve: resolve)
			break;
		case "sendMergerMessage":
			messageManager.sendMergerMessage(param: arguments, resolve: resolve)
			break;
		case "sendForwardMessage":
			messageManager.sendForwardMessage(param: arguments, resolve: resolve)
			break
		case "reSendMessage":
			messageManager.reSendMessage(param: arguments, resolve: resolve)
			break
		case "setC2CReceiveMessageOpt":
			messageManager.setC2CReceiveMessageOpt(param: arguments, resolve: resolve)
			break
		case "getC2CReceiveMessageOpt":
			messageManager.getC2CReceiveMessageOpt(param: arguments, resolve: resolve)
			break
		case "setGroupReceiveMessageOpt":
			messageManager.setGroupReceiveMessageOpt(param: arguments, resolve: resolve)
			break
		case "getC2CHistoryMessageList":
			messageManager.getC2CHistoryMessageList(param: arguments, resolve: resolve)
			break
		case "clearC2CHistoryMessage":
			messageManager.clearC2CHistoryMessage(param: arguments, resolve: resolve)
			break
		case "getGroupHistoryMessageList":
			messageManager.getGroupHistoryMessageList(param: arguments, resolve: resolve)
			break
		case "getHistoryMessageList":
			messageManager.getHistoryMessageList(param: arguments, resolve: resolve)
			break
		case "revokeMessage":
			messageManager.revokeMessage(param: arguments, resolve: resolve)
			break
		case "markC2CMessageAsRead":
			messageManager.markC2CMessageAsRead(param: arguments, resolve: resolve)
			break
		case "markGroupMessageAsRead":
			messageManager.markGroupMessageAsRead(param: arguments, resolve: resolve)
			break
		case "markAllMessageAsRead":
			messageManager.markAllMessageAsRead(param: arguments, resolve: resolve)
			break
		case "deleteMessageFromLocalStorage":
			messageManager.deleteMessageFromLocalStorage(param: arguments, resolve: resolve)
			break
		case "deleteMessages":
			messageManager.deleteMessages(param: arguments, resolve: resolve)
			break
		case "insertGroupMessageToLocalStorage":
			messageManager.insertGroupMessageToLocalStorage(param: arguments, resolve: resolve)
			break
		case "insertC2CMessageToLocalStorage":
			messageManager.insertC2CMessageToLocalStorage(param: arguments, resolve: resolve)
			break
		case "setLocalCustomInt":
			messageManager.setLocalCustomInt(param: arguments, resolve: resolve)
			break
		case "setLocalCustomData":
			messageManager.setLocalCustomData(param: arguments, resolve: resolve)
			break
        case "clearGroupHistoryMessage":
			messageManager.clearGroupHistoryMessage(param: arguments, resolve: resolve)
			break
		case "searchLocalMessages":
			messageManager.searchLocalMessages(param: arguments, resolve: resolve)
			break
        case "modifyMessage":
            messageManager.modifyMessage(param: arguments, resolve: resolve)
            break
		case "findMessages":
			messageManager.findMessages(param: arguments, resolve: resolve)
			break
        case "appendMessage":
            messageManager.appendMessage(param: arguments, resolve: resolve)
            break
        case "addAdvancedMsgListener":
            messageManager.addAdvancedMsgListener(param: arguments, resolve: resolve)
            break
        case "removeAdvancedMsgListener":
            messageManager.removeAdvancedMsgListener(param: arguments, resolve: resolve)
            break
        case "getConversationList":
			conversationManager.getConversationList(param: arguments, resolve: resolve)
			break
		case "getConversationListByConversaionIds":
			conversationManager.getConversationListByConversaionIds(param: arguments, resolve: resolve)
			break
		case "getConversation":
			conversationManager.getConversation(param: arguments, resolve: resolve)
			break
		case "deleteConversation":
			conversationManager.deleteConversation(param: arguments, resolve: resolve)
			break
		case "setConversationDraft":
			conversationManager.setConversationDraft(param: arguments, resolve: resolve)
			break
		case "pinConversation":
			conversationManager.pinConversation(param: arguments, resolve: resolve)
			break
		case "getTotalUnreadMessageCount":
			conversationManager.getTotalUnreadMessageCount(param: arguments, resolve: resolve)
			break
		case "addConversationListener":
			conversationManager.addConversationListener(param: arguments, resolve: resolve)
			break
		case "removeConversationListener":
			conversationManager.removeConversationListener(param: arguments, resolve: resolve)
			break
        case "invite":
			signalingManager.invite(param: arguments, resolve: resolve)
			break
		case "inviteInGroup":
			signalingManager.inviteInGroup(param: arguments, resolve: resolve)
			break
		case "cancel":
			signalingManager.cancel(param: arguments, resolve: resolve)
			break
		case "accept":
			signalingManager.accept(param: arguments, resolve: resolve)
			break
		case "reject":
			signalingManager.reject(param: arguments, resolve: resolve)
			break
		case "getSignalingInfo":
			signalingManager.getSignalingInfo(param: arguments, resolve: resolve)
			break
		case "addInvitedSignaling":
			signalingManager.addInvitedSignaling(param: arguments, resolve: resolve)
			break
        default:
            resolve("Method Not Implemmention")
        }
    }
}
