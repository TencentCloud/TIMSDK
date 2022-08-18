//
//  ConversationManager.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
import ImSDK_Plus

class ConversationManager {
	var channel: FlutterMethodChannel
	
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}

	//MARK: -Conversation
	public func getConversationList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let nextSeq = CommonUtils.getParam(call: call, result: result, param: "nextSeq") as? String,
		   let count = CommonUtils.getParam(call: call, result: result, param: "count") as? Int32 {
            V2TIMManager.sharedInstance().getConversationList(UInt64(nextSeq) ?? 0 , count: count, succ: {
				conversations, nextSeq, finished in
				
                let dict = V2ConversationResultEntity.init(conversations: conversations ?? [], nextSeq: String(nextSeq), finished: finished).getDict();
				CommonUtils.resultSuccess(call: call, result: result, data: dict);
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	public func getConversationListByConversaionIds(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let conversationIDList = CommonUtils.getParam(call: call, result: result, param: "conversationIDList") as? [String] {
		   V2TIMManager.sharedInstance().getConversationList(conversationIDList, succ: {
               if($0 != nil){
                   let dict = $0!.map { V2ConversationEntity.getDict(info: $0) };
                   CommonUtils.resultSuccess(call: call, result: result, data: dict);
               }
				
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	public func getConversation(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let conversationID = CommonUtils.getParam(call: call, result: result, param: "conversationID") as? String {
			V2TIMManager.sharedInstance().getConversation(conversationID, succ: {
				conversation in
				
				CommonUtils.resultSuccess(call: call, result: result, data: V2ConversationEntity.getDict(info: conversation!));
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	public func deleteConversation(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let conversationID = CommonUtils.getParam(call: call, result: result, param: "conversationID") as? String;
		
		V2TIMManager.sharedInstance()?.deleteConversation(conversationID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	public func setConversationDraft(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let conversationID = CommonUtils.getParam(call: call, result: result, param: "conversationID") as? String;
		let draftText = CommonUtils.getParam(call: call, result: result, param: "draftText") as? String;
		
		V2TIMManager.sharedInstance()?.setConversationDraft(conversationID, draftText: draftText, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	public func pinConversation(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let conversationID = CommonUtils.getParam(call: call, result: result, param: "conversationID") as? String;
		let isPinned = CommonUtils.getParam(call: call, result: result, param: "isPinned") as? Bool;
		
		V2TIMManager.sharedInstance()?.pinConversation(conversationID, isPinned: isPinned ?? false, succ: {
			() -> Void in
			CommonUtils.resultSuccess(call: call, result: result, data: "ok")
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	public func getTotalUnreadMessageCount(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.getTotalUnreadMessageCount({
			totalCount -> Void in
			CommonUtils.resultSuccess(call: call, result: result, data: totalCount)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
    public func setConversationCustomData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let customData = CommonUtils.getParam(call: call, result: result, param: "customData") as? String;
        let conversationIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "conversationIDList") as! [String];
        V2TIMManager.sharedInstance().setConversationCustomData(conversationIDList, customData: customData?.data(using: String.Encoding.utf8)) { result_list in
            var dd : [[String:Any]] = [];
            result_list?.forEach({ item in
                dd.append([
                    "conversationID":item.conversationID ?? "",
                    "resultCode":item.resultCode ,
                    "resultInfo":item.resultInfo ?? "",
                ])
            })
            CommonUtils.resultSuccess(call: call, result: result, data: dd)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func getConversationListByFilter(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let filter = CommonUtils.getParam(call: call, result: result, param: "filter") as? [String:Any] ?? [:];
        let filter_native = V2TIMConversationListFilter.init();
      
        if(filter["groupName"] as? String != nil){
            filter_native.groupName = (filter["groupName"] as? String)
        }
        
        if(filter["conversationType"]  as? Int != nil){
            filter_native.type = V2TIMConversationType.init(rawValue: Int(filter["conversationType"] as! Int)) ?? V2TIMConversationType.C2C
        }

        if(filter["nextSeq"]  as? UInt64 != nil){
            filter_native.nextSeq = (filter["nextSeq"] as! UInt64)
        }
        if(filter["count"]  as? UInt32 != nil){
            filter_native.count = (filter["count"] as! UInt32)
        }
        if(filter["markType"]  as? UInt32 != nil){
            let u64: UInt64 = 1;
            let ab = u64 << (filter["markType"] as! UInt32)
            filter_native.markType = UInt(ab);
        }
        V2TIMManager.sharedInstance().getConversationList(by: filter_native) { conversations, nextSeq, finished in
            let dict = V2ConversationResultEntity.init(conversations: conversations ?? [], nextSeq: String(nextSeq), finished: finished).getDict();
            CommonUtils.resultSuccess(call: call, result: result, data: dict);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func markConversation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let conversationIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "conversationIDList") as! [String];
        let enableMark = (CommonUtils.getParam(call: call, result: result, param: "enableMark") as? Bool)!;
        let markType = (CommonUtils.getParam(call: call, result: result, param: "markType") as? Int32)!;
        let u64: UInt64 = 1;
        V2TIMManager.sharedInstance().markConversation(conversationIDList, markType: (u64 << markType) as NSNumber?, enableMark: enableMark) { result_list in
            var dd : [[String:Any]] = [];
            result_list?.forEach({ item in
                dd.append([
                    "conversationID":item.conversationID ?? "",
                    "resultCode":item.resultCode ,
                    "resultInfo":item.resultInfo ?? "",
                ])
            })
            CommonUtils.resultSuccess(call: call, result: result, data: dd)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }


        
    }
    public func createConversationGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let conversationIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "conversationIDList") as! [String];
        let groupName = (CommonUtils.getParam(call: call, result: result, param: "groupName") as? String)!;
        V2TIMManager.sharedInstance().createConversationGroup(groupName, conversationIDList: conversationIDList) { result_list in
            var dd : [[String:Any]] = [];
            result_list?.forEach({ item in
                dd.append([
                    "conversationID":item.conversationID ?? "",
                    "resultCode":item.resultCode ,
                    "resultInfo":item.resultInfo ?? "",
                ])
            })
            CommonUtils.resultSuccess(call: call, result: result, data: dd)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func getConversationGroupList(call: FlutterMethodCall, result: @escaping FlutterResult) {
        V2TIMManager.sharedInstance().getConversationGroupList { ids in
            CommonUtils.resultSuccess(call: call, result: result, data: ids ?? [])
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func deleteConversationGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let groupName = (CommonUtils.getParam(call: call, result: result, param: "groupName") as? String)!;
        V2TIMManager.sharedInstance().deleteConversationGroup(groupName) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func renameConversationGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let oldName = (CommonUtils.getParam(call: call, result: result, param: "oldName") as? String)!;
        let newName = (CommonUtils.getParam(call: call, result: result, param: "newName") as? String)!;
        V2TIMManager.sharedInstance().renameConversationGroup(oldName, newName: newName) {
            CommonUtils.resultSuccess(call: call, result: result)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

    }
    public func addConversationsToGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let conversationIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "conversationIDList") as! [String];
        let groupName = (CommonUtils.getParam(call: call, result: result, param: "groupName") as? String)!;
        V2TIMManager.sharedInstance().addConversations(toGroup: groupName, conversationIDList: conversationIDList) { result_list in
            var dd : [[String:Any]] = [];
            result_list?.forEach({ item in
                dd.append([
                    "conversationID":item.conversationID ?? "",
                    "resultCode":item.resultCode ,
                    "resultInfo":item.resultInfo ?? "",
                ])
            })
            CommonUtils.resultSuccess(call: call, result: result, data: dd)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }

        
    }
    public func deleteConversationsFromGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let conversationIDList:[String] = CommonUtils.getParam(call: call, result: result, param: "conversationIDList") as! [String];
        let groupName = (CommonUtils.getParam(call: call, result: result, param: "groupName") as? String)!;
        V2TIMManager.sharedInstance().deleteConversations(fromGroup: groupName, conversationIDList: conversationIDList) { result_list in
            var dd : [[String:Any]] = [];
            result_list?.forEach({ item in
                dd.append([
                    "conversationID":item.conversationID ?? "",
                    "resultCode":item.resultCode ,
                    "resultInfo":item.resultInfo ?? "",
                ])
            })
            CommonUtils.resultSuccess(call: call, result: result, data: dd)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
        }
        
    }
}
