import Foundation
import  ImSDK_Plus

/// 群申请结果实体
class V2GroupApplicationResultEntity: V2TIMGroupApplicationResult {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMGroupApplicationResult) -> [String: Any] {
        var result: [String: Any] = [:];
        result["unreadCount"] = info.unreadCount;
        var groupApplicationList: [[String: Any]] = [];
        for item in info.applicationList! {
            groupApplicationList.append(V2GroupApplicationEntity.getDict(info: item as! V2TIMGroupApplication))
        }
        result["groupApplicationList"] = groupApplicationList;
        return result;
    }
}