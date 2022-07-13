import Foundation
import  ImSDK_Plus

/// 自定义群@信息实体
class V2GroupAtInfoEntity: V2TIMGroupAtInfo {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMGroupAtInfo) -> [String: Any] {
        var result: [String: Any] = [:];
		result["seq"] = "\(info.seq)";
        result["atType"] = info.atType.rawValue;
        return result;
    }
}
