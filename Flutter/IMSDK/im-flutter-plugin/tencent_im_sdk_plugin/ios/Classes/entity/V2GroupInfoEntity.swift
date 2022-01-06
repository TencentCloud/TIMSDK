import Foundation
import ImSDK_Plus

/// 自定义群信息实体
class V2GroupInfoEntity: V2TIMGroupInfo {

    required public override init() {
    }

//    convenience init(dict: Dictionary<String, Any>) {
//        self.init(dict: dict)
//    }

    init(dict: [String: Any]) {
        super.init();
        self.groupID = (dict["groupID"] as? String);
		
		if let groupType = dict["groupType"] as? String {
			self.groupType = groupType;
		}
		if let groupName = dict["groupName"] as? String {
			self.groupName = groupName;
		}
		if let notification = dict["notification"] as? String {
			self.notification = notification;
		}
		if let introduction = dict["introduction"] as? String {
			self.introduction = introduction;
		}
		if let faceURL = dict["faceUrl"] as? String {
			self.faceURL = faceURL;
		}
		if let allMuted = dict["isAllMuted"] as? Bool {
			self.allMuted = allMuted;
		}
		if let addOpt = dict["addOpt"] as? Int {
			self.groupAddOpt = V2TIMGroupAddOpt.init(rawValue: addOpt)!;
		}
		if let dictCustomInfo = dict["customInfo"] as? Dictionary<String, String> {
			var customInfoData: [String: Data] = [:]
			for (key, value) in dictCustomInfo {
				customInfoData[key] = value.data(using: String.Encoding.utf8, allowLossyConversion: true);
			}
			self.customInfo = customInfoData
		}
    }

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMGroupInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["groupID"] = info.groupID;
        result["groupType"] = info.groupType ?? "Public";
        result["groupName"] = info.groupName;
        result["notification"] = info.notification;
        result["introduction"] = info.introduction;
        result["faceUrl"] = info.faceURL;
        result["isAllMuted"] = info.allMuted;
        result["owner"] = info.owner;
        result["createTime"] = info.createTime;
        result["groupAddOpt"] = info.groupAddOpt.rawValue;
        result["lastInfoTime"] = info.lastInfoTime;
        result["lastMessageTime"] = info.lastMessageTime;
        result["memberCount"] = info.memberCount;
        result["onlineCount"] = info.onlineCount;
        result["role"] = info.role;
        result["recvOpt"] = info.recvOpt.rawValue;
        result["joinTime"] = info.joinTime;
		
		if info.customInfo != nil {
			var retCustomInfo: Dictionary<String, String> = [:]
			for i in info.customInfo {
				retCustomInfo[i.key] = String(data: i.value, encoding: String.Encoding.utf8)
			}
			result["customInfo"] = retCustomInfo;
		}
		
        return result;
    }
}
