/**
 * @module interface
 */
interface V2TimFriendApplication {
    userID: String;
    nickName?: String;
    faceUrl?: String;
    addTime?: number;
    addSource?: String;
    addWording?: String;
    type: number;
}

export default V2TimFriendApplication;
