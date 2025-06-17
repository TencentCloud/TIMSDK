import { V2TIMManager, V2TIMSDKConfig, V2TIMUserFullInfo, V2TIMLogLevel, V2TIMMessage } from '@tencentcloud/imsdk'
import { ConversationListState } from './ConversationListState'
import { MessageListState, MessageListType } from './MessageListState'
import { MessageInputState } from './MessageInputState'
import { MessageActionState } from './MessageActionState'
import { GroupMemberListState } from './GroupMemberListState'

////////////////////////////////////////////////////////////
// 数据定义
////////////////////////////////////////////////////////////

/**
 * 登录状态
 */
export enum LoginStatus {
  Unlogin = 0, // 未登录
  Logined = 1 // 已登录
}

/**
 * 用户信息
 */
export class UserInfo {
  userID?: string // 用户ID
  nickName?: string // 昵称
  friendRemark?: string // 好友备注
  faceUrl?: string // 头像URL

  constructor(userID: string, nickName?: string, friendRemark?: string, faceUrl?: string) {
    this.userID = userID
    this.nickName = nickName
    this.friendRemark = friendRemark
    this.faceUrl = faceUrl
  }
}

/**
 * 错误结果
 */
export class ErrorResult {
  code?: number
  message?: string

  constructor(code: number, message: string) {
    this.code = code
    this.message = message
  }
}

// 定义SDK错误类型
export interface SDKError {
  code: number
  message: string
}

////////////////////////////////////////////////////////////
// 聊天引擎
////////////////////////////////////////////////////////////
export class ChatEngine {
  // 单例模式
  private static instance: ChatEngine | null = null
  // 属性
  private loginStatus: LoginStatus = LoginStatus.Unlogin
  private loginUserInfo: UserInfo | undefined = undefined
  private sdkAppID: number = 0

  private constructor() {
    // 私有构造函数
  }

  /**
   * 获取已登录用户信息
   */
  public get currentUserInfo(): UserInfo | undefined {
    return this.loginUserInfo
  }

  /**
   * 获取当前登录状态
   */
  public get currentLoginStatus(): LoginStatus {
    return this.loginStatus
  }

  /**
   * 获取当前SDKAPPID
   */
  public get currentSDKAppID(): number {
    return this.sdkAppID
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): ChatEngine {
    if (ChatEngine.instance === null) {
      ChatEngine.instance = new ChatEngine()
    }
    return ChatEngine.instance
  }

  /**
   * 登录
   * @param sdkAppID SDK应用ID
   * @param userID 用户ID
   * @param userSig 用户签名
   * @returns Promise<void>
   */
  login(sdkAppID: number, userID: string, userSig: string): Promise<void> {
    return this.loginInternal(sdkAppID, userID, userSig)
  }

  /**
   * 登出
   * @returns Promise<void>
   */
  logout(): Promise<void> {
    return this.logoutInternal()
  }

  /**
   * 创建消息列表状态
   * @param conversationID 会话ID
   * @param messageListType 消息列表类型
   * @returns 消息列表状态对象
   */
  createMessageListState(conversationID: string, messageListType: MessageListType): MessageListState {
    const messageListState = new MessageListState(conversationID, messageListType);
    // 使用 MessageDataSource 替代直接访问 messageList 数组
    // 注意: 相关组件使用 messageDataSource 替代 messageList
    return messageListState;
  }

  /**
   * 创建消息操作状态
   * @returns 消息操作状态对象
   */
  createMessageActionState(): MessageActionState {
    return new MessageActionState()
  }

  /**
   * 创建消息输入状态
   * @param conversationID 会话ID
   * @returns 消息输入状态对象
   */
  createMessageInputState(conversationID: string): MessageInputState {
    return new MessageInputState(conversationID)
  }

  /**
   * 创建会话列表状态
   * @returns 会话列表状态对象
   */
  createConversationListState(): ConversationListState {
    return new ConversationListState()
  }

  /**
   * 创建群成员列表状态
   * @param groupID 群组ID
   * @returns 群成员列表状态对象
   */
  createGroupMemberListState(groupID: string): GroupMemberListState {
    return new GroupMemberListState()
  }

  /**
   * 登录内部实现
   */
  private loginInternal(sdkAppID: number, userID: string, userSig: string): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      // 初始化SDK配置
      const config: V2TIMSDKConfig = {
        logLevel: V2TIMLogLevel.V2TIM_LOG_INFO
      }
      
      const initSuccess = V2TIMManager.getInstance().initSDK(getContext().getApplicationContext(), sdkAppID, config)
      if (!initSuccess) {
        reject(new ErrorResult(-1, "SDK initialization failed"))
        return
      }
      
      this.sdkAppID = sdkAppID
      
      // 使用Promise风格调用
      V2TIMManager.getInstance().login(userID, userSig).then(() => {
        this.loginStatus = LoginStatus.Logined
        
        // 获取用户信息
        this.getUserInfo(userID).then(() => {
          resolve()
        }).catch((error: ErrorResult) => {
          // 即使获取用户信息失败，登录仍然算成功
          console.warn(`Login successful but failed to get user info: ${error.message}`)
          resolve()
        })
      }).catch((error: SDKError) => {
        // 处理登录失败
        reject(new ErrorResult(error.code || -1, error.message || "Login failed"))
      })
    })
  }
  
  /**
   * 登出内部实现
   */
  private logoutInternal(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      // 使用Promise风格调用
      V2TIMManager.getInstance().logout().then(() => {
        this.loginStatus = LoginStatus.Unlogin
        this.loginUserInfo = undefined
        resolve()
      }).catch((error: SDKError) => {
        reject(new ErrorResult(error.code || -1, error.message || "Logout failed"))
      })
    })
  }
  
  /**
   * 获取用户信息
   */
  private getUserInfo(userID: string): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      V2TIMManager.getInstance().getUsersInfo([userID]).then((infoList) => {
        if (infoList && infoList.length > 0) {
          const info = infoList[0]
          this.loginUserInfo = new UserInfo(
            info.userID, 
            info.nickName, 
            undefined, // friendRemark 可能不在userInfo中，需要单独获取
            info.faceURL
          )
          resolve()
        } else {
          reject(new ErrorResult(-1, "User info list is empty"))
        }
      }).catch((error: SDKError) => {
        reject(new ErrorResult(error.code || -1, error.message || "Failed to get user info"))
      })
    })
  }
}
