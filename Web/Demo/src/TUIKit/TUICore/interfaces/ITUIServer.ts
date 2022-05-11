/* eslint-disable @typescript-eslint/no-empty-function */
import { TUICoreParams, TUICoreLoginParams } from '../type';
export default class ITUIServer {
  /**
   * 初始化TUICore
   *
   * @param {TUICoreParams} options 初始化参数
   */
  static init(options:TUICoreParams) {}

  /**
   * TUICore 挂载vue方法
   *
   * @param {Vue} app vue createApp实例
   */
  public install(app:any) {}

  /**
   * 获取TUICore实例
   *
   */
  public getInstance() {}

  /**
   * TUICore 登录
   *
   * @param {TUICoreLoginParams} options 登录参数
   * @param {string} options.userID 当前用户名
   * @param {string} options.userSig 当前用户名签名
   * @returns {Promise}
   */
  public login(options:TUICoreLoginParams): Promise<any> {
    return new Promise<void>((resolve, reject) => {
    });
  }

  /**
   * TUICore 销毁
   */
  public destroyed() {}

  /**
   * 组件挂载
   *
   * @param {string} TUIName  挂载的组件名
   * @param {any} TUIComponent 挂载的组件
   */
  public component(TUIName: string, TUIComponent:any) {}


  /**
   * 插件注入
   *
   * @param {any} TUIPlugin 需要挂载模块的服务
   * @param {any} options 需要挂载模块的服务
   */
  public use(TUIPlugin:any, options?: any) { }

  /**
   * 方法调用
   *
   * @param {string} TUIName 组件名
   * @param {callback} callback 调用的方法
   */
  public setAwaitFunc(TUIName: string, callback: any) {}

  /**
   * 设置公共数据
   *
   * @param {object} store  设置全局的数据
   */
  public setCommonStore(store: Record<string, unknown>) {}

  /**
   * 挂载组件数据
   *
   * @param {string} TUIName 模块名
   * @param {any} store  挂载的数据
   * @param {callback} updateCallback 更新数据 callback
   */
  public setComponentStore(TUIName:string, store: any, updateCallback?:any) {}

  /**
   * 获取 store 数据库
   *
   */
  public getStore() {}

  /**
   * 监听全局数据
   *
   * @param {Array} keys 需要监听的数据key
   * @param {callback} callback 数据变化回调
   */
  public storeCommonListener(keys:Array<string>, callback: any) {}
}
