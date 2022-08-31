class TUIAegis {
  private aegis: any;
  private options: any = {};
  static instance: any;
  private aegisOptions: any = [];
  constructor(Aegis?: any) {
    if (Aegis) {
      this.aegis = Aegis;
    } else {
      this.init(() => {
        this.aegis = new (window as any).Aegis({
          id: 'iHWefAYqTgxNuvtAjr', // 项目key
          uin: '', // 用户唯一 ID（可选）
          reportApiSpeed: true, // 接口测速
          reportAssetSpeed: true, // 静态资源测速
          spa: true, // spa 页面需要开启，页面切换的时候上报pv
        });
        if (this.aegisOptions.length > 0) {
          this.aegisOptions.map((options: any) => {
            this.reportEvent(options);
            return options;
          });
          this.aegisOptions = [];
        }
      });
    }
  }

  /**
   * install 挂载vue上
   *
   * @param {any} app Vue 实例
   */
  public install(app: any) {
    app.config.globalProperties.$TUIAegis = TUIAegis.getInstance();
  }

  static getInstance() {
    if (!TUIAegis.instance) {
      TUIAegis.instance = new TUIAegis((window as any).$Aegis);
    }
    return TUIAegis.instance;
  }

  /**
   * setAegisOptions 设置上报公共参数
   *
   * @param {any} options 公共参数
   */
  public setAegisOptions(options: any) {
    this.options = options;
  }

  /**
   * reportEvent 上报事件
   *
   * @param {any} options 上报的内容
   * @returns {reportEvent}
   */
  public reportEvent(options: any) {
    if (this.aegis) {
      this.aegis.reportEvent({ ...options, ...this.options });
    } else {
      this.aegisOptions = [...this.aegisOptions, options];
    }
  }

  private init(callback: any) {
    if (!TUIAegis.instance) {
      const script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = 'https://tam.cdn-go.cn/aegis-sdk/latest/aegis.min.js';
      document.getElementsByTagName('head')[0].appendChild(script);
      script.onload = callback;
    }
  }
}

export default TUIAegis;
