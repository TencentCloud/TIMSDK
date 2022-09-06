import { TUITheme, TUIi18n, TUIEnv, TUIDirective } from '../../TUIPlugin';

import TIM from '../tim';
import TIMUploadPlugin from 'tim-upload-plugin';

import ITUIServer from '../interfaces/ITUIServer';
import TUIStore from '../store';

import { TUICoreParams, TUICoreLoginParams, TUIServer } from '../type';

import { isFunction } from '../utils';
import TUIAegis from '../../utils/TUIAegis';
export default class TUICore extends ITUIServer {
  static instance: TUICore;
  static isLogin = false;
  public isOfficial = false;
  public isIntl = false;

  public tim: any;
  public TIM: any;
  static TUIServerFunMap: Map<string, Array<void>>;
  private isSDKReady = false;
  private store: TUIStore;

  public TUIEnv: any;

  private SDKAppID: number;
  private installedPlugins: Set<any> = new Set();
  public config: any = {};
  public TUIServer: TUIServer;
  public TUIComponents: Set<any> = new Set();
  private loginResolveRejectCache: Array<{
    resolve: (value: any) => void;
    reject: (reason?: any) => void;
  }>;

  constructor(params: TUICoreParams) {
    super();
    this.loginResolveRejectCache = [];
    this.SDKAppID = params.SDKAppID;
    this.TUIServer = {};
    this.store = new TUIStore();
    this.TIM = TIM;
    (window as any).TIM = TIM;
    if (!params.tim) {
      (window as any).TUIKit = TIM.create({ SDKAppID: this.SDKAppID });
    } else {
      (window as any).TUIKit = params.tim;
    }
    this.tim = (window as any).TUIKit;
    // 注册 COS SDK 插件
    this.tim.registerPlugin({ 'tim-upload-plugin': TIMUploadPlugin });

    this.bindTIMEvent();
    this.TUIEnv = TUIEnv();
    this.isOfficial = this.SDKAppID === 1400187352;
  }

  /**
   * 初始化TUICore
   *
   * @param {TUICoreParams} options 初始化参数
   * @returns {TUICore} TUICore的实例
   */
  static init(options: TUICoreParams) {
    const Aegis = TUIAegis.getInstance();
    if (!TUICore.instance) {
      TUICore.instance = new TUICore(options);
    }
    if (TUIEnv().isH5) {
      Aegis.reportEvent({
        name: 'SDKAppID',
        ext1: 'IMTUIKitH5External',
        ext2: 'IMTUIKitH5External',
        ext3: options.SDKAppID,
      });
      Aegis.setAegisOptions({
        ext2: 'TUIKitH5',
        ext3: options.SDKAppID,
      });
    } else {
      Aegis.reportEvent({
        name: 'SDKAppID',
        ext1: 'IMTUIKitWebExternal',
        ext2: 'IMTUIKitWebExternal',
        ext3: options.SDKAppID,
      });
      Aegis.setAegisOptions({
        ext2: 'TUIKitWeb',
        ext3: options.SDKAppID,
      });
    }
    Aegis.reportEvent({
      name: 'time',
      ext1: 'firstRunTime',
    });
    (window as any).TUIKitTUICore = TUICore.instance;
    TUICore.instance.use(TUITheme);
    TUICore.instance.use(TUIi18n);
    return TUICore.instance;
  }

  /**
   * TUICore 挂载vue方法
   *
   * @param {Vue} app vue createApp实例
   */
  public install(app: any) {
    app.config.globalProperties.$TUIKit = this.getInstance();

    let flag = true;
    this.installedPlugins.forEach((element) => {
      app.use(element);
      if (element.name === 'TUIComponents') {
        flag = false;
      }
    });

    flag &&
      this.TUIComponents.forEach((element) => {
        app.component(element.name, element.component);
      });

    TUIDirective(app);
  }

  /**
   * 获取TUICore实例
   *
   * @returns {TUICore} TUICore的实例
   */
  public getInstance() {
    return TUICore.instance;
  }

  /**
   * TUICore 登录
   *
   * @param {TUICoreLoginParams} options 登录参数
   * @param {string} options.userID 当前用户名
   * @param {string} options.userSig 当前用户名签名
   * @returns {Promise}
   */
  public login(options: TUICoreLoginParams): Promise<any> {
    return new Promise<void>((resolve, reject) => {
      this.tim
        .login(options)
        .then(() => {
          this.loginResolveRejectCache.push({
            resolve,
            reject,
          });
          TUICore.isLogin = true;
          return null;
        })
        .catch((error: any) => {
          reject(error);
        });
    });
  }

