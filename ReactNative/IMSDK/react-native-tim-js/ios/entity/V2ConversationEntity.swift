import Foundation
import ImSDK_Plus
import Hydra

/// 自定义会话实体
class V2ConversationEntity: V2TIMConversation {
    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMConversation) -> [String: Any] {
        var result: [String: Any] = [:];
        result["conversationID"] = info.conversationID;
        result["type"] = info.type.rawValue;
        result["userID"] = info.userID;
        result["groupID"] = info.groupID;
        result["showName"] = info.showName;
        result["faceUrl"] = info.faceUrl;
        result["recvOpt"] = info.recvOpt.rawValue;
        result["groupType"] = info.groupType;
        result["unreadCount"] = info.unreadCount;
        result["draftText"] = info.draftText;
        result["draftText"] = info.draftText;
		result["draftTimestamp"] = (info.draftTimestamp != nil) ? Int(info.draftTimestamp.timeIntervalSince1970) : nil;
        result["test"] = nil;
		result["isPinned"] = info.isPinned;
        result["orderkey"] = info.orderKey;
		if info.lastMessage != nil {
			result["lastMessage"] = V2MessageEntity(message: info.lastMessage).getDict(progress: 100)
		}
        if info.groupAtInfolist != nil {
            var groupAtInfoList: [[String: Any]] = [];
            for item in info.groupAtInfolist {
                groupAtInfoList.append(V2GroupAtInfoEntity.getDict(info: item));
            }
            result["groupAtInfoList"] = groupAtInfoList;
        }
        return result;
    }
	
	
	public static func getDictAll(info: V2TIMConversation) -> Promise<Dictionary<String, Any>> {
		return async({
			_ -> Dictionary<String, Any> in
			
			var dict = self.getDict(info: info)
            if(dict["lastMessage"] != nil){
                dict["lastMessage"] = try Hydra.await(V2MessageEntity(message: info.lastMessage).getDictAll())
            }
			return dict
		}).then({
			data in
			return data
		})
	}
}
