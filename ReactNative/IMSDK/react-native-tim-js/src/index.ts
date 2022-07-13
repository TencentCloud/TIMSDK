import { NativeModules } from 'react-native';
import { V2TIMManager } from './manager/v2_tim_manager';
export * from './enum'

const TimJSModule = NativeModules.TimJs;

export class TencentImSDKPlugin {
    static v2TIMManager: V2TIMManager = new V2TIMManager(TimJSModule);
}
