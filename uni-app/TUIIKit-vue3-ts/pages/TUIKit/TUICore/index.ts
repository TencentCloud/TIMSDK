//  引入 SDK 
// #ifdef H5
import TIM from 'tim-js-sdk';
import TIMUploadPlugin from 'tim-upload-plugin';
// #endif
// #ifdef APP-PLUS
import TIM from 'tim-wx-sdk';
import COS from 'cos-wx-sdk-v5';
// #endif

// #ifdef MP-WEIXIN
import TIM from 'tim-wx-sdk';
import TIMUploadPlugin from 'tim-upload-plugin';
// #endif

// 模块逻辑层
import { TUIConversationServer, TUIChatServer, TUIProfileServer, TUIGroupServer } from './server'
// 其他
import ITUIServer from './interfaces/ITUIServer';
// import TUIStore from './store';
import { TUICoreParams, TUICoreLoginParams, TUIServer } from './type';
import { isFunction } from './utils';
export class TUICore extends ITUIServer {
  static instance: TUICore;
  static isLogin: Boolean = false;

  public tim: any;
  public TIM: any;
  private isSDKReady: boolean = false;
  private SDKAppID: number;
  public config: any = {};
  constructor(params: TUICoreParams) {
    super();
    this.SDKAppID = params.SDKAppID;
    this.TIM = TIM;
    //this.store = new TUIStore();
    if (!params.tim) {
      this.tim = TIM.create({ SDKAppID: this.SDKAppID, devMode: true });
    } else {
      this.tim = params.tim;
    }
    // 注册 COS SDK 插件
    // #ifdef APP-PLUS
    this.tim.registerPlugin({ 'cos-wx-sdk': COS });
    // #endif
		// #ifndef APP-PLUS
    this.tim.registerPlugin({ 'tim-upload-plugin': TIMUploadPlugin });
		// #endif
     this.bindTIMEvent();
  }

  /**
   * 初始化TUICore
   *
   * @param {TUICoreParams} options 初始化参数
   * @returns {TUICore} TUICore的实例
   */
  static init(options: TUICoreParams) {
    if (!TUICore.instance) {
      TUICore.instance = new TUICore(options);
			uni.setStorageSync(`TIM_${this.SDKAppID}_isTUIKit`, true);		
    }
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
      this.tim.login(options).then(() => {
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
      this.tim.logout().then((imResponse: any) => {
        this.isSDKReady = false;
        TUICore.isLogin = false;
				this.TUIConversationServer.destroyed();
				this.TUIChatServer.destroyed();
				this.TUIProfileServer.destroyed();
				this.TUIGroupServer.destroyed();
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
    this.tim.on(TIM.EVENT.SDK_NOT_READY, this.handleSDKNotReady, this)
    // this.tim.on(TIM.EVENT.KICKED_OUT, )
    // this.tim.on(TIM.EVENT.ERROR, )
    // this.tim.on(TIM.EVENT.NET_STATE_CHANGE, )
    // this.tim.on(TIM.EVENT.SDK_RELOAD, )
  }

  private unbindTIMEvent() {
    this.tim.off(TIM.EVENT.SDK_READY, this.handleSDKReady);
    // this.tim.off(TIM.EVENT.SDK_NOT_READY, )
    // this.tim.off(TIM.EVENT.KICKED_OUT, )
    // this.tim.off(TIM.EVENT.ERROR, )
    // this.tim.off(TIM.EVENT.NET_STATE_CHANGE, )
    // this.tim.off(TIM.EVENT.SDK_RELOAD, )
  }

  /**
   * SDK ready 回调函数
   */
  private handleSDKReady(event) {
    this.isSDKReady = true;
    this.TUIConversationServer = new TUIConversationServer();
    this.TUIChatServer = new TUIChatServer();
    this.TUIProfileServer = new TUIProfileServer();
    this.TUIGroupServer = new TUIGroupServer();
  }
	private handleSDKNotReady(event) {
			this.isSDKReady = false;
			uni.showToast({
				title: 'SDK 未完成初始化'
			})
		  // console.error(event)
	}
 
  /**
   * TUICore 销毁
   */
  public destroyed() {
    this.unbindTIMEvent();
    this.isSDKReady = false;
  }

}
