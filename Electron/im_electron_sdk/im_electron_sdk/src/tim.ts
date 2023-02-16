import { CONSOLETAG } from "./const/const";
import Imsdklib from "./imsdk-lib";
import { initConfig, sdkconfig } from "./interface";
import AdvanceMessageManage from "./manager/advanceMessageManager";
import ConversationManager from "./manager/conversationManager";
import FriendshipManager from "./manager/friendshipManager";
import GroupManager from "./manager/groupManager";
import TimbaseManager from "./manager/timbaseManager";

class TIM {
    private _sdkconfig: sdkconfig = {
        sdkappid: 0,
        consoleTag: CONSOLETAG,
        Imsdklib: Imsdklib,
    };
    private _advanceMessageManager: AdvanceMessageManage;
    private _conversationManager: ConversationManager;
    private _friendshipManager: FriendshipManager;
    private _groupManager: GroupManager;
    private _timbaseManager: TimbaseManager;

    constructor(config: initConfig) {
        this._sdkconfig.sdkappid = config.sdkappid;
        this._advanceMessageManager = new AdvanceMessageManage(this._sdkconfig);
        this._conversationManager = new ConversationManager(this._sdkconfig);
        this._friendshipManager = new FriendshipManager(this._sdkconfig);
        this._groupManager = new GroupManager(this._sdkconfig);
        this._timbaseManager = new TimbaseManager(this._sdkconfig);
    }
    getTimbaseManager() {
        return this._timbaseManager;
    }
    getAdvanceMessageManager() {
        return this._advanceMessageManager;
    }
    getConversationManager() {
        return this._conversationManager;
    }
    getFriendshipManager() {
        return this._friendshipManager;
    }
    getGroupManager() {
        return this._groupManager;
    }
    setSDKAPPID(sdkappid: number) {
        this._sdkconfig.sdkappid = sdkappid;
    }
}
export default TIM;
