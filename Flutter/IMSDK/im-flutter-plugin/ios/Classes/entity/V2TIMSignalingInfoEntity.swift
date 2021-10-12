import  ImSDK_Plus


//  心灵消息返回
class V2TIMSignalingInfoEntiry {
    
    public static func getDict(info: V2TIMSignalingInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        var myInviteeList = [String]();
        result["inviteID"] = info.inviteID;
        result["groupID"] = info.groupID ?? "";
        result["inviter"] = info.inviter;
        result["data"] = info.data;
        if( info.timeout != nil){
            result["timeout"] = info.timeout ;
        }
        
        result["actionType"] = info.actionType.rawValue;
        
        
        for item in info.inviteeList {
            myInviteeList.append(item as! String);
        }
        result["inviteeList"] = myInviteeList;
        
        return result;
    }
}
/*
	/*
	 * SignalingActionType_Invite           = 1,  // 邀请方发起邀请
	 * SignalingActionType_Cancel_Invite    = 2,  // 邀请方取消邀请
	 * SignalingActionType_Accept_Invite    = 3,  // 被邀请方接受邀请
	 * SignalingActionType_Reject_Invite    = 4,  // 被邀请方拒绝邀请
	 * SignalingActionType_Invite_Timeout   = 5,  // 邀请超时
	*/

*/
