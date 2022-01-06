//
//  ConversationManager.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
import ImSDK_Plus

class SignalingManager {
	var channel: FlutterMethodChannel
	
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}

	public func invite(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let v2TIMOfflinePushInfo = CommonUtils.getV2TIMOfflinePushInfo(call: call, result: result)

		if var invitee = CommonUtils.getParam(call: call, result: result, param: "invitee") as? String,
			let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String,
			let timeout = CommonUtils.getParam(call: call, result: result, param: "timeout") as? Int32,
			let onlineUserOnly = CommonUtils.getParam(call: call, result: result, param: "onlineUserOnly") as? Bool {
			var inviteID = ""
			//	invitee为""crash，" "可以走到fail
			invitee = (invitee == "") ? " " : invitee
			inviteID = V2TIMManager.sharedInstance().invite(invitee, data: data, onlineUserOnly: onlineUserOnly, offlinePushInfo: v2TIMOfflinePushInfo, timeout: timeout, succ: {
				() -> Void in
				CommonUtils.resultSuccess(call: call, result: result, data: inviteID)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	public func inviteInGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
			let inviteeList = CommonUtils.getParam(call: call, result: result, param: "inviteeList") as? Array<String>,
			let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String,
			let timeout = CommonUtils.getParam(call: call, result: result, param: "timeout") as? Int32,
			let onlineUserOnly = CommonUtils.getParam(call: call, result: result, param: "onlineUserOnly") as? Bool {
			var inviteID = ""
			//	inviteeList为空数组crash，非空可以走到fail
			if inviteeList.count == 0 {
				return CommonUtils.resultFailed(desc: "InviteeList can not be empty", code: -1, call: call, result: result)
			}
			inviteID = V2TIMManager.sharedInstance().invite(inGroup: groupID, inviteeList: inviteeList, data: data, onlineUserOnly: onlineUserOnly, timeout: timeout, succ: {
				() -> Void in
				CommonUtils.resultSuccess(call: call, result: result, data: inviteID)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	public func cancel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let inviteID = CommonUtils.getParam(call: call, result: result, param: "inviteID") as? String,
			let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String {

			V2TIMManager.sharedInstance().cancel(inviteID, data: data, succ: {
				() -> Void in
				CommonUtils.resultSuccess(call: call, result: result, data: "ok");
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	public func accept(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let inviteID = CommonUtils.getParam(call: call, result: result, param: "inviteID") as? String,
			let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String {
				
			V2TIMManager.sharedInstance().accept(inviteID, data: data, succ: {
				() -> Void in
				CommonUtils.resultSuccess(call: call, result: result, data: "ok");
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	public func reject(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let inviteID = CommonUtils.getParam(call: call, result: result, param: "inviteID") as? String,
			let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String {
				
			V2TIMManager.sharedInstance().reject(inviteID, data: data, succ: {
				() -> Void in
				CommonUtils.resultSuccess(call: call, result: result, data: "ok");
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

    // TODO 底层ios的名字是getSignallingInfo, 因此我调用的时候是两个ll
	public func getSignalingInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let messageID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
            V2TIMManager.sharedInstance().findMessages([messageID], succ: {
                msgs in
                if(msgs!.isEmpty) {
                    CommonUtils.resultSuccess(call: call, result: result, data: "messages no found");
                }else{
                    let signalInfo = V2TIMManager.sharedInstance().getSignallingInfo(msgs![0]);
                    
                    var resultMap = [String:Any]();

                    if(signalInfo != nil){
                        resultMap = V2TIMSignalingInfoEntiry.getDict(info: signalInfo!);

                        CommonUtils.resultSuccess(call: call, result: result, data: resultMap)
                    }else {CommonUtils.resultSuccess(call: call, result: result, data: signalInfo)}
                    
                }
            }, fail:  TencentImUtils.returnErrorClosures(call: call, result: result))
        };
	}
	
	public func addInvitedSignaling(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let info = CommonUtils.getParam(call: call, result: result, param: "info") as! [String: Any];
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
            SignalingActionType(rawValue:info["actionType"] as! Int);
        }
        // 注意：ios不需要businessID
        V2TIMManager.sharedInstance().addInvitedSignaling(param, succ: {
            CommonUtils.resultSuccess(call: call, result: result, data: "ok");
        }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}


}
