
import IComponentServer from '../IComponentServer';

import { TUIChatStoreType } from '../types';

import { useStore } from 'vuex';
import store from '../../store';

/**
 * class TUIProfileServer
 *
 * TUIProfile 逻辑主体
 */
export default class TUIProfileServer extends IComponentServer {
  public TUICore: any;
  public store = store.state.timStore
  public currentStore: any = {};
  constructor(TUICore: any) {
    super();
    this.TUICore = uni.$TUIKit;
    this.bindTIMEvent();
    // this.store = TUICore.setComponentStore('TUIProfile', store, this.updateStore.bind(this));
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
  updateStore(newValue: any, oldValue: any) {
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

  private handleProfileUpdated(event: any) {
    // event.data.map((item: any) => {
    //   if (item.userID === this.store.profile.userID) {
    //     this.store.profile = {};
    //     this.store.profile = item;
    //   }
    //   return item;
    // });
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
  public handlePromiseCallback(callback: any) {
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
  public async getMyProfile() {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
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
 * 更新用户资料
 *
 * @param {Object} options 资料参数--[详细参数,请点击查看详情](https://web.sdk.qcloud.com/im/doc/zh-cn//SDK.html#updateMyProfile)
 * @returns {Promise}
 */
  public async updateMyProfile(options: any) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
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
 * @param {Object} params 使用的数据
 * @returns {Object} 数据
 */
  public async bind(params: any) {
    this.currentStore = params;
    return this.currentStore;
  }
}

/**
 * 获取其他用户资料
 *
 * @param {Array<string>} userIDList 用户的账号列表
 * @returns {Promise}
 */
export async function getUserProfile(userIDList: Array<string>) {
  return new Promise<void>(async (resolve, reject) => {
    try {
      const imResponse = await uni.$TUIKit.tim.getUserProfile({ userIDList });
      resolve(imResponse);
    } catch (error) {
      reject(error);
    }
  });
}
