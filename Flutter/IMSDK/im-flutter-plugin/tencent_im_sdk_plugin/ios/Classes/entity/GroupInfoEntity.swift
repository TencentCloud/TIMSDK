import  ImSDK_Plus


//  群信息实体
public class GroupInfoEntity : NSObject{
    var groupID: String?;
    var groupType: String?; // “Work”、“Public”、“Meeting” 和 “AVChatRoom” 中的任何一个
    var groupName: String?;
    var notification: String?;
    var introduction: String?;
    var faceURL: String?;
    var allMuted: Bool?;
    var owner: String?;
    var createTime: UInt32?;
    var groupAddOpt: Int?; // 0禁止加群，1需要管理员审批，2任何人可以加入
    var lastInfoTime: UInt32?;
    var lastMessageTime: UInt32?;
    var memberCount: UInt32?;
    var onlineCount: UInt32?;
    var role: UInt32?; // 0未定义，200群成员，300群管理员，400群主
    var recvOpt: Int?; // 0在线正常接收消息，离线apns推送，1不会收到消息，2在线接收，离线不推送
    var joinTime: UInt32?;
    
    override init() {
    }
    
    init(groupInfo : V2TIMGroupInfo) {
        super.init();
        self.groupID = groupInfo.groupID;
        self.groupType = groupInfo.groupType as String?;
        self.groupName = groupInfo.groupName;
        self.notification = groupInfo.notification;
        self.introduction = groupInfo.introduction;
        self.faceURL = groupInfo.faceURL;
        self.allMuted = groupInfo.allMuted;
        self.owner = groupInfo.owner;
        self.createTime = groupInfo.createTime;
        self.groupAddOpt = groupInfo.groupAddOpt.rawValue;
        self.lastInfoTime = groupInfo.lastInfoTime;
        self.lastMessageTime = groupInfo.lastMessageTime;
        self.memberCount = groupInfo.memberCount;
        self.onlineCount = groupInfo.onlineCount;
        self.role = groupInfo.role;
        self.recvOpt = groupInfo.recvOpt.rawValue;
        self.joinTime = groupInfo.joinTime;
    }
}
