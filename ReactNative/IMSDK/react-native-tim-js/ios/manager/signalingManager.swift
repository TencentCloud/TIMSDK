import Foundation
import ImSDK_Plus

class SignalingManager {
	public func invite(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        let v2TIMOfflinePushInfo = CommonUtils.getV2TIMOfflinePushInfo(param: param)

        if var invitee = param["invitee"] as? String,
            let data = param["data"] as? String,
            let timeout = param["timeout"] as? Int32,
            let onlineUserOnly = param["onlineUserOnly"] as? Bool {
            var inviteID = ""
            //    invitee为""crash，" "可以走到fail
            invitee = (invitee == "") ? " " : invitee
            inviteID = V2TIMManager.sharedInstance().invite(invitee, data: data, onlineUserOnly: onlineUserOnly, offlinePushInfo: v2TIMOfflinePushInfo, timeout: timeout, succ: {
                () -> Void in
                CommonUtils.resultSuccess(method: "invite", resolve: resolve, data: inviteID)
            }, fail: TencentImUtils.returnErrorClosures(method: "invite", resolve: resolve))
        }
	}

	public func inviteInGroup(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        if let groupID = param["groupID"] as? String,
            let inviteeList = param["inviteeList"] as? Array<String>,
            let data = param["data"] as? String,
            let timeout = param["timeout"] as? Int32,
            let onlineUserOnly = param["onlineUserOnly"] as? Bool {
            var inviteID = ""
            //    inviteeList为空数组crash，非空可以走到fail
            if inviteeList.count == 0 {
                return CommonUtils.resultFailed(desc: "InviteeList can not be empty", code: -1, method: "inviteInGroup", resolve: resolve)
            }
            inviteID = V2TIMManager.sharedInstance().invite(inGroup: groupID, inviteeList: inviteeList, data: data, onlineUserOnly: onlineUserOnly, timeout: timeout, succ: {
                () -> Void in
                CommonUtils.resultSuccess(method: "inviteInGroup", resolve: resolve, data: inviteID)
            }, fail: TencentImUtils.returnErrorClosures(method: "inviteInGroup", resolve: resolve))
        }
	}

	public func cancel(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        if let inviteID = param["inviteID"] as? String,
            let data = param["data"] as? String {

            V2TIMManager.sharedInstance().cancel(inviteID, data: data, succ: {
                () -> Void in
                CommonUtils.resultSuccess(method: "cancel", resolve: resolve, data: "ok");
            }, fail: TencentImUtils.returnErrorClosures(method: "cancel", resolve: resolve))
        }
	}

	public func accept(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        if let inviteID = param["inviteID"] as? String,
            let data = param["data"] as? String {
                
            V2TIMManager.sharedInstance().accept(inviteID, data: data, succ: {
                () -> Void in
                CommonUtils.resultSuccess(method: "accept", resolve: resolve, data: "ok");
            }, fail: TencentImUtils.returnErrorClosures(method: "accept", resolve: resolve))
        }
	}

	public func reject(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        if let inviteID = param["inviteID"] as? String,
            let data = param["data"] as? String {
                
            V2TIMManager.sharedInstance().reject(inviteID, data: data, succ: {
                () -> Void in
                CommonUtils.resultSuccess(method: "reject", resolve: resolve, data: "ok");
            }, fail: TencentImUtils.returnErrorClosures(method: "reject", resolve: resolve))
        }
	}

    // TODO 底层ios的名字是getSignallingInfo, 因此我调用的时候是两个ll
	public func getSignalingInfo(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        if let messageID = param["msgID"] as? String {
            V2TIMManager.sharedInstance().findMessages([messageID], succ: {
                msgs in
                if(msgs!.isEmpty) {
                    CommonUtils.resultSuccess(method: "getSignalingInfo", resolve: resolve, data: "messages no found");
                }else{
                    let signalInfo = V2TIMManager.sharedInstance().getSignallingInfo(msgs![0]);
                    
                    var resultMap = [String:Any]();

                    if(signalInfo != nil){
                        resultMap = V2TIMSignalingInfoEntiry.getDict(info: signalInfo!);

                        CommonUtils.resultSuccess(method: "getSignalingInfo", resolve: resolve, data: resultMap)
                    }else {
                        CommonUtils.resultSuccess(method: "getSignalingInfo", resolve: resolve, data: signalInfo as Any)
                        
                    }
                    
                }
            }, fail:  TencentImUtils.returnErrorClosures(method: "getSignalingInfo", resolve: resolve))
        };
	}
	
	public func addInvitedSignaling(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        let info = param["info"] as! [String: Any];
        let param = V2TIMSignalingInfo();
        if(info["inviteID"] != nil) {  // 邀请 ID
            param.inviteID = info["inviteID"] as? String;
        }
        if(info["groupID"] != nil) {     // 发起邀请所在群组
            param.groupID = info["groupID"] as? String;
        }
        if(info["inviteeList"] != nil) {    // 被邀请人列表
         
            param.inviteeList = info["inviteeList"] as? NSMutableArray;
        }
        if(info["data"] != nil) { // 
            param.data = info["data"] as? String;
        }
        if(info["timeout"] != nil) {
            param.timeout = info["timeout"] as! UInt32;
        }
        if(info["actionType"] != nil) {
            param.actionType = SignalingActionType(rawValue:info["actionType"] as! Int)!;
        }
        // 注意：ios不需要businessID
        V2TIMManager.sharedInstance().addInvitedSignaling(param, succ: {
            CommonUtils.resultSuccess(method: "addInvitedSignaling", resolve: resolve, data: "ok");
        }, fail: TencentImUtils.returnErrorClosures(method: "addInvitedSignaling", resolve: resolve))
	}


}
