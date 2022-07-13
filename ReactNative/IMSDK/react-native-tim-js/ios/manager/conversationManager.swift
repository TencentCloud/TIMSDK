import Foundation
import ImSDK_Plus

class ConversationManager {
	private var conversationListener: ConversationListener = ConversationListener();

	public func getConversationList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let nextSeq = param["nextSeq"] as? String,
		   let count = param["count"] as? Int32 {
            V2TIMManager.sharedInstance().getConversationList(UInt64(nextSeq) ?? 0 , count: count, succ: {
				conversations, nextSeq, finished in
				
                let dict = V2ConversationResultEntity.init(conversations: conversations ?? [], nextSeq: String(nextSeq), finished: finished).getDict();
				CommonUtils.resultSuccess(method: "getConversationList", resolve: resolve, data: dict);
			}, fail: TencentImUtils.returnErrorClosures(method: "getConversationList", resolve: resolve))
		}
	}
	
	public func getConversationListByConversaionIds(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let conversationIDList =  param["conversationIDList"] as? [String] {
		   V2TIMManager.sharedInstance().getConversationList(conversationIDList, succ: {
               if($0 != nil){
                   let dict = $0!.map { V2ConversationEntity.getDict(info: $0) };
                   CommonUtils.resultSuccess(method: "getConversationListByConversaionIds", resolve: resolve, data: dict);
               }
				
			}, fail: TencentImUtils.returnErrorClosures(method: "getConversationListByConversaionIds", resolve: resolve))
		}
	}
	
	public func getConversation(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let conversationID = param["conversationID"] as? String {
			V2TIMManager.sharedInstance().getConversation(conversationID, succ: {
				conversation in
				
				CommonUtils.resultSuccess(method: "getConversation", resolve: resolve, data: V2ConversationEntity.getDict(info: conversation!));
			}, fail: TencentImUtils.returnErrorClosures(method: "getConversation", resolve: resolve))
		}
	}
	
	public func deleteConversation(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let conversationID = param["conversationID"] as? String;
		
		V2TIMManager.sharedInstance()?.deleteConversation(conversationID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "deleteConversation", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "deleteConversation", resolve: resolve));
	}
	
	public func setConversationDraft(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let conversationID = param["conversationID"] as? String;
		let draftText = param["draftText"] as? String;
		
		V2TIMManager.sharedInstance()?.setConversationDraft(conversationID, draftText: draftText, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "setConversationDraft", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "setConversationDraft", resolve: resolve))
	}
	
	public func pinConversation(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let conversationID = param["conversationID"] as? String;
		let isPinned = param["isPinned"] as? Bool;
		
		V2TIMManager.sharedInstance()?.pinConversation(conversationID, isPinned: isPinned ?? false, succ: {
			() -> Void in
			CommonUtils.resultSuccess(method: "pinConversation", resolve: resolve, data: "ok")
		}, fail: TencentImUtils.returnErrorClosures(method: "pinConversation", resolve: resolve))
	}
	
	public func getTotalUnreadMessageCount(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.getTotalUnreadMessageCount({
			totalCount -> Void in
			CommonUtils.resultSuccess(method: "getTotalUnreadMessageCount", resolve: resolve, data: totalCount)
		}, fail: TencentImUtils.returnErrorClosures(method: "getTotalUnreadMessageCount", resolve: resolve))
	}

	public func addConversationListener(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance().addConversationListener(listener: conversationListener);
		CommonUtils.resultSuccess(method: "addConversationListener", resolve: resolve, data: "addConversationListener is done");
	}

	public func removeConversationListener(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance().removeConversationListener(listener: conversationListener);
		CommonUtils.resultSuccess(method: "removeConversationListener", resolve: resolve, data: "removeConversationListener is done");
	}
}
