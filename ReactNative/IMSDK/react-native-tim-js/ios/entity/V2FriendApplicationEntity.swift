import Foundation
import  ImSDK_Plus

/// 好友申请实体
class V2FriendApplicationEntity: V2TIMFriendApplication {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMFriendApplication) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = info.userID;
        result["nickname"] = info.nickName;
        result["faceUrl"] = info.faceUrl;
        result["addTime"] = info.addTime;
        result["addSource"] = info.addSource;
        result["addWording"] = info.addWording;
        result["type"] = info.type.rawValue;
        return result;
    }
}