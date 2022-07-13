import Foundation
import  ImSDK_Plus

/// 自定义群成员信息实体
class TIMGroupMemberInfo: V2TIMGroupMemberInfo {

    // convenience init(json: String) {
    //     self.init(dict: JsonUtil.getDictionaryFromJSONString(jsonString: json))
    // }

    // init(dict: [String: Any]) {
    //     super.init();
    //     self.userID = (dict["userID"] as? String);
    //     self.nickName = (dict["nickName"] as? String);
    //     self.nameCard = (dict["nameCard"] as? String);
    //     self.friendRemark = (dict["friendRemark"] as? String);
    //     self.faceURL = (dict["faceURL"] as? String);
    // }

    /// 根据对象获得字典对象
    // public static func getDict(info: V2TIMGroupMemberInfo) -> [String: Any] {
    //     var result: [String: Any] = [:];
    //     result["userID"] = info.userID;
    //     result["nickName"] = info.nickName;
    //     result["friendRemark"] = info.friendRemark;
    //     result["faceURL"] = info.faceURL;
    //     result["nameCard"] = info.nameCard;
		
    //     return result;
    // }
	

    /// 根据对象获得字典对象
    public static func getDict(simpleInfo: V2TIMGroupMemberInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = simpleInfo.userID;
        result["nickName"] = simpleInfo.nickName;
        result["friendRemark"] = simpleInfo.friendRemark;
        result["faceURL"] = simpleInfo.faceURL;
        result["nameCard"] = simpleInfo.nameCard;
		
        return result;
    }
}


