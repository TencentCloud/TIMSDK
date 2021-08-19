import  ImSDK_Plus;

//  朋友实体
public class V2FriendInfoResultEntity : V2TIMFriendInfoResult {
	
	public static func getDict(info: V2TIMFriendInfoResult) -> [String: Any] {
		var result: [String: Any] = [:];
		result["resultCode"] = info.resultCode;
		result["resultInfo"] = info.resultInfo;
		result["relation"] = info.relation.rawValue;
		result["friendInfo"] = V2FriendInfoEntity.getDict(info: info.friendInfo);
		return result;
	}
} 
