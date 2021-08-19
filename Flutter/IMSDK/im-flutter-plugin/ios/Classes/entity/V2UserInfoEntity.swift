import  ImSDK_Plus

/// 自定义用户实体
class V2UserInfoEntity: V2TIMUserFullInfo {
    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMUserInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = info.userID;
        result["nickName"] = info.nickName;
        result["faceUrl"] = info.faceURL;
        return result;
    }
}


