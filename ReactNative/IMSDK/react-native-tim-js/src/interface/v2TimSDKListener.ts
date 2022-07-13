/**
 * @module interface
 */
import type V2TimUserFullInfo from './v2TimUserFullInfo';
import type V2TimUserStatus from './v2TimUserStatus';

interface V2TimSDKListener {
    onConnecting: () => void;
    onConnectSuccess: () => void;
    onConnectFailed: (code: number, error: String) => void;
    onKickedOffline: () => void;
    onUserSigExpired: () => void;
    onSelfInfoUpdated: (info: V2TimUserFullInfo) => void;
    onUserStatusChanged: (userStatusList: V2TimUserStatus[]) => void;
}

export default V2TimSDKListener;
