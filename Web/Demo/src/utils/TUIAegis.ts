class TUIAegis {
  static reportEvent(arg0: { name: string; ext1: string; }) {
    throw new Error('Method not implemented.');
  }
  private aegis:any;
  private options:any = {};
  static instance: any;
  constructor(Aegis?:any) {
    if (Aegis) {
      this.aegis = Aegis;
    } else {
      this.aegis = new (window as any).Aegis({
        id: 'iHWefAYqDTiNaZDjts', // 项目key
        uin: '', // 用户唯一 ID（可选）
        reportApiSpeed: true, // 接口测速
        reportAssetSpeed: true, // 静态资源测速
        spa: true, // spa 页面需要开启，页面切换的时候上报pv
      });
    }
  }

  /**
   * install 挂载vue上
   *
   * @param {any} app Vue 实例
   */
  public install(app:any) {
    app.config.globalProperties.$TUIAegis = TUIAegis.getInstance();
  }

  static getInstance() {
    if (!TUIAegis.instance) {
      TUIAegis.instance = new TUIAegis();
    }
    return TUIAegis.instance;
  }

  /**
   * setAegisOptions 设置上报公共参数
   *
   * @param {any} options 公共参数
   */
  public setAegisOptions(options:any) {
    this.options = options;
  }

  /**
   * reportEvent 上报事件
   *
   * @param {any} options 上报的内容
   * @returns {reportEvent}
   */
  public reportEvent(options:any) {
    return this.aegis.reportEvent({ ...options, ...this.options });
  }
}

export default TUIAegis;
