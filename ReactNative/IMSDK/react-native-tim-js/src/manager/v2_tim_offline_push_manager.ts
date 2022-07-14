/**
 * 离线推送
 * @module OfflinePushManager(高级消息收发接口)
 */
import type { V2TimCallback } from '../interface/v2TimCallback';

export class V2TIMOfflinePushManager {
    private nativeModule: any;
    private manager: string = 'offlinePushManager';

    /** @hidden */
    constructor(module: any) {
        this.nativeModule = module;
    }

    /**
     * ### 设置离线推送配置信息
     */
    public setOfflinePushConfig(
        businessID: number,
        token: string,
        isTPNSToken = false
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setOfflinePushConfig', {
            businessID,
            token,
            isTPNSToken,
        });
    }

    /**
     * APP 检测到应用退后台时可以调用此接口，可以用作桌面应用角标的初始化未读数量。
     * @param unreadCount 未读数量
     * @note
     * APP 检测到应用退后台时可以调用此接口，可以用作桌面应用角标的初始化未读数量。
     */
    public doBackground(unreadCount: number): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'doBackground', {
            unreadCount,
        });
    }

    /**
     * APP 检测到应用进前台时可以调用此接口
     */
    public doForeground(): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'doForeground', {});
    }
}
