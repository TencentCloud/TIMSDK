import  ImSDK_Plus

/// 自定义用户实体
class V2UserFullInfoEntity: V2TIMUserFullInfo {

    convenience init(json: String) {
        self.init(dict: JsonUtil.getDictionaryFromJSONString(jsonString: json))
    }

    init(dict: [String: Any]) {
        super.init();
        self.nickName = (dict["nickName"] as? String);
        self.faceURL = (dict["faceUrl"] as? String);
        self.selfSignature = (dict["selfSignature"] as? String);
        if dict["gender"] != nil {
            self.gender = V2TIMGender.init(rawValue: (dict["gender"] as! Int))!;
        }
        if dict["allowType"] != nil {
            self.allowType = V2TIMFriendAllowType.init(rawValue: (dict["allowType"] as! Int))!;
        }
		self.role = dict["role"] as? UInt32 ?? 0;
		self.level = dict["level"] as? UInt32 ?? 0;
        self.customInfo = (dict["customInfo"] as? [String: Data]);
    }

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMUserFullInfo) -> [String: Any] {
        var result: [String: Any] = [:];
		var retCustomInfo: [String: String] = [:];
		
        result["userID"] = info.userID;
        result["nickName"] = info.nickName;
        result["faceUrl"] = info.faceURL;
        result["selfSignature"] = info.selfSignature;
        result["gender"] = info.gender.rawValue;
        result["allowType"] = info.allowType.rawValue;
        result["role"] = info.role;
        result["level"] = info.level;
		
		for i in info.customInfo {
			retCustomInfo[i.key] = String(data: i.value, encoding: String.Encoding.utf8)
		}
		result["customInfo"] = retCustomInfo;
		
        return result;
    }
}
