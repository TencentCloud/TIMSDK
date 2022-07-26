
import IComponentServer from '../IComponentServer';

const store:any = {};

/**
 * class TUIContactServer
 *
 * TUIGroup 逻辑主体
 */
export default class TUIContactServer extends IComponentServer {
  public TUICore:any;
  public store:any;
  public currentStore: any = {};
  public storeCallback: any;
  constructor(TUICore:any) {
    super();
    this.TUICore = TUICore;
    this.bindTIMEvent();
    this.store = TUICore.setComponentStore('TUIContact', store, this.updateStore.bind(this));
  }

  /**
   * 组件销毁
   */
  public destroyed() {
    this.unbindTIMEvent();
  }

  /**
     * 数据监听回调
     *
     * @param {any} newValue 新数据
     * @param {any} oldValue 旧数据
     */
  updateStore(newValue:any, oldValue:any) {
    this.currentStore.groupList = newValue.groupList;
    this.currentStore.searchGroup = newValue.searchGroup;
    this.currentStore.systemConversation = newValue.systemConversation;
    this.currentStore.systemMessageList = newValue.systemMessageList;
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 事件监听注册接口
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.GROUP_ATTRIBUTES_UPDATED, this.handleGroupAttributesUpdated, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.CONVERSATION_LIST_UPDATED, this.handleConversationListUpdate, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.FRIEND_LIST_UPDATED, this.handleFriendListUpdated, this);
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.GROUP_ATTRIBUTES_UPDATED, this.handleGroupAttributesUpdated);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.CONVERSATION_LIST_UPDATED, this.handleConversationListUpdate);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.FRIEND_LIST_UPDATED, this.handleFriendListUpdated);
  }

  private handleGroupListUpdated(event:any) {
    this.store.groupList = event.data;
  }

  private handleGroupAttributesUpdated(event:any) {
    const { groupID, groupAttributes } = event.data; // 群组ID // 更新后的群属性
    console.log(groupID, groupAttributes);
  }

  private handleConversationListUpdate(res:any) {
    this.handleFilterSystem(res.data);
  }

  private handleFriendListUpdated(event:any) {
    this.currentStore.friendList = event.data;
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 处理 TIM 接口参数及回调
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 处理异步函数
   *
   * @param {callback} callback 回调函数
   * @returns {Promise} 返回异步函数
   */
  public handlePromiseCallback(callback:any) {
    return new Promise<void>((resolve, reject) => {
      const config = {
        TUIName: 'TUIContact',
        callback: () => {
          callback && callback(resolve, reject);
        },
      };
      this.TUICore.setAwaitFunc(config.TUIName, config.callback);
    });
  }

  /**
   * 处理conversationList
   *
   * @param {Array} list conversationList
   * @returns {Object}
   */
  private handleFilterSystem(list:any) {
    const options = {
      allConversationList: list,
      systemConversationList: [],
    };
    options.systemConversationList = list.filter((item:any) => item.type === this.TUICore.TIM.TYPES.CONV_SYSTEM);
    this.store.allConversationList = options.allConversationList;
    this.store.systemConversationList = options.systemConversationList;
    const [systemConversation] = options.systemConversationList;
    this.store.systemConversation = systemConversation;
    return options;
  }


  /**
 * /////////////////////////////////////////////////////////////////////////////////
 * //
 * //                                 对外方法
 * //
 * /////////////////////////////////////////////////////////////////////////////////
 */

  /*
 * 获取 conversationList
 *
 * @returns {Promise}
 */
  public async getConversationList() {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getConversationList();
        this.handleFilterSystem(imResponse.data.conversationList);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 获取系统通知 messageList
 *
 * @returns {Promise}
 */
  public async getSystemMessageList() {
    const options = {
      conversationID: this.store.systemConversation.conversationID,
      count: 15,
    };
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getMessageList(options);
        this.store.systemMessageList = imResponse.data.messageList;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 设置已读
 *
 * @param {string} conversationID 会话ID
 * @returns {Promise}
 */
  public async setMessageRead() {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse:any = await this.TUICore.tim.setMessageRead({ conversationID: this.store.systemConversation.conversationID });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 获取群组列表
 *
 * @param {any} options 参数
 * @param {Array.<String>} options.groupProfileFilter 群资料过滤器
 * @returns {Promise}
 */
  public async getGroupList(options?:any) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        let imResponse:any = {};
        if (!options) {
          imResponse = await this.TUICore.tim.getGroupList();
        } else {
          imResponse = await this.TUICore.tim.getGroupList(options);
        }
        this.store.groupList = imResponse.data.groupList;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 获取群组属性
 *
 * @param {any} options 参数
 * @param {String} options.groupID 群组ID
 * @param {Array.<String>} options.groupProfileFilter 群资料过滤器
 * @returns {Promise}
 */
  public getGroupProfile(options:any): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupProfile(options);
        this.store.groupList = imResponse.data.groupList;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 删除群组
 *
 * @param {String} groupID 群组ID
 * @returns {Promise}
 */
  public dismissGroup(groupID:string): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.dismissGroup(groupID);
        this.store.groupProfile = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 修改群组资料
 *
 * @param {any} options 参数
 * @param {String} options.groupID 群组ID
 * @param {String} options.name 群组名称
 * @param {String} options.introduction 群简介
 * @param {String} options.notification 群公告
 * @param {String} options.avatar 群头像 URL
 * @param {Number} options.maxMemberNum 最大群成员数量
 * @param {Number} options.joinOption 申请加群处理方式
 * @param {Array.<Object>} options.groupCustomField 群组维度的自定义字段
 * @returns {Promise}
 */
  public updateGroupProfile(options:any): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.updateGroupProfile(options);
        this.store.groupProfile = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 申请加群
 *
 * @param {any} options 参数
 * @param {String} options.groupID 群组ID
 * @param {String} options.applyMessage 附言
 * @param {String} options.type 群组类型
 * @returns {Promise}
 */
  public joinGroup(options:any): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.joinGroup(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 退出群组
 *
 * @param {String} groupID 群组ID
 * @returns {Promise}
 */
  public quitGroup(groupID:string): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.quitGroup(groupID);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 通过 groupID 搜索群组
 *
 * @param {String} groupID 群组ID
 * @returns {Promise}
 */
  public searchGroupByID(groupID:string): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.searchGroupByID(groupID);
        this.store.searchGroup = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        this.store.searchGroup = {};
        reject(error);
      }
    });
  }

  /**
 * 处理申请加群
 * - 管理员
 *
 * @param {any} options 参数
 * @param {String} options.handleAction 处理结果 Agree(同意) / Reject(拒绝)
 * @param {String} options.handleMessage 附言
 * @param {Message} options.message 对应【群系统通知】的消息实例
 * @returns {Promise}
 */
  public handleGroupApplication(options:any): Promise<any>  {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.handleGroupApplication(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 获取 SDK 缓存的好友列表
 *
 * @param {Array<string>} userIDList 用户的账号列表
 * @returns {Promise}
 */
  public async getFriendList():Promise<void> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getFriendList();
        this.currentStore.friendList = imResponse.data;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 赋值
 *
 * @param {Object} params 使用的数据
 * @returns {Object} 数据
 */
  public async bind(params:any) {
    this.currentStore = params;
    await this.getGroupList();
    await this.getConversationList();
    await this.getFriendList();
    return this.currentStore;
  }
}