  /**
   * TUICore 退出登录
   *
   * @returns {Promise}
   */
  public logout(): Promise<any> {
    return new Promise<void>((resolve, reject) => {
      this.tim
        .logout()
        .then((imResponse: any) => {
          this.isSDKReady = false;
          TUICore.isLogin = false;
          resolve(imResponse);
        })
        .catch((error: any) => {
          reject(error);
        });
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
    this.tim.on(TIM.EVENT.SDK_READY, this.handleSDKReady, this);
    // this.tim.on(TIM.EVENT.SDK_NOT_READY,)
    // this.tim.on(TIM.EVENT.KICKED_OUT,)
    // this.tim.on(TIM.EVENT.ERROR, )
    // this.tim.on(TIM.EVENT.NET_STATE_CHANGE, )
    // this.tim.on(TIM.EVENT.SDK_RELOAD, )
  }

  private unbindTIMEvent() {
    this.tim.off(TIM.EVENT.SDK_READY, this.handleSDKReady);
    // this.tim.off(TIM.EVENT.SDK_NOT_READY, )
    // this.tim.off(TIM.EVENT.KICKED_OUT,)
    // this.tim.off(TIM.EVENT.ERROR, )
    // this.tim.off(TIM.EVENT.NET_STATE_CHANGE, )
    // this.tim.off(TIM.EVENT.SDK_RELOAD, )
  }

  /**
   * SDK ready 回调函数
   */
  private handleSDKReady() {
    this.isSDKReady = true;
    this.handelAwaitFunc(TUICore.TUIServerFunMap);
    this.loginResolveRejectCache.forEach(({ resolve }) => {
      resolve({
        msg: '登录成功，且SDK Ready',
      });
    });
  }

  /**
   * 处理等待函数
   *
   * @param {Map} awaitFunList 等待调用的函数
   * @returns {Map} 执行完的数据
   */
  private handelAwaitFunc(awaitFunList: Map<string, any>) {
    const keys = Object.keys(this.TUIServer);
    for (let i = 0; i < keys.length; i++) {
      const TUIServerFunList = awaitFunList?.get(keys[i]) || [];
      TUIServerFunList.length > 0 && TUIServerFunList.map((callback: any) => callback());
      awaitFunList?.delete(keys[i]);
    }
    return awaitFunList;
  }

  /**
   * TUICore 销毁
   */
  public destroyed() {
    this.unbindTIMEvent();
    this.isSDKReady = false;
  }

  /**
   * 组件挂载
   *
   * @param {string} TUIName  挂载的组件名
   * @param {any} TUIComponent 挂载的组件
   * @returns {TUICore} 挂载后的实例
   */
  public component(TUIName: string, TUIComponent: any) {
    const TUICore = this.getInstance();
    if (!this.TUIServer) {
      this.TUIServer = {};
    }
    // const Server = TUIComponent.server;
    this.TUIServer[TUIName] = TUIComponent.server;
    if (this.TUIComponents.has(TUIComponent)) {
      console.warn(`${TUIName} component has already been applied to target TUICore.`);
    } else {
      this.TUIComponents.add(TUIComponent);
    }
    return TUICore;
  }

  /**
   * 插件注入
   *
   * @param {any} TUIPlugin 需要挂载模块的服务
   * @param {any} options 其他参数
   * @returns {TUICore} 挂载后的实例
   */
  public use(TUIPlugin: any, options?: any) {
    const TUICore = this.getInstance();
    if (this.installedPlugins.has(TUIPlugin)) {
      console.warn('Plugin has already been applied to target TUICore.');
    } else if (TUIPlugin && isFunction(TUIPlugin?.plugin)) {
      this.installedPlugins.add(TUIPlugin);
      TUIPlugin?.plugin(TUICore, options);
    } else if (isFunction(TUIPlugin)) {
      this.installedPlugins.add(TUIPlugin);
      TUIPlugin(TUICore, options);
    } else {
      console.warn('A plugin must either be a function or an object with an "plugin" ' + 'function.');
    }
    return TUICore;
  }

  public usePlugin(TUIPluginName: string) {
    let plugin = {};
    this.installedPlugins.forEach((element) => {
      if (element.name === TUIPluginName) {
        plugin = element;
      }
    });
    return plugin;
  }

  /**
   * 方法调用
   *
   * @param {string} TUIName 组件名
   * @param {callback} callback 调用的方法
   */
  public setAwaitFunc(TUIName: string, callback: any) {
    if (this.isSDKReady) {
      callback();
    } else {
      if (!TUICore.TUIServerFunMap) {
        TUICore.TUIServerFunMap = new Map();
      }

      const TUIServerFunList: Array<void> = TUICore.TUIServerFunMap.get(TUIName) || [];
      TUIServerFunList.push(callback);
      TUICore.TUIServerFunMap.set(TUIName, TUIServerFunList);
    }
  }

  /**
   * 设置公共数据
   *
   * @param {object} store 设置全局的数据
   * @returns {proxy} 设置完成的数据
   */
  public setCommonStore(store: Record<string, unknown>) {
    return this.store.setCommonStore(store);
  }

  /**
   * 挂载组件数据
   *
   * @param {string} TUIName 模块名
   * @param {any} store  挂载的数据
   * @param {callback} updateCallback 更新数据 callback
   * @returns {proxy} 挂载完成的模块数据
   */
  public setComponentStore(TUIName: string, store: any, updateCallback?: any) {
    return this.store.setComponentStore(TUIName, store, updateCallback);
  }

  /**
   * 获取 store 数据库
   *
   * @returns {any} store 数据库
   */
  public getStore() {
    return this.store.store;
  }

  /**
   * 监听全局数据
   *
   * @param {Array} keys 需要监听的数据key
   * @param {callback} callback 数据变化回调
   * @returns {addStoreUpdate}
   */
  public storeCommonListener(keys: Array<string>, callback: any) {
    return this.store.storeCommonListener(keys, callback);
  }
}
