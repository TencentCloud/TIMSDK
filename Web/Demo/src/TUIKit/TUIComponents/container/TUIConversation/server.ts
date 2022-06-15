import IComponentServer from '../IComponentServer';

/**
 * class TUIConversationServer
 *
 * TUIConversation 逻辑主体
 */
export default class TUIConversationServer extends IComponentServer {
  public TUICore:any;
  public store:any;
  public currentStore: any = {};
  public storeCallback:any;
  constructor(TUICore:any) {
    super();
    this.TUICore = TUICore;
    this.bindTIMEvent();
    this.store = TUICore.setComponentStore('TUIConversation', {}, this.updateStore.bind(this));
  }

  /**
   * 组件销毁
   *
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
    if (!this?.currentStore?.conversationData) {
      return;
    }
    this.currentStore.conversationData.list = newValue.conversationList;
  }

  /**
   * 处理异步函数
   *
   * @param {callback} callback 回调函数
   * @returns {Promise} 返回异步函数
   */
  private handlePromiseCallback(callback:any) {
    return new Promise<void>((resolve, reject) => {
      const config = {
        TUIName: 'TUIConversation',
        callback: () => {
          callback && callback(resolve, reject);
        },
      };
      this.TUICore.setAwaitFunc(config.TUIName, config.callback);
    });
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 事件监听注册接口
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.CONVERSATION_LIST_UPDATED, this.handleConversationListUpdate, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.NET_STATE_CHANGE, this.handleNetStateChange, this);
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.CONVERSATION_LIST_UPDATED, this.handleConversationListUpdate);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.NET_STATE_CHANGE, this.handleNetStateChange);
  }

  private handleConversationListUpdate(res:any) {
    this.handleFilterSystem(res.data);
  }

  private handleNetStateChange(res:any) {
    this.currentStore.netWork = res?.data?.state || '';
  }

  /**
   * 处理conversationList
   *
   * @param {Array} list conversationList
   * @returns {Object}
   */
  private handleFilterSystem(list: any) {
    const options = {
      allConversationList: list,
      conversationList: [],
    };
    const currentList = list.filter((item:any) => item?.conversationID === this?.currentStore?.currentConversationID);
    if (currentList.length === 0) {
      this.handleCurrentConversation({});
    }
    options.conversationList = list.filter((item:any) => item.type !== this.TUICore.TIM.TYPES.CONV_SYSTEM);
    this.store.allConversationList = options.allConversationList;
    this.store.conversationList = options.conversationList;
    return options;
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 方法
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 设置已读
   *
   * @param {string} conversationID 会话ID
   * @returns {Promise}
   */
  public async setMessageRead(conversationID: string) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse:any = await this.TUICore.tim.setMessageRead({ conversationID });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 删除会话
   *
   * @param {string} conversationID 会话ID
   * @returns {Promise}
   */
  public async deleteConversation(conversationID: string) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse:any = await this.TUICore.tim.deleteConversation(conversationID);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 置顶会话
   *
   * @param {Object} options 置顶参数
   * @returns {Promise}
   */
  public async pinConversation(options: any) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse:any = await this.TUICore.tim.pinConversation(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * C2C消息免打扰
   *
   * @param {Object} options 消息免打扰参数
   * @returns {Promise}
   */
  public async muteConversation(options: any) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse:any = await this.TUICore.tim.setMessageRemindType(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }
  /**
   * 获取 conversationList
   *
   * @param {string} conversationID 会话ID
   * @returns {Promise}
   */
  public async getConversationProfile(conversationID:string) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getConversationProfile(conversationID);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

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
 * 获取其他用户资料
 *
 * @param {Array<string>} userIDList 用户的账号列表
 * @returns {Promise}
 */
  public async getUserProfile(userIDList:Array<string>) {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getUserProfile({ userIDList });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    UI 数据绑定server数据同步
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 赋值
   *
   * @param {Object} params 使用的数据
   * @returns {Object} 数据
   */
  public async bind(params:any) {
    this.currentStore = params;
    await this.getConversationList();
    return this.currentStore;
  }

  // 切换当前会话
  public handleCurrentConversation(value: any) {
    // 通知 TUIChat 切换会话或关闭会话
    this.TUICore.getStore().TUIChat.conversation = value || {};

    if (!value?.conversationID) {
      this.currentStore.currentConversationID = '';
      return;
    }
    // Prevent group chat that is currently open from entering from the address book, resulting in no jump.
    if (this.currentStore.currentConversationID === value?.conversationID) {
      this.currentStore.currentConversationID = '';
    }
    if (this.currentStore.currentConversationID) {
      this.setMessageRead(this.currentStore.currentConversationID);
    }
    this.currentStore.currentConversationID = value?.conversationID;
    this.setMessageRead(value.conversationID);
  }
}
