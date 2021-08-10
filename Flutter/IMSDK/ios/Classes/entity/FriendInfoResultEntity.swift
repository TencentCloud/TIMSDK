import  ImSDK_Plus;


//  朋友实体
public class FriendInfoResultEntity : NSObject{
    
    /**
     * ID
     */
    var resultCode : Int32?;
    var resultInfo : String?;
    var relation : Int?;
    var friendInfo : [String: Any]?;
    
    
    override init() {
    }
    
    init(friendInfoResult : V2TIMFriendInfoResult) {
        super.init();
        self.resultCode = friendInfoResult.resultCode;
        self.resultInfo = friendInfoResult.resultInfo;
        self.relation = friendInfoResult.relation.rawValue;
        self.friendInfo = V2FriendInfoEntity.getDict(info: friendInfoResult.friendInfo); 
    }
}
