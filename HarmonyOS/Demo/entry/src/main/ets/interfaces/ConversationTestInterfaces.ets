import TestResult from "../pages/ConversationManagerTestPage";
import { V2TIMConversationListener, V2TIMConversation, V2TIMManager, V2TIMConversationResult, V2TIMConversationType, V2TIMConversationListFilter, V2TIMConversationOperationResult } from "@tencentcloud/imsdk";
import Prompt from "@system.prompt";
import buffer from "@ohos.buffer";

export class ConversationTestInterfaces {
  static addConversationListener() {
    V2TIMManager.getConversationManager().addConversationListener(conversationListener);
    Prompt.showToast({ message: "addConversationListener" });
  }

  static removeConversationListener() {
    V2TIMManager.getConversationManager().removeConversationListener(conversationListener);
    Prompt.showToast({ message: "removeConversationListener" });
  }

  static getConversationListByFilter(nextSeq: number, count: number) {
    V2TIMManager.getConversationManager()
      .getConversationListByFilter(nextSeq, count)
      .then((result: V2TIMConversationResult) => {
        TestResult.result = `getConversationListByFilter succeeded \n${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getConversationListByFilter failed ${error}`;
      });
  }

  static getConversation(conversationID: string) {
    V2TIMManager.getConversationManager()
      .getConversation(conversationID)
      .then((conversation: V2TIMConversation) => {
        TestResult.result = `getConversation succeeded ${conversation}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getConversation failed ${error}`;
      });
  }

