import { TUIStoreType } from '../type';

import ITUIStore from '../interfaces/ITUIStore';

export default class TUIStore extends ITUIStore {
  public store: TUIStoreType;
  private storeListener: any;
  constructor() {
    super();
    this.storeListener = {
      keys: [],
      // eslint-disable-next-line @typescript-eslint/no-empty-function
      callback: () => {},
    };
    this.store = {};
    const commonStore = {};
    this.store.common = new Proxy(commonStore, {
      get: (target:any, name:string) => target[name],
      set: (target:any, name:string, value:any) => {
        const oldValue:TUIStoreType = {};
        Object.assign(oldValue, target);
        // eslint-disable-next-line no-param-reassign
        target[name] = value;
        if (target[name] !== oldValue[name] && this.storeListener.keys.indexOf(name) >= 0) {
          this.storeListener.callback(target[name], oldValue[name]);
        }
        return target[name];
      },
    });
  }

  /**
   * 设置全局数据
   *
   * @param {any} store 设置全局的数据
   * @returns {proxy} 设置完成的数据
   */
  public setCommonStore(store: any) {
    Object.keys(store).forEach((key: string) => {
      if (key in this.store.common) {
        return new Error(`${key} 在公共数据已存在，请重新设置`);
      }
      this.store.common[key] = store[key];
    });
    return this.store;
  }


  /**
   * 挂载组件数据
   *
   * @param {string} TUIName 模块名
   * @param {any} store 挂载的数据
   * @param {callback} updateCallback 更新数据 callback
   * @returns {proxy} 挂载完成的模块数据
   */
  public setComponentStore(TUIName:string, store: any, updateCallback?: any) {
    if (TUIName in this.store) {
      return new Error(`${TUIName} 该数据模块已存在，请重新设置`);
    }
    return this.store[TUIName] = new Proxy(store, {
      get: (target:any, name:string) => target[name],
      set: (target:any, name:string, value:any) => {
        const oldValue:TUIStoreType = {};
        Object.assign(oldValue, target);
        // eslint-disable-next-line no-param-reassign
        target[name] = value;
        if (target[name] !== oldValue[name]) {
          updateCallback && updateCallback(target, oldValue);
        }
        return target;
      },
    });
  }

  /**
   * 监听全局数据
   *
   * @param {Array} keys 需要监听的数据key
   * @param {callback} callback 数据变化回调
   */
  public storeCommonListener(keys:Array<string>, callback: any) {
    this.storeListener = {
      keys,
      callback,
    };
  }
}
