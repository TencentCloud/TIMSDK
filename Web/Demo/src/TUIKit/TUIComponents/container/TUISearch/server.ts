import IComponentServer from '../IComponentServer';

/**
 * class TUISearchServer
 *
 * TUISearch 逻辑主体
 */
export default class TUISearchServer extends IComponentServer {
  public TUICore: any;
  public store: any;
  public currentStore: any = {};
  public storeCallback: any;
  constructor(TUICore: any) {
    super();
    this.TUICore = TUICore;
    this.bindTIMEvent();
    this.store = TUICore.setComponentStore('TUISearch', {}, this.updateStore.bind(this));
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
  updateStore(newValue: any, oldValue: any) {
    if (this?.currentStore?.conversationData?.list) {
      this.currentStore.conversationData.list = newValue.conversationList;
    }
  }

  /**
   * 处理异步函数
   *
   * @param {callback} callback 回调函数
   * @returns {Promise} 返回异步函数
   */
  private handlePromiseCallback(callback: any) {
    return new Promise<void>((resolve, reject) => {
      const config = {
        TUIName: 'TUISearch',
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
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.FRIEND_LIST_UPDATED, this.handleFriendListUpdated, this);
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.FRIEND_LIST_UPDATED, this.handleFriendListUpdated);
  }

  private handleFriendListUpdated(event: any) {
    this.currentStore.searchUserList = event.data.map((item: any) => item?.profile);
    this.currentStore.allUserList = event.data.map((item: any) => item?.profile);
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 方法
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 获取 conversationList
   *
   * @param {string} conversationID 会话ID
   * @returns {Promise}
   */
  public async getConversationProfile(conversationID: string): Promise<void> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getConversationProfile(conversationID);
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
  public async getUserProfile(userIDList: Array<string>): Promise<void> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getUserProfile({ userIDList });
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
  public async getFriendList(): Promise<void> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getFriendList();
        this.currentStore.searchUserList = imResponse.data.map((item: any) => item?.profile);
        this.currentStore.allUserList = imResponse.data.map((item: any) => item?.profile);
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
  public async bind(params: any) {
    this.currentStore = params;
    await this.getFriendList();
    return this.currentStore;
  }
}
