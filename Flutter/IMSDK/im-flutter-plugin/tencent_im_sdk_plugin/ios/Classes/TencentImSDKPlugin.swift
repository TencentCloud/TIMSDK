import UIKit
import Hydra
import Flutter
import ImSDK_Plus
import UserNotifications

public class TencentImSDKPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate
{
	public static var channel: FlutterMethodChannel?;
	/**
	* 监听器回调的方法名
	*/
	private static let LISTENER_FUNC_NAME = "onListener";
	
	var friendManager: FriendManager?

	var conversationManager: ConversationManager?

	var groupManager: GroupManager?

	var messageManager: MessageManager?

	var sdkManager: SDKManager?
	
	var signalingManager: SignalingManager?
	
	public static func register(with registrar: FlutterPluginRegistrar) {
		let channel = FlutterMethodChannel(name: "tencent_im_sdk_plugin", binaryMessenger: registrar.messenger())
		let instance = TencentImSDKPlugin()
		
		TencentImSDKPlugin.channel = channel;
		
		registrar.addApplicationDelegate(instance)
		registrar.addMethodCallDelegate(instance, channel: channel)
		
		instance.friendManager = FriendManager(channel: TencentImSDKPlugin.channel!)
		instance.conversationManager = ConversationManager(channel: TencentImSDKPlugin.channel!)
		instance.groupManager = GroupManager(channel: TencentImSDKPlugin.channel!)
		instance.messageManager = MessageManager(channel: TencentImSDKPlugin.channel!)
		instance.signalingManager = SignalingManager(channel: TencentImSDKPlugin.channel!)
		instance.sdkManager = SDKManager(channel: TencentImSDKPlugin.channel!)
	}
	//MARK: -Switch Handle
	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		CommonUtils.logFromSwift(channel: TencentImSDKPlugin.channel!, data: ["msg": "Swift Resqust，方法名\(call.method)，参数：", "data": call.arguments])
		
