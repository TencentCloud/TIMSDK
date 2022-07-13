/**
 * @module interface
 */
import type V2TimCustomElem from './v2TimCustomElem';
import type V2TimFaceElem from './v2TimFaceElem';
import type V2TimFileElem from './v2TimFileElem';
import type V2TimGroupTipsElem from './v2TimGroupTipsElem';
import type V2TimImageElem from './v2TimImageElem';
import type V2TimLocationElem from './v2TimLocationElem';
import type V2TimMergerElem from './v2TimMergerElem';
import type V2TimOfflinePushInfo from './v2TimOfflinePushInfo';
import type V2TimSoundElem from './v2TimSoundElem';
import type V2TimTextElem from './v2TimTextElem';
import type V2TimVideoElem from './v2TimVideoElem';

interface V2TimMessage {
    msgID?: String;
    timestamp?: number;
    progress?: number;
    sender?: String;
    nickName?: String;
    friendRemark?: String;
    faceUrl?: String;
    nameCard?: String;
    groupID?: String;
    userID?: String;
    status?: number;
    elemType?: number;
    textElem?: V2TimTextElem;
    customElem?: V2TimCustomElem;
    imageElem?: V2TimImageElem;
    soundElem?: V2TimSoundElem;
    videoElem?: V2TimVideoElem;
    fileElem?: V2TimFileElem;
    locationElem?: V2TimLocationElem;
    faceElem?: V2TimFaceElem;
    groupTipsElem?: V2TimGroupTipsElem;
    mergerElem?: V2TimMergerElem;
    localCustomData?: String;
    localCustomInt?: number;
    cloudCustomData?: String;
    isSelf?: boolean;
    isRead?: boolean;
    isPeerRead?: boolean;
    priority?: number;
    offlinePushInfo?: V2TimOfflinePushInfo;
    groupAtUserList?: String[];
    seq?: String;
    random?: number;
    isExcludedFromUnreadCount?: boolean;
    isExcludedFromLastMessage?: boolean;
    id?: String;
    needReadReceipt?: boolean;
}

export default V2TimMessage;
