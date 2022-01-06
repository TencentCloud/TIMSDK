import Foundation
import  ImSDK_Plus

/// 自定义群成员信息实体
class V2GroupMemberFullInfoEntity: V2TIMGroupMemberFullInfo {

    convenience init(json: String) {
        self.init(dict: JsonUtil.getDictionaryFromJSONString(jsonString: json))
    }

    init(dict: [String: Any]) {
        super.init();
        self.userID = (dict["userID"] as? String);
        self.customInfo = (dict["customInfo"] as? [String: Data]);
        self.nameCard = (dict["nameCard"] as? String);
    }

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMGroupMemberFullInfo) -> [String: Any] {
        var result: [String: Any] = [:];
		var customInfo: [String: Any] = [:];
        result["userID"] = info.userID;
        result["nickName"] = info.nickName;
        result["friendRemark"] = info.friendRemark;
        result["faceUrl"] = info.faceURL;
        result["role"] = info.role;
        result["muteUntil"] = info.muteUntil;
        result["joinTime"] = info.joinTime;
        result["nameCard"] = info.nameCard;
		for (k, v) in info.customInfo {
			var data: NSData
			if v is NSData {
				customInfo[k] = String(data: v, encoding: String.Encoding.utf8)
			} else {
				customInfo[k] = v
			}
		};
		result["customInfo"] = customInfo;
        return result;
    }
	

    /// 根据对象获得字典对象
    public static func getDict(simpleInfo: V2TIMGroupMemberInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = simpleInfo.userID;
        result["nickName"] = simpleInfo.nickName;
        result["friendRemark"] = simpleInfo.friendRemark;
        result["faceUrl"] = simpleInfo.faceURL;
        result["nameCard"] = simpleInfo.nameCard;
        return result;
    }
}



