import { util } from '@kit.ArkTS';

export default abstract class CommonData {
  private _ID = "";

  public get ID() {
    return this._ID;
  }

  public set ID(value) {
    this._ID = value;
  }

  getKey() {
    // 基于 UUID + ID + 对象状态哈希生成键值
    const stateHash = this.getStateHash();
    return this._ID + stateHash;
  }

  // 获取对象状态哈希，任何属性变化都会产生不同的哈希值
  protected getStateHash(): string {
    try {
      // 将整个对象序列化，这样任何属性变化都会引起键值变化
      const jsonStr = JSON.stringify(this);
      let hash = 0;
      for (let i = 0; i < jsonStr.length; i++) {
        const char = jsonStr.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // 转换为32位整数
      }
      return hash.toString();
    } catch (e) {
      // 如果JSON序列化失败，返回时间戳作为后备
      return Date.now().toString();
    }
  }
}