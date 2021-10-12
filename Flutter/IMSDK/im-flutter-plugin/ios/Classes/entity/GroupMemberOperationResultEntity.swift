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

    /**
    *  兼容example，example统一使用的memberID和userId相同
    */
    var memberID : String?;
    
    override init() {
    }
    
    init(result : V2TIMGroupMemberOperationResult) {
        super.init();
        self.userID = result.userID;
        self.result = result.result.rawValue;
        self.memberID = result.userID;
    }
}
