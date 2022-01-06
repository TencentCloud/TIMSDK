import Foundation
import  ImSDK_Plus

/// 自定义群改变信息
class V2GroupChangeInfoEntity: V2TIMGroupChangeInfo {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMGroupChangeInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["type"] = info.type.rawValue;
        result["key"] = info.key;
        result["value"] = info.value;
        return result;
    }
}