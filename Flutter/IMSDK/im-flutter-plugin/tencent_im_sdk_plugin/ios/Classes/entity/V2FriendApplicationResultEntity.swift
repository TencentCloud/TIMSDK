import  ImSDK_Plus


//  未决对象实体
public class V2FriendApplicationResultEntity : NSObject{
	var unreadCount : UInt64?;
	var applicationList : [[String: Any]]?;
	
	override init() {
	}
	
	init(result : V2TIMFriendApplicationResult) {
		super.init();
		self.unreadCount = result.unreadCount;
		var applicationList: [[String: Any]] = [];
		for item in result.applicationList {
			applicationList.append(V2FriendApplicationEntity.getDict(info: item as! V2TIMFriendApplication));
		}
		self.applicationList = applicationList;
	}
}


