const app = getApp()

Component({
  options: {
    multipleSlots: true // 启用多slot支持
  },
  properties: {
    roomID: {
      type: Number,
      value: 0
    },
    roomName: {
      type: String,
      value: ''
    },
    userID: {
      type: String,
      value: ''
    },
    userName: {
      type: String,
      value: ''
    },
    userSig: {
      type: String,
      value: ''
    },
    sdkAppID: {
      type: Number,
      value: 0
    },
    privateMapKey: {
      type: String,
      value: ''
    },
    beauty: {
      type: Number,
      value: 0
    }, //美颜程度，取值为0~9
    // 美白指数
    whiteness: {
      type: Number,
      value: 0
    },
    aspect: {
      type: String,
      value: '3:4'
    }, // 设置画面比例，取值为'3:4'或者'9:16'
    minBitrate: {
      type: Number,
      value: 200
    }, // 设置码率范围为[minBitrate,maxBitrate]，四人建议设置为200~400
    maxBitrate: {
      type: Number,
      value: 400
    },
    muted: {
      type: Boolean,
      value: false
    }, // 设置推流是否静音
    debug: {
      type: Boolean,
      value: false
    }, // 是否显示log
    enableIM: {
      type: Boolean, // 是否启用IM
      value: false
    },
    useCloud: {
      type: Boolean, // 是否使用云上环境
      value: true
    },
    // 进入房间后是否自动播放房间中其他的远程画面
    autoplay: {
      type: Boolean,
      value: false
    },
    enableCamera: {
      type: Boolean,
      value: true
    },
    smallViewLeft: {
      type: String,
      value: '1vw'
    },
    smallViewTop: {
      type: String,
      value: '1vw'
    },
    smallViewWidth: {
      type: String,
      value: '30vw'
    },
    smallViewHeight: {
      type: String,
      value: '40vw'
    },
    waitingImg: {
      type: String,
      value: 'https://main.qcloudimg.com/raw/b14189beafbb8db8275e53c8cb596e1f.png'
    },
    // live-player的背景图
    playerBackgroundImg: {
      type: String,
      value: 'https://main.qcloudimg.com/raw/b14189beafbb8db8275e53c8cb596e1f.png'
    },
    loadingImg: {
      type: String,
      value: 'https://main.qcloudimg.com/raw/3e0a94d92a3b312a191cee4f96f0bd8b.png'
    },
    
    pureAudioPushMod: {
      type: Number,
      value: 0
    },
    recordId: {
      type: Number,
      value: null
    }
  },
  data: {
    requestSigFailCount: 0,
    pusherContext: '',
    hasPushStarted: false,
    pushURL: '',
    members: [{}],
    maxMembers: 3,
    self: {},
    startPlay: false,
    hasExitRoom: true,
    
    fixPlayId: 'trtc_fix_play_id', // 大小画面的用来定位live-player的id
    
    // 记录live-player的声音状态， 默认都是打开声音状态(false和undefined)
    playerMutedStatus: {
    
    },
    
    // 记录live-player的摄像头状态， 默认都是打开声音状态（true和undefined）
    playerVideoStatus: {
    
    },
    
    PUSH_SUCCESS: 1, // 推流成功
    JOIN_ROOM_SUCCESS: 0, // 进房成功
    
    ERROR_OPEN_CAMERA: -4, // 打开摄像头失败
    ERROR_OPEN_MIC: -5, // 打开麦克风失败
    ERROR_PUSH_DISCONNECT: -6, // 推流连接断开
    ERROR_CAMERA_MIC_PERMISSION: -7, // 获取不到摄像头或者麦克风权限
    ERROR_EXCEEDS_THE_MAX_MEMBER: -8, // 超过最大成员数
    ERROR_REQUEST_ROOM_SIG: -9, // 获取房间SIG错误
    ERROR_JOIN_ROOM: -10 // 进房失败
  },
  
  ready: function () {
    self = this;
    if (!this.data.pusherContext) {
      this.data.pusherContext = wx.createLivePusherContext('rtcpusher');
    }
  },
  
  detached: function () {
    self.exitRoom();
  },
  
  methods: {
    
    /**
     * 打开或者关闭某一路画面
     * @param {Boolean} enable
     * @param {String} userid  userid = 0 代表打开或关闭本地的摄像头画面
     */
    enableVideo(enable, userid) {
      if (userid) {
        var playerContext = wx.createLivePlayerContext(userid, this);
        if (playerContext) {
          // 获取用户视频状态，默认是播放用户视频， true 播放   false 不播放
          var videoStatus = this.data.playerVideoStatus[userid];
          // 如果 enable = true（想要打开画面）
          if (enable) {
            if (videoStatus) {
              // 如果原来是打开状态，则不需要操作了
            } else {
              // 如果原来是关闭状态，则打开
              playerContext.play();
              var playerVideoStatus = this.data.playerVideoStatus;
              playerVideoStatus[userid] = true; // 设置为打开状态
              this.setData({
                playerVideoStatus: playerVideoStatus
              })
            }
          } else { // 想关闭画面
            if (videoStatus) {
              // 原来是打开状态，则关闭
              // playerContext.stop();
              var playerVideoStatus = this.data.playerVideoStatus;
              playerVideoStatus[userid] = false; // 设置为关闭状态
              this.setData({
                playerVideoStatus: playerVideoStatus
              })
            } else {
              // 原来就是关闭的，则不需要操作了
            }
          }
          
        }
      } else {
        // this.setData({
        //   enableCamera: enable
        // });
      }
    },
    
    /**
     * 打开或者关闭某一路声音
     * @param {*} enable
     * @param {*} userid  userid = 0 代表打开或关闭本地的麦克风声音
     */
    enableAudio(enable, userid, params = {}) {
      if (userid) {
        var playerContext = wx.createLivePlayerContext(userid, this);
        if (playerContext) {
          // 获取用户声音的状态，默认false 打开声音  true 关闭声音
          var muted = this.data.playerMutedStatus[userid];
          
          // 如果 enable = true（想要打开声音）
          if (enable) {
            // 如果原来是关闭状态，则打开
            if (muted) {
              playerContext.mute(params);
              var playerMutedStatus = this.data.playerMutedStatus;
              playerMutedStatus[userid] = false; // 设置为打开状态
              this.setData({
                playerMutedStatus: playerMutedStatus
              })
            } else {
              // 如果原来是打开状态，则不需要操作了
            }
          } else { // 想关闭声音
            if (muted) {
              // 原来就是关闭的，则不需要操作了
            } else {
              // 原来是打开状态，则关闭
              playerContext.mute(params);
              var playerMutedStatus = this.data.playerMutedStatus;
              playerMutedStatus[userid] = true; // 设置为关闭状态
              this.setData({
                playerMutedStatus: playerMutedStatus
              })
            }
          }
        }
      } else {
        // this.setData({
        //   muted: enable
        // });
      }
    },
    
    onBack: function () {
      wx.navigateBack({
        delta: 1
      });
    },
    /**
     * 点击切换player的声音事件
     * @param {*} e
     */
    enableAudioTap(e) {
      var uid = e.currentTarget.dataset.uid;
      var status = this.data.playerMutedStatus[uid];
      if (typeof status === 'undefined') {
        this.data.playerMutedStatus[uid] = false;
        status = false; // 默认是打开audio
      }
      this.enableAudio(status, uid);
    },
    
    /**
     * 点击切换player的视频事件
     * @param {*} e
     */
    enableVidoTap(e) {
      var uid = e.currentTarget.dataset.uid;
      var status = this.data.playerVideoStatus[uid];
      if (typeof status === 'undefined') {
        this.data.playerVideoStatus[uid] = !!this.data.autoplay;
        status = !!this.data.autoplay; // 默认是打开audio
      }
      this.enableVideo(!status, uid);
    },
    
    /**
     * webrtc-room程序的入口
     */
    start: function () {
      self = this;
      self.data.hasExitRoom = false;
      self.requestSigServer(self.data.userSig, self.data.privateMapKey);
    },
    
    /**
     * 停止
     */
    stop: function () {
      self.data.hasExitRoom = true;
      console.log("组件停止");
      self.exitRoom();
    },
    
    /**
     * 暂停
     */
    pause: function () {
      if (!self.data.pusherContext) {
        self.data.pusherContext = wx.createLivePusherContext('rtcpusher');
      }
      self.data.pusherContext && self.data.pusherContext.pause();
      
      self.data.members.forEach(function (val) {
        val.playerContext && val.playerContext.pause();
      });
    },
    
    resume: function () {
      if (!self.data.pusherContext) {
        self.data.pusherContext = wx.createLivePusherContext('rtcpusher');
      }
      self.data.pusherContext && self.data.pusherContext.resume();
      
      self.data.members.forEach(function (val) {
        val.playerContext && val.playerContext.resume();
      });
    },
    
    /**
     * 切换摄像头
     */
    switchCamera: function () {
      if (!self.data.pusherContext) {
        self.data.pusherContext = wx.createLivePusherContext('rtcpusher');
      }
      console.log('switch')
      self.data.pusherContext && self.data.pusherContext.switchCamera({});
    },
    
    /**
     * 退出房间
     */
    exitRoom: function () {
      if (!self.data.pusherContext) {
        self.data.pusherContext = wx.createLivePusherContext('rtcpusher');
      }
      self.data.pusherContext && self.data.pusherContext.stop && self.data.pusherContext.stop();
      
      self.data.members.forEach(function (val) {
        val.playerContext && val.playerContext.stop();
      });
      
      for (var i = 0; i < self.data.maxMembers; i++) {
        self.data.members[i] = {};
      }
      
      self.setData({
        pushURL: "",
        members: self.data.members
      });
      
    },
    
    postErrorEvent: function (errCode, errMsg) {
      self.postEvent('error', errCode, errMsg);
    },
    
    postNormalEvent: function (code, msg) {
      self.postEvent('event', code, msg);
    },
    
    postEvent: function (tag, code, detail) {
      self.triggerEvent('RoomEvent', {
        tag: tag,
        code: code,
        detail: detail
      }, {});
    },
    
    /**
     * 请求SIG服务
     */
    requestSigServer: function (userSig, privMapEncrypt) {
      console.log('获取sig:', this.data);
      
      var self = this;
      var roomID = this.data.roomID
      var userID = this.data.userID;
      var sdkAppID = this.data.sdkAppID;
      
      var url = this.data.useCloud ? 'https://official.opensso.tencent-cloud.com/v4/openim/jsonvideoapp' : 'https://yun.tim.qq.com/v4/openim/jsonvideoapp';
      url += '?sdkappid=' + sdkAppID + "&identifier=" + userID + "&usersig=" + userSig + "&random=" + Date.now() + "&contenttype=json";
      
      var reqHead = {
        "Cmd": 1,
        "SeqNo": 1,
        "BusType": 7,
        "GroupId": roomID
      };
      var reqBody = {
        "PrivMapEncrypt": privMapEncrypt,
        "TerminalType": 1,
        "FromType": 3,
        "SdkVersion": 26280566
      };
      console.log("requestSigServer params:", url, reqHead, reqBody);
      
      wx.request({
        url: url,
        data: {
          "ReqHead": reqHead,
          "ReqBody": reqBody
        },
        method: "POST",
        success: function (res) {
          console.log("requestSigServer success:", res);
          if (res.data["ErrorCode"] || res.data["RspHead"]["ErrorCode"] != 0) {
            console.error(res.data["ErrorInfo"] || res.data["RspHead"]["ErrorInfo"]);
            self.data.requestSigFailCount++;
            // 重试1次后还是错误，则抛出错误
            if (self.data.requestSigFailCount <= 1) {
              setTimeout(() => {
                console.error('获取roomsig失败，重试~');
                self.requestSigServer(userSig, privMapEncrypt);
              }, 1000);
            } else {
              self.postErrorEvent(self.data.ERROR_REQUEST_ROOM_SIG, '获取roomsig失败');
            }
            return;
          }
          
          self.data.requestSigFailCount = 0;
          
          var roomSig = JSON.stringify(res.data["RspBody"]);
          var pushUrl = "room://cloud.tencent.com?sdkappid=" + sdkAppID + "&roomid=" + roomID + "&userid=" + userID + "&roomsig=" + encodeURIComponent(roomSig);
          
          // 如果有配置纯音频推流或者recordId参数
          if (self.data.pureAudioPushMod || self.data.recordId) {
            var bizbuf = {
              Str_uc_params: {
                pure_audio_push_mod: 0,
                record_id: 0
              }
            }
            // 纯音频推流
            if (self.data.pureAudioPushMod) {
              bizbuf.Str_uc_params.pure_audio_push_mod = self.data.pureAudioPushMod
            } else {
              delete bizbuf.Str_uc_params.pure_audio_push_mod;
            }
            
            // 自动录制时业务自定义id
            if (self.data.recordId) {
              bizbuf.Str_uc_params.record_id = self.data.recordId
            } else {
              delete bizbuf.Str_uc_params.record_id;
            }
            pushUrl += '&bizbuf=' + encodeURIComponent(JSON.stringify(bizbuf));
          }
          
          console.log("roomSigInfo", roomID, userID, roomSig, pushUrl);
          
          self.setData({
            pushURL: pushUrl,
            userID: userID
          });
        },
        fail: function (res) {
          console.log("requestSigServer fail:", res);
          wx.showToast({
            title: '获取房间签名失败',
          });
          
          self.data.requestSigFailCount++;
          // 重试1次后还是错误，则抛出错误
          if (self.data.requestSigFailCount <= 1) {
            setTimeout(() => {
              console.error('获取roomsig失败，重试~');
              self.requestSigServer(userSig, privMapEncrypt);
            }, 1000);
          } else {
            self.postErrorEvent(self.data.ERROR_REQUEST_ROOM_SIG, '获取roomsig失败');
          }
        }
      })
    },
    
    onWebRTCUserListPush: function (msg) {
      console.log('onWebRTCUserListPush method', msg);
      if (!msg) {
        return;
      }
      
      var jsonDic = JSON.parse(msg);
      if (!jsonDic) {
        return;
      }
      
      var newUserList = jsonDic.userlist;
      console.log('play_users: ', JSON.stringify(newUserList));
      
      if (!newUserList) {
        return;
      }
      
      var pushers = [];
      newUserList && newUserList.forEach(function (val) {
        var pusher = {
          userID: val.userid,
          accelerateURL: val.playurl
        };
        pushers.push(pusher);
      });
      
      // 如果超过了最大人数，则检测出不在members里面的成员，并通知他
      if (pushers.length > self.data.maxMembers) {
        self.postErrorEvent(self.data.ERROR_EXCEEDS_THE_MAX_MEMBER, `当前房间超过最大人数${self.data.maxMembers + 1}，请重新进入其他房间体验~`);
      }
      
      self.onPusherJoin({
        pushers: pushers
      });
      
      self.onPusherQuit({
        pushers: pushers
      });
    },
    
    //将在res.pushers中，但不在self.data.members中的流，加入到self.data.members中
    onPusherJoin: function (res) {
      res.pushers.forEach(function (val) {
        var emptyIndex = -1;
        var hasPlay = false;
        for (var i = 0; self.data.members && i < self.data.members.length; i++) {
          if (self.data.members[i].userID && self.data.members[i].userID == val.userID) {
            hasPlay = true;
          } else if (!self.data.members[i].userID && emptyIndex == -1) {
            emptyIndex = i;
          }
        }
        if (!hasPlay && emptyIndex != -1) {
          val.loading = false;
          
          // 如果是bigsmall大小画面，则使用固定的id
          if (self.data.template == 'bigsmall') {
            val.playerContext = wx.createLivePlayerContext(self.data.fixPlayId, self);
          } else {
            val.playerContext = wx.createLivePlayerContext(val.userID, self);
          }
          // val.playerContext = wx.createLivePlayerContext(val.userID);
          self.data.members[emptyIndex] = val;
        }
        
        self.setData({
          members: self.data.members
        });
        
        self.initPlayerStatus(val.userID);
      });
    },
    
    //将在self.data.members中，但不在res.pushers中的流删除
    onPusherQuit: function (res) {
      for (var i = 0; i < self.data.members.length; i++) {
        var needDelete = true;
        for (var j = 0; j < res.pushers.length; j++) {
          if (self.data.members[i].userID == res.pushers[j].userID) {
            needDelete = false;
          }
        }
        if (needDelete) {
          // if(self.data.members[i] && self.data.members[i].userID) {
          //   var player = wx.createLivePlayerContext(self.data.members[i].userID);
          //   player && player.stop();
          // }
          var userid = self.data.members[i].userID;
          if (userid) {
            if (self.data.playerVideoStatus[userid]) {
              delete self.data.playerVideoStatus[userid];
            }
            if (self.data.playerMutedStatus[userid]) {
              delete self.data.playerMutedStatus[userid];
            }
          }
          self.setData({
            playerVideoStatus: self.data.playerVideoStatus,
            playerMutedStatus: self.data.playerMutedStatus,
          });
          self.data.members[i] = {};
        }
      }
      self.setData({
        members: self.data.members
      });
    },
    
    //删除res.pushers
    delPusher: function (pusher) {
      for (var i = 0; i < self.data.members.length; i++) {
        if (self.data.members[i].userID == pusher.userID) {
          var player = wx.createLivePlayerContext(pusher.userID);
          player && player.stop();
          self.data.members[i] = {};
        }
      }
      self.setData({
        members: self.data.members
      });
    },
    
    // 推流事件
    onPush: function (e) {
      console.log('============== onPush e userID', this.data.userID);
      if (!self.data.pusherContext) {
        self.data.pusherContext = wx.createLivePusherContext('rtcpusher');
      }
      var code;
      if (e.detail) {
        code = e.detail.code;
      } else {
        code = e;
      }
      console.log('推流事件：', code);
      var errmessage = '';
      switch (code) {
        case 1002:
        {
          console.log('推流成功');
          self.postNormalEvent(self.data.PUSH_SUCCESS, '推流成功');
          break;
        }
        case -1301:
        {
          console.error('打开摄像头失败: ', code);
          self.postErrorEvent(self.data.ERROR_OPEN_CAMERA, '打开摄像头失败');
          self.exitRoom();
          break;
        }
        case -1302:
        {
          console.error('打开麦克风失败: ', code);
          self.postErrorEvent(self.data.ERROR_OPEN_MIC, '打开麦克风失败');
          self.exitRoom();
          break;
        }
        case -1307:
        {
          console.error('推流连接断开: ', code);
          self.postErrorEvent(self.data.ERROR_PUSH_DISCONNECT, '推流连接断开');
          self.exitRoom();
          break;
        }
        case 5000:
        {
          console.log('收到5000: ', code);
          // 收到5000就退房
          self.exitRoom();
          break;
        }
        case 1018:
        {
          console.log('进房成功', code);
          self.postNormalEvent(self.data.JOIN_ROOM_SUCCESS, '进房成功');
          break;
        }
        case 1019:
        {
          console.log('退出房间', code);
          self.postErrorEvent(self.data.ERROR_JOIN_ROOM, '加入房间异常，请重试');
          break;
        }
        case 1020:
        {
          console.log('成员列表', code);
          self.onWebRTCUserListPush(e.detail.message);
          break;
        }
        case 1021:
        {
          console.log('网络类型发生变化，需要重新进房', code);
          //先退出房间
          self.exitRoom();
          self.start();
          break;
        }
        case 2007:
        {
          console.log('视频播放loading: ', e.detail.code);
          break;
        };
        case 2004:
        {
          console.log('视频播放开始: ', e.detail.code);
          break;
        };
        default:
        {
          // console.log('推流情况：', code);
        }
      }
    },
    
    // 标签错误处理
    onError: function (e) {
      console.error('onError: ', e);
      // 最新版的微信在live-pusher上有坑，binderror事件返回的数据有问题，原来返回的数据是在detail字段中，最新版本返回在details中
      // 这里已经和微信小程序的开发确认过，下一个版本会修复成detail。
      // 当前版本需要做兼容处理。
      let detail = e.detail || e.details;
      detail.errCode == 10001 ? (detail.errMsg = '未获取到摄像头功能权限，请删除小程序后重新打开') : '';
      detail.errCode == 10002 ? (detail.errMsg = '未获取到录音功能权限，请删除小程序后重新打开') : '';
      self.postErrorEvent(self.data.ERROR_CAMERA_MIC_PERMISSION, detail.errMsg || '未获取到摄像头、录音功能权限，请删除小程序后重新打开')
    },
    
    //播放器live-player回调
    onPlay: function (e) {
      console.log('onPlay code: ', e.detail.code);
      self.data.members.forEach(function (val) {
        if ((self.data.template == 'bigsmall' && e.currentTarget.id === self.data.fixPlayId) || e.currentTarget.id == val.userID) {
          switch (e.detail.code) {
            case 2007:
            {
              console.log('视频播放loading: ', e);
              val.loading = true;
              break;
            }
            case 2004:
            {
              console.log('视频播放开始: ', e);
              val.loading = false;
              self.setData({
                startPlay: true
              });
              break;
            }
            case -2301:
            {
              console.error('网络连接断开，且重新连接亦不能恢复，播放器已停止播放', val);
              self.delPusher(val);
              break;
            }
            default:
            {
              // console.log('拉流情况：', e);
            }
          }
        }
      });
    },
    // 初始化状态
    initPlayerStatus(uid) {
      var status = this.data.playerVideoStatus[uid];
      if (typeof status === 'undefined') {
        this.data.playerVideoStatus[uid] = !!this.data.autoplay;
        var playerVideoStatus = this.data.playerVideoStatus;
        this.setData({
          playerVideoStatus: playerVideoStatus
        })
      }
    }
  }
})
