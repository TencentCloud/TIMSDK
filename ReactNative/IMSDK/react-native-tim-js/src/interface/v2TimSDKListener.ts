/**
 * @module interface
 */
import type { V2TimUserFullInfo } from './v2TimUserFullInfo';
import type { V2TimUserStatus } from './v2TimUserStatus';

export interface V2TimSDKListener {
    onConnecting: () => void;
    onConnectSuccess: () => void;
    onConnectFailed: (code: number, error: string) => void;
    onKickedOffline: () => void;
    onUserSigExpired: () => void;
    onSelfInfoUpdated: (info: V2TimUserFullInfo) => void;
    onUserStatusChanged: (userStatusList: V2TimUserStatus[]) => void;
}
