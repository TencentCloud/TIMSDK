import { ipcRenderer } from 'electron';
import eventEmiter from './event';


export const eventListiner = {
    init: () => {
        ipcRenderer.on('pass-call-data', (event, data) => {
            eventEmiter.emit('getData', JSON.parse(data));
        });

        ipcRenderer.on('exit-room', () => {
            eventEmiter.emit('exitRoom');
        });

        ipcRenderer.on('update-invite-list', (event, data) => {
            eventEmiter.emit('updateInviteList', data);
        });
    },
    remoteUserJoin: userId => {
        ipcRenderer.send('remote-user-join', userId)
    },
    remoteUserExit: userId => {
        ipcRenderer.send('remote-user-exit', userId)
    },
    acceptCall: (acceptParams) => {
        ipcRenderer.send('change-window-size', acceptParams);
        eventEmiter.emit('changeWindowType', 'callWindow');
    },
    onEnterRoom: (inviteID) => {
        ipcRenderer.send('accept-call', inviteID);
    },
    refuseCall: (inviteID) => {
        ipcRenderer.send('refuse-call', inviteID);
    },
    cancelCall: (inviteId, realCallTime) => {
        ipcRenderer.send('cancel-call-invite', {inviteId, realCallTime});
    },
}
