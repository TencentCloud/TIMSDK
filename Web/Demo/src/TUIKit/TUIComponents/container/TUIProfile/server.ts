
import IComponentServer from '../IComponentServer';

const store:any = {
  profile: {},
};

/**
 * class TUIProfileServer
 *
 * TUIProfile 逻辑主体
 */
export default class TUIProfileServer extends IComponentServer {
  public TUICore:any;
  public store:any;
  public currentStore: any = {};
  constructor(TUICore:any) {
    super();
    this.TUICore = TUICore;
    this.bindTIMEvent();
    this.store = TUICore.setComponentStore('TUIProfile', store, this.updateStore.bind(this));
    this.getMyProfile();
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
    this.currentStore.profile = JSON.parse(JSON.stringify(newValue.profile));
  }


  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 事件监听注册接口
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.PROFILE_UPDATED, this.handleProfileUpdated, this);
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.PROFILE_UPDATED, this.handleProfileUpdated);
  }

  private handleProfileUpdated(event:any) {
    event.data.map((item:any) => {
      if (item.userID === this.store.profile.userID) {
        this.store.profile = {};
        this.store.profile = item;
      }
      return item;
    });
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
  public handlePromiseCallback(callback:any): Promise<any> {
    return new Promise<void>((resolve, reject) => {
      const config = {
        TUIName: 'TUIProfile',
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
 * //                                 TIM方法
 * //
 * /////////////////////////////////////////////////////////////////////////////////
 */

  /**
 * 获取个人资料
 *
 * @returns {Promise}
 */
  public async getMyProfile(): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getMyProfile();
        this.store.profile = imResponse.data;
        this.currentStore.profile = JSON.parse(JSON.stringify(this.store.profile));
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
  public async getUserProfile(userIDList:Array<string>): Promise<any> {
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
 * 更新用户资料
 *
 * @param {Object} options 资料参数--[详细参数,请点击查看详情](https://web.sdk.qcloud.com/im/doc/zh-cn//SDK.html#updateMyProfile)
 * @returns {Promise}
 */
  public async updateMyProfile(options:any): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.updateMyProfile(options);
        this.store.profile = imResponse.data;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 赋值
 *
 * @param {any} params 使用的数据
 * @returns {any} 数据
 */
  public async bind(params:unknown): Promise<any> {
    this.currentStore = params;
    this.getMyProfile();
    return this.currentStore;
  }

  /**
 * 赋值
 *
 * @param {Boolean} params 使用的数据
 * @returns {boolean} 数据
 */
  public setEdit(params:boolean): boolean {
    this.currentStore.isEdit = params;
    return this.currentStore.isEdit;
  }
}
