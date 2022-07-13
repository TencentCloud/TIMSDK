import  ImSDK_Plus


//  未决对象实体
public class FriendOperationResultEntity : NSObject{
    var userID : String?;
    var resultCode : Int?;
    var resultInfo : String?;
    
    override init() {
    }
    
    init(result: V2TIMFriendOperationResult) {
        super.init();
        self.userID = result.userID;
        self.resultCode = result.resultCode;
        self.resultInfo = result.resultInfo;
    }
}
