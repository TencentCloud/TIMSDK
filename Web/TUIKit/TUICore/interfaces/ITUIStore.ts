/* eslint-disable @typescript-eslint/no-empty-function */
export default class ITUIStore {
  /**
   * 设置公共数据
   *
   * @param {any} store  设置全局的数据
   */
  public setCommonStore(store: any) {}

  /**
   * 挂载组件数据
   *
   * @param {string} TUIName 模块名
   * @param {any} store 挂载的数据
   * @param {callback} updateCallback 更新数据 callback
   */
  public setComponentStore(TUIName:string, store: any, updateCallback?: any) {}

  /**
   * 监听全局数据
   *
   * @param {Array} keys 需要监听的数据key
   * @param {callback} callback 数据变化回调
   */
  public storeCommonListener(keys:Array<string>, callback: any) {}
}
