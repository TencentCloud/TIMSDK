/**
 * @module interface
 */
import type { StringMap } from './commonInterface';

interface V2TimUserFullInfo {
    userID?: String;
    nickName?: String;
    faceUrl?: String;
    selfSignature?: String;
    gender?: number;
    allowType?: number;
    customInfo?: StringMap;
    role?: number;
    level?: number;
    birthday?: number;
}

export default V2TimUserFullInfo;
