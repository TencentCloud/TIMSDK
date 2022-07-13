import Foundation
import  ImSDK_Plus

/// 自定义会话结果实体
class V2ConversationResultEntity: NSObject {
    /// 下一次分页拉取的游标
    var nextSeq: String?;

    /// 是否拉取完毕
    var finished: Bool?;

    /// 会话列表
    var conversationList: [[String: Any]]?;

    required public override init() {
    }

	func getDict() -> [String: Any] {
        var result: [String: Any] = [:]

        result["nextSeq"] = nextSeq
        result["isFinished"] = self.finished
        result["conversationList"] = self.conversationList

        return result
    }

    init(conversations: [V2TIMConversation], nextSeq: String, finished: Bool) {
        super.init();
        self.nextSeq = nextSeq;
        self.finished = finished;
        conversationList = [];
        for item in conversations {
            conversationList!.append(V2ConversationEntity.getDict(info: item));
        }
    }
}
