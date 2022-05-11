/* eslint-disable @typescript-eslint/no-empty-function */
/**
   * class IComponentServer
   *
   * IComponentServer 组件 server 基类
   */
export default class IComponentServer {
  /**
     * 组件销毁
     */
  public destroyed() {}

  /**
     * 数据监听回调
     *
     * @param {any} oldValue 旧数据
     * @param {any} newValue 新数据
     */
  protected updateStore(oldValue:any, newValue:any) {}
}
