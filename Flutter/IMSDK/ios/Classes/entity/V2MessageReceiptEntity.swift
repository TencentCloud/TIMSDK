import Foundation
import  ImSDK_Plus

/// 自定义消息响应实体
class V2MessageReceiptEntity: V2TIMMessageReceipt {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMMessageReceipt) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = info.userID;
        result["timestamp"] = info.timestamp;
        return result;
    }
}