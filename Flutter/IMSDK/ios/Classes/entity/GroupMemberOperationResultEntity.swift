import  ImSDK_Plus


//  群成员结实体
public class GroupMemberOperationResultEntity :NSObject{
    
    /**
     *  用户ID
     */
    var userID : String?;
    
    /**
     *  结果
     */
    var result : Int?;
    
    override init() {
    }
    
    init(result : V2TIMGroupMemberOperationResult) {
        super.init();
        self.userID = result.userID;
        self.result = result.result.rawValue;
    }
}
