export const EVENT = {
  INVITED: 'INVITED',
  GROUP_CALL_INVITEE_LIST_UPDATE: 'GROUP_CALL_INVITEE_LIST_UPDATE',
  USER_ENTER: 'USER_ENTER',
  USER_LEAVE: 'USER_LEAVE',
  USER_ACCEPT: 'USER_ACCEPT',
  USER_UPDATE: 'USER_UPDATE',
  REJECT: 'REJECT',
  NO_RESP: 'NO_RESP',
  LINE_BUSY: 'LINE_BUSY',
  CALLING_CANCEL: 'CALLING_CANCEL',
  CALLING_TIMEOUT: 'CALLING_TIMEOUT',
  CALL_END: 'CALL_END',
  USER_VIDEO_AVAILABLE: 'USER_VIDEO_AVAILABLE',
  USER_AUDIO_AVAILABLE: 'USER_AUDIO_AVAILABLE',
  USER_VOICE_VOLUME: 'USER_VOICE_VOLUME',
  SDK_READY: 'SDK_READY',
  KICKED_OUT: 'KICKED_OUT',
  CALL_MODE: 'CALL_MODE',

  HANG_UP: 'HANG_UP',
  ERROR: 'ERROR', // 组件内部抛出的错误
};

export const CALL_STATUS = {
  IDLE: 'idle',
  CALLING: 'calling',
  CONNECTED: 'connected',
};

export const ACTION_TYPE = {
  INVITE: 1, // 邀请方发起邀请
  CANCEL_INVITE: 2, // 邀请方取消邀请
  ACCEPT_INVITE: 3, // 被邀请方同意邀请
  REJECT_INVITE: 4, // 被邀请方拒绝邀请
  INVITE_TIMEOUT: 5, // 被邀请方超时未回复
};

export const BUSINESS_ID = {
  SIGNAL: 1, // 信令
};

export const CALL_TYPE = {
  AUDIO: 1,
  VIDEO: 2,
};

export const CMD_TYPE_LIST = ['', 'audioCall', 'videoCall'];

// audio视频切音频；video：音频切视频
export const MODE_TYPE = {
  AUDIO: 'audio',
  VIDEO: 'video',
};
