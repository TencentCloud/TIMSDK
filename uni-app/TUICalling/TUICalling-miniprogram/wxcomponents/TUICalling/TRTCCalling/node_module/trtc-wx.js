!(function (e, t) {
  'object' === typeof exports && 'undefined' !== typeof module ? module.exports = t() : 'function' === typeof define && define.amd ? define(t) : (e = 'undefined' !== typeof globalThis ? globalThis : e || self).TRTC = t();
}(this, (() => {
  'use strict';function e(e, t) {
    if (!(e instanceof t)) throw new TypeError('Cannot call a class as a function');
  } function t(e, t) {
    for (let r = 0;r < t.length;r++) {
      const s = t[r];s.enumerable = s.enumerable || !1, s.configurable = !0, 'value' in s && (s.writable = !0), Object.defineProperty(e, s.key, s);
    }
  } function r(e, r, s) {
    return r && t(e.prototype, r), s && t(e, s), e;
  } function s(e, t, r) {
    return t in e ? Object.defineProperty(e, t, { value: r, enumerable: !0, configurable: !0, writable: !0 }) : e[t] = r, e;
  } function i(e, t) {
    const r = Object.keys(e);if (Object.getOwnPropertySymbols) {
      let s = Object.getOwnPropertySymbols(e);t && (s = s.filter((t => Object.getOwnPropertyDescriptor(e, t).enumerable))), r.push.apply(r, s);
    } return r;
  } function a(e) {
    for (let t = 1;t < arguments.length;t++) {
      var r = null != arguments[t] ? arguments[t] : {};t % 2 ? i(Object(r), !0).forEach(((t) => {
        s(e, t, r[t]);
      })) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(r)) : i(Object(r)).forEach(((t) => {
        Object.defineProperty(e, t, Object.getOwnPropertyDescriptor(r, t));
      }));
    } return e;
  } function n() {
    const e = (new Date).getTime(); const t = new Date(e); let r = t.getHours(); let s = t.getMinutes(); let i = t.getSeconds(); const a = t.getMilliseconds();return r = r < 10 ? '0'.concat(r) : r, s = s < 10 ? '0'.concat(s) : s, i = i < 10 ? '0'.concat(i) : i, ''.concat(r, ':').concat(s, ':')
      .concat(i, '.')
      .concat(a);
  } const o = 'TRTC-WX'; const u = 0; const c = 1; const l = new (function () {
    function t() {
      e(this, t), this.logLevel = 0;
    } return r(t, [{ key: 'setLogLevel', value(e) {
      this.logLevel = e;
    } }, { key: 'log', value() {
      let e;this.logLevel === u && (e = console).log.apply(e, [o, n()].concat(Array.prototype.slice.call(arguments)));
    } }, { key: 'warn', value() {
      let e;this.logLevel <= c && (e = console).warn.apply(e, [o, n()].concat(Array.prototype.slice.call(arguments)));
    } }, { key: 'error', value() {
      let e;(e = console).error.apply(e, [o, n()].concat(Array.prototype.slice.call(arguments)));
    } }]), t;
  }());const h = function (e) {
    const t = /[\u4e00-\u9fa5]/;return e.sdkAppID ? void 0 === e.roomID && void 0 === e.strRoomID ? (l.error('未设置 roomID'), !1) : !e.strRoomID && (e.roomID < 1 || e.roomID > 4294967296) ? (l.error('roomID 超出取值范围 1 ~ 4294967295'), !1) : e.strRoomID && t.test(e.strRoomID) ? (l.error('strRoomID 请勿使用中文字符'), !1) : e.userID ? e.userID && t.test(e.userID) ? (l.error('userID 请勿使用中文字符'), !1) : !!e.userSig || (l.error('未设置 userSig'), !1) : (l.error('未设置 userID'), !1) : (l.error('未设置 sdkAppID'), !1);
  }; const p = { LOCAL_JOIN: 'LOCAL_JOIN', LOCAL_LEAVE: 'LOCAL_LEAVE', KICKED_OUT: 'KICKED_OUT', REMOTE_USER_JOIN: 'REMOTE_USER_JOIN', REMOTE_USER_LEAVE: 'REMOTE_USER_LEAVE', REMOTE_VIDEO_ADD: 'REMOTE_VIDEO_ADD', REMOTE_VIDEO_REMOVE: 'REMOTE_VIDEO_REMOVE', REMOTE_AUDIO_ADD: 'REMOTE_AUDIO_ADD', REMOTE_AUDIO_REMOVE: 'REMOTE_AUDIO_REMOVE', REMOTE_STATE_UPDATE: 'REMOTE_STATE_UPDATE', LOCAL_NET_STATE_UPDATE: 'LOCAL_NET_STATE_UPDATE', REMOTE_NET_STATE_UPDATE: 'REMOTE_NET_STATE_UPDATE', LOCAL_AUDIO_VOLUME_UPDATE: 'LOCAL_AUDIO_VOLUME_UPDATE', REMOTE_AUDIO_VOLUME_UPDATE: 'REMOTE_AUDIO_VOLUME_UPDATE', VIDEO_FULLSCREEN_UPDATE: 'VIDEO_FULLSCREEN_UPDATE', BGM_PLAY_START: 'BGM_PLAY_START', BGM_PLAY_FAIL: 'BGM_PLAY_FAIL', BGM_PLAY_PROGRESS: 'BGM_PLAY_PROGRESS', BGM_PLAY_COMPLETE: 'BGM_PLAY_COMPLETE', ERROR: 'ERROR', IM_READY: 'IM_READY', IM_MESSAGE_RECEIVED: 'IM_MESSAGE_RECEIVED', IM_NOT_READY: 'IM_NOT_READY', IM_KICKED_OUT: 'IM_KICKED_OUT', IM_ERROR: 'IM_ERROR' }; const m = { url: '', mode: 'RTC', autopush: !1, enableCamera: !1, enableMic: !1, enableAgc: !1, enableAns: !1, enableEarMonitor: !1, enableAutoFocus: !0, enableZoom: !1, minBitrate: 600, maxBitrate: 900, videoWidth: 360, videoHeight: 640, beautyLevel: 0, whitenessLevel: 0, videoOrientation: 'vertical', videoAspect: '9:16', frontCamera: 'front', enableRemoteMirror: !1, localMirror: 'auto', enableBackgroundMute: !1, audioQuality: 'high', audioVolumeType: 'voicecall', audioReverbType: 0, waitingImage: 'https://mc.qcloudimg.com/static/img/daeed8616ac5df256c0591c22a65c4d3/pause_publish.jpg', waitingImageHash: '', beautyStyle: 'smooth', filter: '', netStatus: {} }; const f = { src: '', mode: 'RTC', autoplay: !0, muteAudio: !0, muteVideo: !0, orientation: 'vertical', objectFit: 'fillCrop', enableBackgroundMute: !1, minCache: 1, maxCache: 2, soundMode: 'speaker', enableRecvMessage: !1, autoPauseIfNavigate: !0, autoPauseIfOpenNative: !0, isVisible: !0, _definitionType: 'main', netStatus: {} };(new Date).getTime();function d() {
    const e = new Date;return e.setTime((new Date).getTime() + 0), e.toLocaleString();
  } function v(e) {
    const t = this; let r = []; let s = [];this.length = function () {
      return r.length;
    }, this.sent = function () {
      return s.length;
    }, this.push = function (t) {
      r.push(t), r.length > e && r.shift();
    }, this.send = function () {
      return s.length || (s = r, r = []), s;
    }, this.confirm = function () {
      s = [], t.content = '';
    }, this.fail = function () {
      r = s.concat(r), t.confirm();const i = 1 + r.length + s.length - e;i > 0 && (s.splice(0, i), r = s.concat(r), t.confirm());
    };
  } const g = new (function () {
    function t() {
      e(this, t), this.sdkAppId = '', this.userId = '', this.version = '', this.queue = new v(20);
    } return r(t, [{ key: 'setConfig', value(e) {
      this.sdkAppId = ''.concat(e.sdkAppId), this.userId = ''.concat(e.userId), this.version = ''.concat(e.version);
    } }, { key: 'push', value(e) {
      this.queue.push(e);
    } }, { key: 'log', value(e) {
      uni.request({ url: 'https://yun.tim.qq.com/v5/AVQualityReportSvc/C2S?sdkappid=1&cmdtype=jssdk_log', method: 'POST', header: { 'content-type': 'application/json' }, data: { timestamp: d(), sdkAppId: this.sdkAppId, userId: this.userId, version: this.version, log: e } });
    } }, { key: 'send', value() {
      const e = this;if (!this.queue.sent()) {
        if (!this.queue.length()) return;const t = this.queue.send();this.queue.content = 'string' !== typeof log ? '{"logs":['.concat(t.join(','), ']}') : t.join('\n'), uni.request({ url: 'https://yun.tim.qq.com/v5/AVQualityReportSvc/C2S?sdkappid=1&cmdtype=jssdk_log', method: 'POST', header: { 'content-type': 'application/json' }, data: { timestamp: d(), sdkAppId: this.sdkAppId, userId: this.userId, version: this.version, log: this.queue.content }, success() {
          e.queue.confirm();
        }, fail() {
          e.queue.fail();
        } });
      }
    } }]), t;
  }()); const y = (function () {
    function t(r, s) {
      e(this, t), this.context = uni.createLivePusherContext(s), this.pusherAttributes = {}, Object.assign(this.pusherAttributes, m, r);
    } return r(t, [{ key: 'setPusherAttributes', value(e) {
      return Object.assign(this.pusherAttributes, e), this.pusherAttributes;
    } }, { key: 'start', value(e) {
      l.log('[apiLog][pusherStart]'), g.log('pusherStart'), this.context.start(e);
    } }, { key: 'stop', value(e) {
      l.log('[apiLog][pusherStop]'), g.log('pusherStop'), this.context.stop(e);
    } }, { key: 'pause', value(e) {
      l.log('[apiLog] pusherPause()'), g.log('pusherPause'), this.context.pause(e);
    } }, { key: 'resume', value(e) {
      l.log('[apiLog][pusherResume]'), g.log('pusherResume'), this.context.resume(e);
    } }, { key: 'switchCamera', value(e) {
      return l.log('[apiLog][switchCamera]'), this.pusherAttributes.frontCamera = 'front' === this.pusherAttributes.frontCamera ? 'back' : 'front', this.context.switchCamera(e), this.pusherAttributes;
    } }, { key: 'sendMessage', value(e) {
      l.log('[apiLog][sendMessage]', e.msg), this.context.sendMessage(e);
    } }, { key: 'snapshot', value() {
      const e = this;return l.log('[apiLog][pusherSnapshot]'), new Promise(((t, r) => {
        e.context.snapshot({ quality: 'raw', complete(e) {
          e.tempImagePath ? (uni.saveImageToPhotosAlbum({ filePath: e.tempImagePath, success(r) {
            t(e);
          }, fail(e) {
            l.error('[error] pusher截图失败: ', e), r(new Error('截图失败'));
          } }), t(e)) : (l.error('[error] snapShot 回调失败', e), r(new Error('截图失败')));
        } });
      }));
    } }, { key: 'toggleTorch', value(e) {
      this.context.toggleTorch(e);
    } }, { key: 'startDumpAudio', value(e) {
      this.context.startDumpAudio(e);
    } }, { key: 'stopDumpAudio', value(e) {
      this.context.startDumpAudio(e);
    } }, { key: 'playBGM', value(e) {
      l.log('[apiLog] playBGM() url: ', e.url), this.context.playBGM(e);
    } }, { key: 'pauseBGM', value(e) {
      l.log('[apiLog] pauseBGM()'), this.context.pauseBGM(e);
    } }, { key: 'resumeBGM', value(e) {
      l.log('[apiLog] resumeBGM()'), this.context.resumeBGM(e);
    } }, { key: 'stopBGM', value(e) {
      l.log('[apiLog] stopBGM()'), this.context.stopBGM(e);
    } }, { key: 'setBGMVolume', value(e) {
      l.log('[apiLog] setBGMVolume() volume:', e.volume), this.context.setBGMVolume(e.volume);
    } }, { key: 'setMICVolume', value(e) {
      l.log('[apiLog] setMICVolume() volume:', e.volume), this.context.setMICVolume(e.volume);
    } }, { key: 'startPreview', value(e) {
      l.log('[apiLog] startPreview()'), this.context.startPreview(e);
    } }, { key: 'stopPreview', value(e) {
      l.log('[apiLog] stopPreview()'), this.context.stopPreview(e);
    } }, { key: 'reset', value() {
      return console.log('Pusher reset', this.context), this.pusherConfig = {}, this.context && (this.stop({ success() {
        console.log('Pusher context.stop()');
      } }), this.context = null), this.pusherAttributes;
    } }]), t;
  }()); const E = function t(r) {
    e(this, t), Object.assign(this, { userID: '', streams: {} }, r);
  }; const A = (function () {
    function t(r, s) {
      e(this, t), this.ctx = s, this.playerAttributes = {}, Object.assign(this.playerAttributes, f, { userID: '', streamType: '', streamID: '', id: '', hasVideo: !1, hasAudio: !1, volume: 0, playerContext: void 0 }, r);
    } return r(t, [{ key: 'play', value(e) {
      this.getPlayerContext().play(e);
    } }, { key: 'stop', value(e) {
      this.getPlayerContext().stop(e);
    } }, { key: 'mute', value(e) {
      this.getPlayerContext().mute(e);
    } }, { key: 'pause', value(e) {
      this.getPlayerContext().pause(e);
    } }, { key: 'resume', value(e) {
      this.getPlayerContext().resume(e);
    } }, { key: 'requestFullScreen', value(e) {
      const t = this;return new Promise(((r, s) => {
        t.getPlayerContext().requestFullScreen({ direction: e.direction, success(e) {
          r(e);
        }, fail(e) {
          s(e);
        } });
      }));
    } }, { key: 'requestExitFullScreen', value() {
      const e = this;return new Promise(((t, r) => {
        e.getPlayerContext().exitFullScreen({ success(e) {
          t(e);
        }, fail(e) {
          r(e);
        } });
      }));
    } }, { key: 'snapshot', value(e) {
      const t = this;return l.log('[playerSnapshot]', e), new Promise(((e, r) => {
        t.getPlayerContext().snapshot({ quality: 'raw', complete(t) {
          t.tempImagePath ? (uni.saveImageToPhotosAlbum({ filePath: t.tempImagePath, success(r) {
            l.log('save photo is success', r), e(t);
          }, fail(e) {
            l.error('save photo is fail', e), r(e);
          } }), e(t)) : (l.error('snapShot 回调失败', t), r(new Error('截图失败')));
        } });
      }));
    } }, { key: 'setPlayerAttributes', value(e) {
      Object.assign(this.playerAttributes, e);
    } }, { key: 'getPlayerContext', value() {
      return this.playerContext || (this.playerContext = uni.createLivePlayerContext(this.playerAttributes.id, this.ctx)), this.playerContext;
    } }, { key: 'reset', value() {
      this.playerContext && (this.playerContext.stop(), this.playerContext = void 0), Object.assign(this.playerAttributes, f, { userID: '', streamType: '', streamID: '', hasVideo: !1, hasAudio: !1, volume: 0, playerContext: void 0 });
    } }]), t;
  }()); const _ = 'UserController'; const I = (function () {
    function t(r, s) {
      e(this, t), this.ctx = s, this.userMap = new Map, this.userList = [], this.streamList = [], this.emitter = r;
    } return r(t, [{ key: 'userEventHandler', value(e) {
      const t = e.detail.code; const r = e.detail.message;switch (t) {
        case 0:l.log(r, t);break;case 1001:l.log('已经连接推流服务器', t);break;case 1002:l.log('已经与服务器握手完毕,开始推流', t);break;case 1003:l.log('打开摄像头成功', t);break;case 1004:l.log('录屏启动成功', t);break;case 1005:l.log('推流动态调整分辨率', t);break;case 1006:l.log('推流动态调整码率', t);break;case 1007:l.log('首帧画面采集完成', t);break;case 1008:l.log('编码器启动', t);break;case 1018:l.log('进房成功', t), g.log('event enterRoom success '.concat(t)), this.emitter.emit(p.LOCAL_JOIN);break;case 1019:l.log('退出房间', t), r.indexOf('reason[0]') > -1 ? g.log('event exitRoom '.concat(t)) : (g.log('event abnormal exitRoom '.concat(r)), this.emitter.emit(p.KICKED_OUT));break;case 2003:l.log('渲染首帧视频', t);break;case -1301:l.error('打开摄像头失败: ', t), g.log('event start camera failed: '.concat(t)), this.emitter.emit(p.ERROR, { code: t, message: r });break;case -1302:l.error('打开麦克风失败: ', t), g.log('event start microphone failed: '.concat(t)), this.emitter.emit(p.ERROR, { code: t, message: r });break;case -1303:l.error('视频编码失败: ', t), g.log('event video encode failed: '.concat(t)), this.emitter.emit(p.ERROR, { code: t, message: r });break;case -1304:l.error('音频编码失败: ', t), g.log('event audio encode failed: '.concat(t)), this.emitter.emit(p.ERROR, { code: t, message: r });break;case -1307:l.error('推流连接断开: ', t), this.emitter.emit(p.ERROR, { code: t, message: r });break;case -100018:l.error('进房失败: userSig 校验失败，请检查 userSig 是否填写正确', t, r), this.emitter.emit(p.ERROR, { code: t, message: r });break;case 5e3:l.log('小程序被挂起: ', t), g.log('小程序被挂起: 5000');break;case 5001:l.log('小程序悬浮窗被关闭: ', t);break;case 1021:l.log('网络类型发生变化，需要重新进房', t);break;case 2007:l.log('本地视频播放loading: ', t);break;case 2004:l.log('本地视频播放开始: ', t);break;case 1031:case 1032:case 1033:case 1034:this._handleUserEvent(e);
      }
    } }, { key: '_handleUserEvent', value(e) {
      let t; const r = e.detail.code; const s = e.detail.message;if (!e.detail.message || 'string' !== typeof s) return l.warn(_, 'userEventHandler 数据格式错误'), !1;try {
        t = JSON.parse(e.detail.message);
      } catch (e) {
        return l.warn(_, 'userEventHandler 数据格式错误', e), !1;
      } switch (this.emitter.emit(p.LOCAL_STATE_UPDATE, e), g.log('event code: '.concat(r, ', data: ').concat(JSON.stringify(t))), r) {
        case 1031:this.addUser(t);break;case 1032:this.removeUser(t);break;case 1033:this.updateUserVideo(t);break;case 1034:this.updateUserAudio(t);
      }
    } }, { key: 'addUser', value(e) {
      const t = this;l.log('addUser', e);const r = e.userlist;Array.isArray(r) && r.length > 0 && r.forEach(((e) => {
        const r = e.userid; let s = t.getUser(r);s || (s = new E({ userID: r }), t.userList.push({ userID: r })), t.userMap.set(r, s), t.emitter.emit(p.REMOTE_USER_JOIN, { userID: r, userList: t.userList, playerList: t.getPlayerList() });
      }));
    } }, { key: 'removeUser', value(e) {
      const t = this; const r = e.userlist;Array.isArray(r) && r.length > 0 && r.forEach(((e) => {
        const r = e.userid; let s = t.getUser(r);s && s.streams && (t._removeUserAndStream(r), s.streams.main && s.streams.main.reset(), s.streams.aux && s.streams.aux.reset(), t.emitter.emit(p.REMOTE_USER_LEAVE, { userID: r, userList: t.userList, playerList: t.getPlayerList() }), s = void 0, t.userMap.delete(r));
      }));
    } }, { key: 'updateUserVideo', value(e) {
      const t = this;l.log(_, 'updateUserVideo', e);const r = e.userlist;Array.isArray(r) && r.length > 0 && r.forEach(((e) => {
        const r = e.userid; const s = e.streamtype; const i = ''.concat(r, '_').concat(s); const a = i; const n = e.hasvideo; const o = e.playurl; const u = t.getUser(r);if (u) {
          let c = u.streams[s];l.log(_, 'updateUserVideo start', u, s, c), c ? (c.setPlayerAttributes({ hasVideo: n }), n || c.playerAttributes.hasAudio || t._removeStream(c)) : (c = new A({ userID: r, streamID: i, hasVideo: n, src: o, streamType: s, id: a }, t.ctx), u.streams[s] = c, t._addStream(c)), 'aux' === s && (n ? (c.objectFit = 'contain', t._addStream(c)) : t._removeStream(c)), t.userList.find(((e) => {
            if (e.userID === r) return e['has'.concat(s.replace(/^\S/, (e => e.toUpperCase())), 'Video')] = n, !0;
          })), l.log(_, 'updateUserVideo end', u, s, c);const h = n ? p.REMOTE_VIDEO_ADD : p.REMOTE_VIDEO_REMOVE;t.emitter.emit(h, { player: c.playerAttributes, userList: t.userList, playerList: t.getPlayerList() });
        }
      }));
    } }, { key: 'updateUserAudio', value(e) {
      const t = this; const r = e.userlist;Array.isArray(r) && r.length > 0 && r.forEach(((e) => {
        const r = e.userid; const s = 'main'; const i = ''.concat(r, '_').concat(s); const a = i; const n = e.hasaudio; const o = e.playurl; const u = t.getUser(r);if (u) {
          let c = u.streams.main;c ? (c.setPlayerAttributes({ hasAudio: n }), n || c.playerAttributes.hasVideo || t._removeStream(c)) : (c = new A({ userID: r, streamID: i, hasAudio: n, src: o, streamType: s, id: a }, t.ctx), u.streams.main = c, t._addStream(c)), t.userList.find(((e) => {
            if (e.userID === r) return e['has'.concat(s.replace(/^\S/, (e => e.toUpperCase())), 'Audio')] = n, !0;
          }));const l = n ? p.REMOTE_AUDIO_ADD : p.REMOTE_AUDIO_REMOVE;t.emitter.emit(l, { player: c.playerAttributes, userList: t.userList, playerList: t.getPlayerList() });
        }
      }));
    } }, { key: 'getUser', value(e) {
      return this.userMap.get(e);
    } }, { key: 'getStream', value(e) {
      const t = e.userID; const r = e.streamType; const s = this.userMap.get(t);if (s) return s.streams[r];
    } }, { key: 'getUserList', value() {
      return this.userList;
    } }, { key: 'getStreamList', value() {
      return this.streamList;
    } }, { key: 'getPlayerList', value() {
      for (var e = this.getStreamList(), t = [], r = 0;r < e.length;r++)t.push(e[r].playerAttributes);return t;
    } }, { key: 'reset', value() {
      return this.streamList.forEach(((e) => {
        e.reset();
      })), this.streamList = [], this.userList = [], this.userMap.clear(), { userList: this.userList, streamList: this.streamList };
    } }, { key: '_removeUserAndStream', value(e) {
      this.streamList = this.streamList.filter((t => t.playerAttributes.userID !== e && '' !== t.playerAttributes.userID)), this.userList = this.userList.filter((t => t.userID !== e));
    } }, { key: '_addStream', value(e) {
      this.streamList.includes(e) || this.streamList.push(e);
    } }, { key: '_removeStream', value(e) {
      this.streamList = this.streamList.filter((t => t.playerAttributes.userID !== e.playerAttributes.userID || t.playerAttributes.streamType !== e.playerAttributes.streamType)), this.getUser(e.playerAttributes.userID).streams[e.playerAttributes.streamType] = void 0;
    } }]), t;
  }()); const L = (function () {
    function t() {
      e(this, t);
    } return r(t, [{ key: 'on', value(e, t, r) {
      'function' === typeof t ? (this._stores = this._stores || {}, (this._stores[e] = this._stores[e] || []).push({ cb: t, ctx: r })) : console.error('listener must be a function');
    } }, { key: 'emit', value(e) {
      this._stores = this._stores || {};let t; let r = this._stores[e];if (r) {
        r = r.slice(0), (t = [].slice.call(arguments, 1))[0] = { eventCode: e, data: t[0] };for (let s = 0, i = r.length;s < i;s++)r[s].cb.apply(r[s].ctx, t);
      }
    } }, { key: 'off', value(e, t) {
      if (this._stores = this._stores || {}, arguments.length) {
        const r = this._stores[e];if (r) if (1 !== arguments.length) {
          for (let s = 0, i = r.length;s < i;s++) if (r[s].cb === t) {
            r.splice(s, 1);break;
          }
        } else delete this._stores[e];
      } else this._stores = {};
    } }]), t;
  }());return (function () {
    function t(r, s) {
      const i = this;e(this, t), this.ctx = r, this.eventEmitter = new L, this.pusherInstance = null, this.userController = new I(this.eventEmitter, this.ctx), this.EVENT = p, 'test' !== s ? uni.getSystemInfo({ success(e) {
        return i.systemInfo = e;
      } }) : (g.log = function () {}, l.log = function () {}, l.warn = function () {});
    } return r(t, [{ key: 'on', value(e, t, r) {
      l.log('[on] 事件订阅: '.concat(e)), this.eventEmitter.on(e, t, r);
    } }, { key: 'off', value(e, t) {
      l.log('[off] 取消订阅: '.concat(e)), this.eventEmitter.off(e, t);
    } }, { key: 'createPusher', value(e) {
      return this.pusherInstance = new y(e, this.ctx), console.log('pusherInstance', this.pusherInstance), this.pusherInstance;
    } }, { key: 'getPusherInstance', value() {
      return this.pusherInstance;
    } }, { key: 'enterRoom', value(e) {
      l.log('[apiLog] [enterRoom]', e);const t = (function (e) {
        if (!h(e)) return null;e.scene = e.scene && 'rtc' !== e.scene ? e.scene : 'videocall', e.enableBlackStream = e.enableBlackStream || '', e.encsmall = e.encsmall || 0, e.cloudenv = e.cloudenv || 'PRO', e.streamID = e.streamID || '', e.userDefineRecordID = e.userDefineRecordID || '', e.privateMapKey = e.privateMapKey || '', e.pureAudioMode = e.pureAudioMode || '', e.recvMode = e.recvMode || 1;let t = '';return t = e.strRoomID ? '&strroomid='.concat(e.strRoomID) : '&roomid='.concat(e.roomID), 'room://cloud.tencent.com/rtc?sdkappid='.concat(e.sdkAppID).concat(t, '&userid=')
          .concat(e.userID, '&usersig=')
          .concat(e.userSig, '&appscene=')
          .concat(e.scene, '&encsmall=')
          .concat(e.encsmall, '&cloudenv=')
          .concat(e.cloudenv, '&enableBlackStream=')
          .concat(e.enableBlackStream, '&streamid=')
          .concat(e.streamID, '&userdefinerecordid=')
          .concat(e.userDefineRecordID, '&privatemapkey=')
          .concat(e.privateMapKey, '&pureaudiomode=')
          .concat(e.pureAudioMode, '&recvmode=')
          .concat(e.recvMode);
      }(e));return t || this.eventEmitter.emit(p.ERROR, { message: '进房参数错误' }), g.setConfig({ sdkAppId: e.sdkAppID, userId: e.userID, version: 'wechat-mini' }), this.pusherInstance.setPusherAttributes(a(a({}, e), {}, { url: t })), l.warn('[statusLog] [enterRoom]', this.pusherInstance.pusherAttributes), g.log('api-enterRoom'), g.log('pusherConfig: '.concat(JSON.stringify(this.pusherInstance.pusherAttributes))), this.getPusherAttributes();
    } }, { key: 'exitRoom', value() {
      g.log('api-exitRoom'), this.userController.reset();const e = Object.assign({ pusher: this.pusherInstance.reset() }, { playerList: this.userController.getPlayerList() });return this.eventEmitter.emit(p.LOCAL_LEAVE), e;
    } }, { key: 'getPlayerList', value() {
      const e = this.userController.getPlayerList();return l.log('[apiLog][getStreamList]', e), e;
    } }, { key: 'setPusherAttributes', value(e) {
      return l.log('[apiLog] [setPusherAttributes], ', e), this.pusherInstance.setPusherAttributes(e), l.warn('[statusLog] [setPusherAttributes]', this.pusherInstance.pusherAttributes), g.log('api-setPusherAttributes '.concat(JSON.stringify(e))), this.pusherInstance.pusherAttributes;
    } }, { key: 'getPusherAttributes', value() {
      return l.log('[apiLog] [getPusherConfig]'), this.pusherInstance.pusherAttributes;
    } }, { key: 'setPlayerAttributes', value(e, t) {
      l.log('[apiLog] [setPlayerAttributes] id', e, 'options: ', t);const r = this._transformStreamID(e); const s = r.userID; const i = r.streamType; const a = this.userController.getStream({ userID: s, streamType: i });return a ? (a.setPlayerAttributes(t), g.log('api-setPlayerAttributes id: '.concat(e, ' options: ').concat(JSON.stringify(t))), this.getPlayerList()) : this.getPlayerList();
    } }, { key: 'getPlayerInstance', value(e) {
      const t = this._transformStreamID(e); const r = t.userID; const s = t.streamType;return l.log('[api][getPlayerInstance] id:', e), this.userController.getStream({ userID: r, streamType: s });
    } }, { key: 'switchStreamType', value(e) {
      l.log('[apiLog] [switchStreamType] id: ', e);const t = this._transformStreamID(e); const r = t.userID; const s = t.streamType; const i = this.userController.getStream({ userID: r, streamType: s });return 'main' === i._definitionType ? (i.src = i.src.replace('main', 'small'), i._definitionType = 'small') : (i.src = i.src.replace('small', 'main'), i._definitionType = 'main'), this.getPlayerList();
    } }, { key: 'pusherEventHandler', value(e) {
      this.userController.userEventHandler(e);
    } }, { key: 'pusherNetStatusHandler', value(e) {
      const t = e.detail.info;this.pusherInstance.setPusherAttributes(t), this.eventEmitter.emit(p.LOCAL_NET_STATE_UPDATE, { pusher: this.pusherInstance.pusherAttributes });
    } }, { key: 'pusherErrorHandler', value(e) {
      try {
        const t = e.detail.errCode; const r = e.detail.errMsg;this.eventEmitter.emit(p.ERROR, { code: t, message: r });
      } catch (t) {
        l.error('pusher error data parser exception', e, t);
      }
    } }, { key: 'pusherBGMStartHandler', value(e) {
      this.eventEmitter.emit(p.BGM_PLAY_START);
    } }, { key: 'pusherBGMProgressHandler', value(e) {
      let t; let r; let s; let i;this.eventEmitter.emit(p.BGM_PLAY_PROGRESS, { progress: null === (t = e.data) || void 0 === t || null === (r = t.detail) || void 0 === r ? void 0 : r.progress, duration: null === (s = e.data) || void 0 === s || null === (i = s.detail) || void 0 === i ? void 0 : i.duration });
    } }, { key: 'pusherBGMCompleteHandler', value(e) {
      this.eventEmitter.emit(p.BGM_PLAY_COMPLETE);
    } }, { key: 'pusherAudioVolumeNotify', value(e) {
      this.pusherInstance.pusherAttributes.volume = e.detail.volume, this.eventEmitter.emit(p.LOCAL_AUDIO_VOLUME_UPDATE, { pusher: this.pusherInstance.pusherAttributes });
    } }, { key: 'playerEventHandler', value(e) {
      l.log('[statusLog][playerStateChange]', e), this.eventEmitter.emit(p.REMOTE_STATE_UPDATE, e);
    } }, { key: 'playerFullscreenChange', value(e) {
      this.eventEmitter.emit(p.VIDEO_FULLSCREEN_UPDATE);
    } }, { key: 'playerNetStatus', value(e) {
      const t = this._transformStreamID(e.currentTarget.dataset.streamid); const r = t.userID; const s = t.streamType; const i = this.userController.getStream({ userID: r, streamType: s });!i || i.videoWidth === e.detail.info.videoWidth && i.videoHeight === e.detail.info.videoHeight || (i.setPlayerAttributes({ netStatus: e.detail.info }), this.eventEmitter.emit(p.REMOTE_NET_STATE_UPDATE, { playerList: this.userController.getPlayerList() }));
    } }, { key: 'playerAudioVolumeNotify', value(e) {
      const t = this._transformStreamID(e.currentTarget.dataset.streamid); const r = t.userID; const s = t.streamType; const i = this.userController.getStream({ userID: r, streamType: s }); const a = e.detail.volume;i.setPlayerAttributes({ volume: a }), this.eventEmitter.emit(p.REMOTE_AUDIO_VOLUME_UPDATE, { playerList: this.userController.getPlayerList() });
    } }, { key: '_transformStreamID', value(e) {
      const t = e.lastIndexOf('_');return { userID: e.slice(0, t), streamType: e.slice(t + 1) };
    } }]), t;
  }());
})));
// # sourceMappingURL=trtc-wx.js.map
