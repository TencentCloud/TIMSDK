import  ImSDK_Plus


//  好友关系检测返回对象
public class FriendCheckResultEntity : NSObject{
    var userID : String?;
    var resultCode : Int?;
    var resultInfo : String?;
    var resultType : Int?;
    
    override init() {
    }
    
    init(result : V2TIMFriendCheckResult) {
        super.init();
        self.userID = result.userID;
        self.resultCode = result.resultCode;
        self.resultInfo = result.resultInfo;
        self.resultType = result.relationType.rawValue;
    }
}
