import Foundation
import ImSDK_Plus
import Hydra
/// 自定义群信息实体
class V2TIMTopicInfoEntity: V2TIMTopicInfo {

    required public override init() {
    }

//    convenience init(dict: Dictionary<String, Any>) {
//        self.init(dict: dict)
//    }

    init(dict: [String: Any]) {
        super.init();
        self.topicID = (dict["topicID"] as? String);
		
		if let topicName = dict["topicName"] as? String {
			self.topicName = topicName;
		}
		
		if let topicFaceURL = dict["topicFaceURL"] as? String {
			self.topicFaceURL = topicFaceURL;
		}
		if let notification = dict["notification"] as? String {
			self.notification = notification;
		}
		if let introduction = dict["introduction"] as? String {
			self.introduction = introduction;
		}
		if let isAllMuted = dict["isAllMuted"] as? Bool {
			self.isAllMuted = isAllMuted;
		}
        if let customString = dict["customString"] as? String {
            self.customString = customString;
        }
		
		if let draftText = dict["draftText"] as? String {
            self.draftText = draftText;
        }
    }

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMTopicInfo)  ->  Promise<Dictionary<String, Any>> {
        
        return async({
            _ -> Dictionary<String, Any> in
            var result: [String: Any] = [:];
            result["topicID"] = info.topicID;
            result["topicName"] = info.topicName;
            result["notification"] = info.notification;
            result["introduction"] = info.introduction;
            result["topicFaceURL"] = info.topicFaceURL;
            result["isAllMuted"] = info.isAllMuted;
            result["selfMuteTime"] = info.selfMuteTime;
            result["customString"] = info.customString;
            result["recvOpt"] = info.recvOpt.rawValue;
            result["draftText"] = info.draftText;
            result["unreadCount"] = info.unreadCount;
    //        result["lastMessage"] = try Hydra.await()
    //        V2MessageEntity.init(message:info.lastMessage).getDictAll().then { data in
    //            = data;
    //        }
            
            if(info.lastMessage.msgID != nil){
                result["lastMessage"] = try Hydra.await(V2MessageEntity.init(message:info.lastMessage).getDictAll())
            }
            if info.groupAtInfolist != nil {
                
                var groupAtInfolist: [[String: Any]]  = [];
                info.groupAtInfolist.forEach { info in
                    var item:[String:Any] = [:]
                    item["atType"] = info.atType.rawValue;
                    item["seq"] = info.seq;
                    groupAtInfolist.append(item)
                }
                
                result["groupAtInfolist"] = groupAtInfolist;
            }
            print(result)
            return result;
        }).then({ $0 })
        
        
    }
}