  static setConversationDraft(conversationID: string, draftText: string) {
    V2TIMManager.getConversationManager()
      .setConversationDraft(conversationID, draftText)
      .then(() => {
        TestResult.result = `setConversationDraft succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `setConversationDraft failed  ${error}`;
      });
  }

  static deleteConversation(conversationID: string) {
    V2TIMManager.getConversationManager()
      .deleteConversation(conversationID)
      .then(() => {
        TestResult.result = `deleteConversation succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteConversation failed ${error}`;
      });
  }

  static getConversationList(...conversationIDList: string[]) {
    V2TIMManager.getConversationManager()
      .getConversations(conversationIDList)
      .then((conversationList: V2TIMConversation[]) => {
        TestResult.result = `getConversationList succeeded ${conversationList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getConversationList failed ${error}`;
      });
  }

  static deleteConversationList(conversationIDList: string[], clearMessage: boolean) {
    V2TIMManager.getConversationManager()
      .deleteConversationList(conversationIDList, clearMessage)
      .then(() => {
        TestResult.result = `deleteConversationList succeeded `;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteConversationList failed ${error}`;
      });
  }

  static getConversationListByFilter2(nextSeq: number, count: number, type: V2TIMConversationType, conversationType: string, markType: number) {
    const info: V2TIMConversationListFilter = {
      type: type,
      conversationGroup: conversationType,
      markType: markType,
    };
    V2TIMManager.getConversationManager()
      .getConversationListByFilter(nextSeq, count, info)
      .then((result: V2TIMConversationResult) => {
        TestResult.result = `getConversationListByFilter_todo succeeded ${result}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getConversationListByFilter_todo failed ${error}`;
      });
  }

  static setConversationCustomData(customBuffer: string, ...conversations: string[]) {
    const customData = buffer.from(customBuffer).buffer;
    V2TIMManager.getConversationManager()
      .setConversationCustomData(conversations, customData)
      .then((resultList: V2TIMConversationOperationResult[]) => {
        TestResult.result = `setConversationCustomData succeeded ${resultList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `setConversationCustomData failed ${error}`;
      });
  }

  static pinConversation(conversationID: string, isPinned: boolean) {
    V2TIMManager.getConversationManager()
      .pinConversation(conversationID, isPinned)
      .then(() => {
        TestResult.result = `pinConversation succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `pinConversation failed ${error}`;
      });
  }

  static markConversation(conversationIDs: string[], markType: number, enableMark: boolean) {
    V2TIMManager.getConversationManager()
      .markConversation(conversationIDs, markType, enableMark)
      .then((resultList: V2TIMConversationOperationResult[]) => {
        TestResult.result = `markConversation succeeded  ${resultList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `markConversation failed ${error}`;
      });
  }

  static getTotalUnreadMessageCount() {
    V2TIMManager.getConversationManager()
      .getTotalUnreadMessageCount()
      .then((count: number) => {
        TestResult.result = `getTotalUnreadMessageCount succeeded `;
      })
      .catch((error: Error) => {
        TestResult.result = `getTotalUnreadMessageCount failed ${error}`;
      });
  }

  static getUnreadMessageCountByFilter(conversationGroup: string, markType: number, type: V2TIMConversationType) {
    const info: V2TIMConversationListFilter = {
      type: type,
      conversationGroup: conversationGroup,
      markType: markType,
    };
    V2TIMManager.getConversationManager()
      .getUnreadMessageCountByFilter(info)
      .then((count: number) => {
        TestResult.result = `getUnreadMessageCountByFilter succeeded  ${count}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getUnreadMessageCountByFilter failed ${error}`;
      });
  }

  static subscribeUnreadMessageCountByFilter(conversationGroup: string, markType: number, type: V2TIMConversationType) {
    const info: V2TIMConversationListFilter = {
      type: type,
      conversationGroup: conversationGroup,
      markType: markType,
    };
    V2TIMManager.getConversationManager().subscribeUnreadMessageCountByFilter(info);
    Prompt.showToast({ message: "subscribeUnreadMessageCountByFilter" });
  }

  static unsubscribeUnreadMessageCountByFilter(conversationGroup: string, markType: number, type: V2TIMConversationType) {
    const info: V2TIMConversationListFilter = {
      type: type,
      conversationGroup: conversationGroup,
      markType: markType,
    };
    V2TIMManager.getConversationManager().unsubscribeUnreadMessageCountByFilter(info);
    Prompt.showToast({ message: "unsubscribeUnreadMessageCountByFilter" });
  }

  static cleanConversationUnreadMessageCount(conversationID: string, cleanTimestamp: number, cleanSequence: number) {
    V2TIMManager.getConversationManager()
      .cleanConversationUnreadMessageCount(conversationID, {
        cleanTimestamp: cleanTimestamp,
        cleanSequence: cleanSequence,
      })
      .then(() => {
        TestResult.result = `cleanConversationUnreadMessageCount succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `cleanConversationUnreadMessageCount failed ${error}`;
      });
  }

  static createConversationGroup(groupName: string, conversationID1: string, conversationID2: string) {
    V2TIMManager.getConversationManager()
      .createConversationGroup(groupName, [conversationID1, conversationID2])
      .then((resultList: V2TIMConversationOperationResult[]) => {
        TestResult.result = `createConversationGroup succeeded ${resultList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `createConversationGroup failed ${error}`;
      });
  }

  static getConversationGroupList() {
    V2TIMManager.getConversationManager()
      .getConversationGroupList()
      .then((resultList: string[]) => {
        TestResult.result = `getConversationGroupList succeeded ${resultList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `getConversationGroupList failed ${error}`;
      });
  }

  static deleteConversationGroup(groupName: string) {
    V2TIMManager.getConversationManager()
      .deleteConversationGroup(groupName)
      .then(() => {
        TestResult.result = `deleteConversationGroup succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteConversationGroup failed ${error}`;
      });
  }

  static renameConversationGroup(oldName: string, newName: string) {
    V2TIMManager.getConversationManager()
      .renameConversationGroup(oldName, newName)
      .then(() => {
        TestResult.result = `renameConversationGroup succeeded`;
      })
      .catch((error: Error) => {
        TestResult.result = `renameConversationGroup failed ${error}`;
      });
  }

  static addConversationsToGroup(groupName: string, conversationID1: string, conversationID2: string) {
    V2TIMManager.getConversationManager()
      .addConversationsToGroup(groupName, [conversationID1, conversationID2])
      .then((resultList: V2TIMConversationOperationResult[]) => {
        TestResult.result = `addConversationsToGroup succeeded ${resultList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `addConversationsToGroup failed ${error}`;
      });
  }

  static deleteConversationsFromGroup(groupName: string, conversationID1: string, conversationID2: string) {
    V2TIMManager.getConversationManager()
      .deleteConversationsFromGroup(groupName, [conversationID1, conversationID2])
      .then((resultList: V2TIMConversationOperationResult[]) => {
        TestResult.result = `deleteConversationsFromGroup succeeded ${resultList}`;
      })
      .catch((error: Error) => {
        TestResult.result = `deleteConversationsFromGroup failed  ${error}`;
      });
  }
}

const conversationListener: V2TIMConversationListener = {
  onSyncServerStart: () => {
    TestResult.result = "onSyncServerStart";
  },
  onSyncServerFinish: () => {
    TestResult.result = "onSyncServerFinish";
  },
  onSyncServerFailed: () => {
    TestResult.result = "onSyncServerFailed";
  },
  onNewConversation: (conversationList: V2TIMConversation[]) => {
    TestResult.result = `onNewConversation ${conversationList}`;
  },
  onConversationChanged: (conversationList: V2TIMConversation[]) => {
    TestResult.result = `onConversationChanged ${conversationList}`;
  },
  onConversationDeleted: (conversationIDList: string[]) => {
    TestResult.result = `onConversationDeleted ${conversationIDList}`;
  },
  onTotalUnreadMessageCountChanged: (totalUnreadCount: number) => {
    TestResult.result = `onTotalUnreadMessageCountChanged ${totalUnreadCount}`;
  },
};
