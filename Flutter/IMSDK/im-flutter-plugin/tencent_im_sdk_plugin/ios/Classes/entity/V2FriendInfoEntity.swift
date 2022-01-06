import  ImSDK_Plus;


//  朋友实体
public class V2FriendInfoEntity : V2TIMFriendInfo{

    convenience init(json: String) {
        self.init(dict: JsonUtil.getDictionaryFromJSONString(jsonString: json))
    }
    
    
    init(dict: [String: Any]) {
		super.init();
        self.userID = (dict["userID"] as? String);
        self.friendRemark = (dict["friendRemark"] as? String);
		
		if let dictCustomInfo = dict["friendCustomInfo"] as? Dictionary<String, String> {
			var customInfoData: Dictionary<String, Data> = [:]
			for (key, value) in dictCustomInfo {
				customInfoData[key] = value.data(using: String.Encoding.utf8, allowLossyConversion: true);
			}
			self.friendCustomInfo = customInfoData
		}
    }
    
    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMFriendInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = info.userID;
        result["friendRemark"] = info.friendRemark;
        result["friendGroups"] = info.friendGroups;
        result["userProfile"] = V2UserFullInfoEntity.getDict(info: info.userFullInfo);
		
		if let customInfo = info.friendCustomInfo as? Dictionary<String, Data> {
			var retCustomInfo: Dictionary<String, String> = [:]
			for i in customInfo {
				retCustomInfo[i.key] = String(data: i.value, encoding: String.Encoding.utf8)
			}
			result["friendCustomInfo"] = retCustomInfo;
		}
		
        return result;
    }
}
