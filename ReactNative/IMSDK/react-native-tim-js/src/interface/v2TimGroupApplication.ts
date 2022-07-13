/**
 * @module interface
 */
interface V2TimGroupApplication {
    groupID: String;
    fromUser?: String;
    fromUserNickName?: String;
    fromUserFaceUrl?: String;
    toUser?: String;
    addTime?: number;
    requestMsg?: String;
    handleMsg?: String;
    typeƒ: number;
    handleStatus: number;
    handleResult: number;
}

export default V2TimGroupApplication;
