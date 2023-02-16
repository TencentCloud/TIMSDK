import { ipcRenderer } from 'electron';
import { OPEN_CALL_WINDOW, CALL_WINDOW_CLOSE_REPLY, CLOSE_CALL_WINDOW, END_CALL_WINDOW } from "../../app/const/const";

const openCallWindow = (data) => {
    ipcRenderer.send(OPEN_CALL_WINDOW, data);
}

const closeCallWindow = () => {
    ipcRenderer.send(CLOSE_CALL_WINDOW);
};

const callWindowCloseListiner = (callback) => {
    ipcRenderer.on(CALL_WINDOW_CLOSE_REPLY, () => {
        // setTimeout(() => {
            callback();
        // }, 0);
    });
};

const acceptCallListiner = (callback) => {
    ipcRenderer.on('accept-call-reply', (event,inviteID) => {
        console.log('接受通话',inviteID);
        callback(inviteID);
    })
};

const refuseCallListiner = (callback) => {
    ipcRenderer.on('refuse-call-reply', (event,inviteID) => {
        console.log('拒绝通话');
        callback(inviteID);
    })
}

const remoteUserJoin = callback => {
    ipcRenderer.on('remote-user-join-reply', (event, userId) => {
        console.log('远端用户加入', userId);
        callback(userId);
    })
}

const remoteUserExit = callback => {
    ipcRenderer.on('remote-user-exit-reply', (event, userId) => {
        console.log('远端用户退出', userId);
        callback(userId);
    })
}

const cancelCallInvite = callback => {
    ipcRenderer.on('cancel-call-invite-reply', (event, data) => {
        console.log('取消邀请', data);
        callback(data);
    });
}

const endCallWindow = ()=>{
    ipcRenderer.send(END_CALL_WINDOW);
}

const updateInviteList = (data) => {
    console.warn('===========update invite list============', data);
    ipcRenderer.send('update-invite-list', data);
}

export {
    openCallWindow,
    closeCallWindow,
    callWindowCloseListiner,
    acceptCallListiner,
    refuseCallListiner,
    remoteUserJoin,
    remoteUserExit,
    endCallWindow,
    cancelCallInvite,
    updateInviteList
}