		switch call.method {
		case "initSDK":
			sdkManager!.`initSDK`(call: call, result: result)
			break
		case "setAPNS":
			sdkManager!.setAPNS(call: call, result: result)
			break
		case "getVersion":
			sdkManager!.`getVersion`(call: call, result: result)
			break
		case "getServerTime":
			sdkManager!.getServerTime(call: call, result: result)
			break
		case "getLoginUser":
			sdkManager!.getLoginUser(call: call, result: result)
			break
		case "unInitSDK":
			sdkManager!.unInitSDK(call: call, result: result)
			break
		case "login":
			sdkManager!.login(call: call, result: result)
			break
		case "logout":
			sdkManager!.logout(call: call, result: result)
			break
		case "initStorage":
			sdkManager!.initStorage(call: call, result: result)
			break
		case "getLoginStatus":
			sdkManager!.getLoginStatus(call: call, result: result)
			break	
		case "setFriendListener":
			sdkManager!.setFriendListener(call: call, result: result)
			break
		case "addAdvancedMsgListener":
			sdkManager!.addAdvancedMsgListener(call: call, result: result)
			break
		case "removeAdvancedMsgListener":
			sdkManager!.removeAdvancedMsgListener(call: call, result: result)
			break
		case "setConversationListener":
			sdkManager!.setConversationListener(call: call, result: result)
			break
		case "addSignalingListener":
			sdkManager!.addSignalingListener(call: call, result: result)
			break
		case "removeSignalingListener":
			sdkManager!.removeSignalingListener(call: call, result: result)
			break
		case "setGroupListener":
			sdkManager!.setGroupListener(call: call, result: result)
			break
		case "addSimpleMsgListener":
			sdkManager!.addSimpleMsgListener(call: call, result: result)
			break
		case "removeSimpleMsgListener":
			sdkManager!.removeSimpleMsgListener(call: call, result: result)
			break
		case "setAPNSListener":
			sdkManager!.setAPNSListener(call: call, result: result)
		case "getUsersInfo":
			sdkManager!.getUsersInfo(call: call, result: result)
			break
		case "setSelfInfo":
			sdkManager!.setSelfInfo(call: call, result: result)
			break
		// 好友管理 begin
		case "getFriendList":
			friendManager!.getFriendList(call:call, result: result)
			break
		case "getFriendsInfo":
			friendManager!.getFriendsInfo(call:call, result: result)
			break
		case "setFriendInfo":
			friendManager!.setFriendInfo(call:call, result: result)
			break
		case "addFriend":
			friendManager!.addFriend(call:call, result: result)
			break
		case "deleteFromFriendList":
			friendManager!.deleteFromFriendList(call:call, result: result)
			break
		case "checkFriend":
			friendManager!.checkFriend(call:call, result: result)
			break
		case "getFriendApplicationList":
			friendManager!.getFriendApplicationList(call:call, result: result)
			break
		case "acceptFriendApplication":
			friendManager!.acceptFriendApplication(call:call, result: result)
			break
		case "refuseFriendApplication":
			friendManager!.refuseFriendApplication(call:call, result: result)
			break
		case "deleteFriendApplication":
			friendManager!.deleteFriendApplication(call:call, result: result)
			break
		case "setFriendApplicationRead":
			friendManager!.setFriendApplicationRead(call:call, result: result)
			break
		case "createFriendGroup":
			friendManager!.createFriendGroup(call:call, result: result)
			break
		case "getFriendGroups":
			friendManager!.getFriendGroups(call:call, result: result)
			break
		case "deleteFriendGroup":
			friendManager!.deleteFriendGroup(call:call, result: result)
			break
		case "renameFriendGroup":
			friendManager!.renameFriendGroup(call:call, result: result)
			break
		case "addFriendsToFriendGroup":
			friendManager!.addFriendsToFriendGroup(call:call, result: result)
			break
		case "deleteFriendsFromFriendGroup":
			friendManager!.deleteFriendsFromFriendGroup(call:call, result: result)
			break
		case "getBlackList":
			friendManager!.getBlackList(call:call, result: result)
			break
		case "addToBlackList":
			friendManager!.addToBlackList(call:call, result: result)
			break
		case "deleteFromBlackList":
			friendManager!.deleteFromBlackList(call:call, result: result)
			break
		case "createGroup":
			groupManager!.createGroup(call: call, result: result)
			break
		// case "createGroup":
		//   groupManager!.createGroup(call: call, result: result)
		//   break
		case "joinGroup":
			groupManager!.joinGroup(call: call, result: result)
			break
		case "quitGroup":
			groupManager!.quitGroup(call: call, result: result)
			break
		case "dismissGroup":
			groupManager!.dismissGroup(call: call, result: result)
			break
		case "getJoinedGroupList":
			groupManager!.getJoinedGroupList(call: call, result: result)
			break
		case "getGroupsInfo":
			groupManager!.getGroupsInfo(call: call, result: result)
			break
		case "setGroupInfo":
			groupManager!.setGroupInfo(call: call, result: result)
			break
		case "setReceiveMessageOpt":
			groupManager!.setReceiveMessageOpt(call: call, result: result)
			break
		case "getGroupMemberList":
			groupManager!.getGroupMemberList(call: call, result: result)
			break
		case "getGroupMembersInfo":
			groupManager!.getGroupMembersInfo(call: call, result: result)
			break
		case "setGroupMemberInfo":
			groupManager!.setGroupMemberInfo(call: call, result: result)
			break
		case "muteGroupMember":
			groupManager!.muteGroupMember(call: call, result: result)
			break
		case "inviteUserToGroup":
			groupManager!.inviteUserToGroup(call: call, result: result)
			break
		case "kickGroupMember":
			groupManager!.kickGroupMember(call: call, result: result)
			break
		case "setGroupMemberRole":
			groupManager!.setGroupMemberRole(call: call, result: result)
			break
		case "transferGroupOwner":
			groupManager!.transferGroupOwner(call: call, result: result)
			break
		case "getGroupApplicationList":
			groupManager!.getGroupApplicationList(call: call, result: result)
			break
		case "acceptGroupApplication":
			groupManager!.acceptGroupApplication(call: call, result: result)
			break
		case "refuseGroupApplication":
			groupManager!.refuseGroupApplication(call: call, result: result)
			break
		case "setGroupApplicationRead":
			groupManager!.setGroupApplicationRead(call: call, result: result)
			break
		case "initGroupAttributes":
			groupManager!.initGroupAttributes(call: call, result: result)
			break
		case "setGroupAttributes":
			groupManager!.setGroupAttributes(call: call, result: result)
			break
		case "deleteGroupAttributes":
			groupManager!.deleteGroupAttributes(call: call, result: result)
			break
		case "getGroupAttributes":
			groupManager!.getGroupAttributes(call: call, result: result)
			break
		case "getGroupOnlineMemberCount":
			groupManager!.getGroupOnlineMemberCount(call: call, result: result)
			break
		case "getConversationList":
			conversationManager!.getConversationList(call: call, result: result)
			break
		case "getConversationListByConversaionIds":
			conversationManager!.getConversationListByConversaionIds(call: call, result: result)
			break
		case "getConversation":
			conversationManager!.getConversation(call: call, result: result)
			break
		case "deleteConversation":
			conversationManager!.deleteConversation(call: call, result: result)
			break
		case "setConversationDraft":
			conversationManager!.setConversationDraft(call: call, result: result)
			break
		case "pinConversation":
			conversationManager!.pinConversation(call: call, result: result)
			break
		case "getTotalUnreadMessageCount":
			conversationManager!.getTotalUnreadMessageCount(call: call, result: result)
			break
        case "sendMessage":
            messageManager!.sendMessage(call: call, result: result)
		case "createTextMessage":
			messageManager!.createTextMessage(call: call, result: result, type: 1)
			break
		case "createCustomMessage":
			messageManager!.createCustomMessage(call: call, result: result, type: 2)
			break
		case "createImageMessage":
			messageManager!.createImageMessage(call: call, result: result, type: 3)
			break
		case "createSoundMessage":
			messageManager!.createSoundMessage(call: call, result: result, type: 4)
			break
		case "createVideoMessage":
			messageManager!.createVideoMessage(call: call, result: result, type: 5)
			break
		case "createFileMessage":
			messageManager!.createVideoMessage(call: call, result: result, type: 6)
			break
		case "createTextAtMessage":
			messageManager!.createTextAtMessage(call: call, result: result, type: 1)
			break
		case "createLocationMessage":
			messageManager!.createLocationMessage(call: call, result: result, type: 7)
			break
		case "createFaceMessage":
			messageManager!.createFaceMessage(call: call, result: result, type: 8)
			break	
		case "createMergerMessage":
			messageManager!.createMergerMessage(call: call, result: result)
			break
		case "createForwardMessage":
			messageManager!.createForwardMessage(call: call, result: result)
			break
		case "sendTextMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 1)
			break
		case "sendTextAtMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 1)
			break
		case "sendCustomMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 2)
			break
		case "sendImageMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 3)
			break
		case "sendSoundMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 4)
			break
		case "sendVideoMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 5)
			break
		case "sendFileMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 6)
			break
		case "sendLocationMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 7)
			break
		case "sendFaceMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 8)
			break
		// 无creatGroupTipsMessage
		case "sendGroupTipsMessage":
			messageManager!.sendMessageOldEdition(call: call, result: result, type: 9)
			break
		case "downloadMergerMessage":
			messageManager!.downloadMergerMessage(call: call, result: result)
			break;
		case "sendMergerMessage":
			messageManager!.sendMergerMessage(call: call, result: result)
			break;
		case "sendForwardMessage":
			messageManager!.sendForwardMessage(call: call, result: result)
			break
		case "reSendMessage":
			messageManager!.reSendMessage(call: call, result: result)
			break
		case "sendC2CTextMessage":
			messageManager!.sendC2CTextMessage(call: call, result: result)
			break
		case "sendC2CCustomMessage":
			messageManager!.sendC2CCustomMessage(call: call, result: result)
			break
		case "sendGroupTextMessage":
			messageManager!.sendGroupTextMessage(call: call, result: result)
			break
		case "sendGroupCustomMessage":
			messageManager!.sendGroupCustomMessage(call: call, result: result)
			break
		case "setC2CReceiveMessageOpt":
			messageManager!.setC2CReceiveMessageOpt(call: call, result: result)
			break
		case "getC2CReceiveMessageOpt":
			messageManager!.getC2CReceiveMessageOpt(call: call, result: result)
			break
		case "setGroupReceiveMessageOpt":
			messageManager!.setGroupReceiveMessageOpt(call: call, result: result)
			break
		case "getC2CHistoryMessageList":
			messageManager!.getC2CHistoryMessageList(call: call, result: result)
			break
		case "clearC2CHistoryMessage":
			messageManager!.clearC2CHistoryMessage(call: call, result: result)
			break
		case "getGroupHistoryMessageList":
			messageManager!.getGroupHistoryMessageList(call: call, result: result)
			break
		case "getHistoryMessageList":
			messageManager!.getHistoryMessageList(call: call, result: result)
			break
		case "revokeMessage":
			messageManager!.revokeMessage(call: call, result: result)
			break
		case "markC2CMessageAsRead":
			messageManager!.markC2CMessageAsRead(call: call, result: result)
			break
		case "markGroupMessageAsRead":
			messageManager!.markGroupMessageAsRead(call: call, result: result)
			break
		case "markAllMessageAsRead":
			messageManager!.markAllMessageAsRead(call: call, result: result)
			break
		case "deleteMessageFromLocalStorage":
			messageManager!.deleteMessageFromLocalStorage(call: call, result: result)
			break
		case "deleteMessages":
			messageManager!.deleteMessages(call: call, result: result)
			break
		case "insertGroupMessageToLocalStorage":
			messageManager!.insertGroupMessageToLocalStorage(call: call, result: result)
			break
		case "insertC2CMessageToLocalStorage":
			messageManager!.insertC2CMessageToLocalStorage(call: call, result: result)
			break
		case "setCloudCustomData":
			messageManager!.setCloudCustomData(call: call, result: result)
			break
		case "setLocalCustomInt":
			messageManager!.setLocalCustomInt(call: call, result: result)
			break
		case "setLocalCustomData":
			messageManager!.setLocalCustomData(call: call, result: result)
			break
		case "setUnreadCount":
			sdkManager!.setUnreadCount(call: call, result: result)
			break
		case "callExperimentalAPI":
            sdkManager!.callExperimentalAPI(call: call, result: result)
            break
		case "invite":
			signalingManager!.invite(call: call, result: result)
			break
		case "inviteInGroup":
			signalingManager!.inviteInGroup(call: call, result: result)
			break
		case "cancel":
			signalingManager!.cancel(call: call, result: result)
			break
		case "accept":
			signalingManager!.accept(call: call, result: result)
			break
		case "reject":
			signalingManager!.reject(call: call, result: result)
			break
		case "getSignalingInfo":
			signalingManager!.getSignalingInfo(call: call, result: result)
			break
		case "addInvitedSignaling":
			signalingManager!.addInvitedSignaling(call: call, result: result)
			break
		case "clearGroupHistoryMessage":
			messageManager!.clearGroupHistoryMessage(call: call, result: result)
			break
		case "searchLocalMessages":
			messageManager!.searchLocalMessages(call: call, result: result)
			break
		case "findMessages":
			messageManager!.findMessages(call: call, result: result)
			break
		case "searchGroups":
			groupManager!.searchGroups(call: call, result: result)
			break
		case "searchGroupMembers":
			groupManager!.searchGroupMembers(call: call, result: result)
			break
		case "searchFriends":
			friendManager!.searchFriends(call: call, result: result)
			break	
		default:
			result(FlutterMethodNotImplemented);
		}
	}
	/**
	* 调用监听器
	*
	* @param type   类型
	* @param params 参数
	*/
    public static func invokeListener(type: ListenerType, method: String, data: Any?, listenerUuid: String?) {
		 CommonUtils.logFromSwift(channel: TencentImSDKPlugin.channel!, data: ["msg": "Swift向Dart发送事件，事件名\(type)，数据", "data": data])
		var resultParams: [String: Any] = [:];
		resultParams["type"] = "\(type)";
		if data != nil {
			resultParams["data"] = data;
		}
        
        resultParams["listenerUuid"] = listenerUuid;
		
		TencentImSDKPlugin.channel!.invokeMethod(method, arguments: resultParams);
	}
}

