/**
 * @module interface
 */
import type { StringMap } from './commonInterface';

export interface V2TimUserFullInfo {
    userID?: string;
    nickName?: string;
    faceUrl?: string;
    selfSignature?: string;
    gender?: number;
    allowType?: number;
    customInfo?: StringMap;
    role?: number;
    level?: number;
    birthday?: number;
}
