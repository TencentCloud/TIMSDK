import IComponentServer from '../IComponentServer';

import { TUIChatStoreType } from '../types';

import { useStore } from 'vuex';
import store from '../../store';

// const store:TUIChatStoreType = {
//   conversation: {
//     conversationID: '',
//   },
//   messageList: [],
// };

/**
 * class TUIChatServer
 *
 * TUIChat 逻辑主体
 */
export default class TUIChatServer extends IComponentServer {
  public TUICore:any;
  public currentStore: any = {};
	public store = store.state.timStore
  constructor(TUICore:any) {
    super();
    this.TUICore = uni.$TUIKit;
    this.bindTIMEvent();
		// updateStore()
   }

  /**
   * 组件销毁
   */
  public destroyed() {
    this.unbindTIMEvent();
  }

/**
     * 数据监听回调
     *
     * @param {any} newValue 新数据
     * @param {any} oldValue 旧数据
     *
     */
  public updateStore(conversationID:string) {
  //   this.store.messageList = [];
		 store.commit('timStore/resetChat')
    this.getMessageList({ conversationID: conversationID, count: 15 }).then((res: any) => {
    //   this.store.messageList = res.data.messageList;
    });
  }


  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 事件监听注册接口
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_RECEIVED, this.handleMessageReceived, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_MODIFIED, this.handleMessageModified, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_REVOKED, this.handleMessageRevoked, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_READ_BY_PEER, this.handleMessageReadByPeer, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated, this);
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_RECEIVED, this.handleMessageReceived);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_MODIFIED, this.handleMessageModified);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_REVOKED, this.handleMessageRevoked);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_READ_BY_PEER, this.handleMessageReadByPeer);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated, this);
  }

  private handleMessageReceived(event:any) {
		event.data.forEach((item) => {
			if (item.conversationID === this.store.conversationID) {
				uni.$TUIKit.TUIConversationServer.setMessageRead(item.conversationID);
			  const messageList = [...this.store.messageList, item];
				// 更新 messageList
				store.commit('timStore/setMessageList', messageList)
			}
		})
    
  }
  private handleMessageModified(event:any) {
    const middleData = this.store.messageList;
    this.store.messageList = [];
    this.store.messageList = middleData;
  }
  private handleMessageRevoked(event:any) {
    // const middleData = this.store.messageList;
    // this.store.messageList = [];
    // this.store.messageList = middleData;
  }
  private async handleMessageReadByPeer(event:any) {
		// sdk message 消息引用关系会自动更新
		const middleData = this.store.messageList;
		// 兼容小程序，在小程序中 setData 是异步
		await store.commit('timStore/resetChat');
		await store.commit('timStore/setMessageList', middleData);
  }

  private handleGroupListUpdated(event:any) {
    event?.data.map((item:any) => {
      if (item?.groupID === this?.store?.conversation?.groupProfile?.groupID) {
        this.store.conversation.groupProfile = item;
        const midden = this.store.conversation;
        this.store.conversation = {};
        this.store.conversation = midden;
      }
      return item;
    });
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 处理 TIM 接口参数及回调
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 创建消息生成参数
   *
   * @param {Object} content 消息体
   * @param {String} type 消息类型 text: 文本类型 file: 文件类型 face: 表情 location: 地址 custom: 自定义 merger: 合并 forward: 转发
   * @param {Callback} callback 回调函数
   * @param {any} to 发送的对象
   * @returns {options} 消息参数
   */
  public handleMessageOptions(content:any, type:string, callback?:any, to?:any) {
    const options:any = {
      to: '',
      conversationType: to?.type || this.store.conversation.type,
      payload: content,
      needReadReceipt: true,
    };
    if (type === 'file' && callback) {
      options.onProgress = callback;
    }
    switch (options.conversationType) {
			
      case this.TUICore.TIM.TYPES.CONV_C2C:
        options.to = to?.userProfile?.userID || this.store.conversation?.userProfile?.userID || '';
        break;
      case this.TUICore.TIM.TYPES.CONV_GROUP:
        options.to = to?.groupProfile?.groupID || this.store.conversation?.groupProfile?.groupID || '';
        break;
      default:
        break;
    }
    return options;
  }

  /**
   * 处理异步函数
   *
   * @param {callback} callback 回调函数
   * @returns {Promise} 返回异步函数
   */
  public handlePromiseCallback(callback:any) {
    return new Promise<void>((resolve, reject) => {
      // const config = {
      //   TUIName: 'TUIChat',
      //   callback: () => {
      //     callback && callback(resolve, reject);
      //   },
      // };
      // this.TUICore.setAwaitFunc(config.TUIName, config.callback);
    });
  }

  /**
   * 文件上传进度函数处理
   *
   * @param {number} progress 文件上传进度 1表示完成
   * @param {message} message 文件消息
   */
  public handleUploadProgress(progress:number, message:any) {
    this.store.messageList.map((item:any) => {
      if (item.ID === message.ID) {
        item.progress = progress;
      }
      return item;
    });
  }

  /**
 * /////////////////////////////////////////////////////////////////////////////////
 * //
 * //                                 对外方法
 * //
 * /////////////////////////////////////////////////////////////////////////////////
 */

// /**
//  * 发送文本消息
//  *
//  * @param {any} text 发送的消息
//  * @returns {Promise}
//  */
/**
	 * 发送文本消息
	 *
	 * @param {any} text 发送的消息
	 * @returns {Promise}
	 */
	public  sendTextMessage(text:any): Promise<any>  {
	  return new Promise<void>(async(resolve, reject) => {
	    try {
	      const options = this.handleMessageOptions({ text }, 'text');
	      const message = this.TUICore.tim.createTextMessage(options);
				// 优化写法
	      const messageList = [...this.store.messageList, message];
				store.commit('timStore/setMessageList', messageList)
	      const imResponse = await this.TUICore.tim.sendMessage(message);
	      this.store.messageList = this.store.messageList.map((item:any) => {
	        if (item.ID === imResponse.data.message.ID) {
	          return imResponse.data.message;
	        }
	        return item;
	      });
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
				const middleData = this.store.messageList;
				store.commit('timStore/resetChat')
				store.commit('timStore/setMessageList', middleData)
	    }
	  });
	}


  /**
 * 发送表情消息
 *
 * @param {Object} data 消息内容
 * @param {Number} data.index 表情索引
 * @param {String} data.data 额外数据
 * @returns {Promise}
 */
  public sendFaceMessage(data:any): Promise<any> {
    return new Promise<void>(async(resolve, reject) => {
      try {
        const options = this.handleMessageOptions(data, 'face');
        const message = this.TUICore.tim.createFaceMessage(options);
        // this.store.messageList.push(message);
				// 优化写法
				const messageList = [...this.store.messageList, message];
				store.commit('timStore/setMessageList', messageList)
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.store.messageList = this.store.messageList.map((item:any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 发送图片消息
 *
 * @param {res} res 图片文件
 * @param {image} 图片尺寸
 * @returns {Promise}
 */
  public sendImageMessage(res:any, image:any): Promise<any> {
    return new Promise<void>(async(resolve, reject) => {
      try {
        const options = this.handleMessageOptions({ file: res }, 'file')
        const message = this.TUICore.tim.createImageMessage(options);
				// todo  上屏图片消息在发送之前没有尺寸，本地获取补充
				message.payload.imageInfoArray[1].height = image.height 
				message.payload.imageInfoArray[1].width = image.width 
				const messageList = [...this.store.messageList, message];
				store.commit('timStore/setMessageList', messageList)
        const imResponse = await this.TUICore.tim.sendMessage(message);
         this.store.messageList = this.store.messageList.map((item:any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 发送视频消息
 *
 * @param {Video} video 图片文件
 * @returns {Promise}
 */
  public sendVideoMessage(res:any, video:any): Promise<any> {
    return new Promise<void>(async(resolve, reject) => {
      try {
        const options = this.handleMessageOptions({ file: res }, 'file');
        const message = this.TUICore.tim.createVideoMessage(options);
				// todo  上屏图片消息在发送之前没有尺寸，本地获取补充
				// message.payload.imageInfoArray[1].height = video.height 
				// message.payload.imageInfoArray[1].width = video.width 
				const messageList = [...this.store.messageList, message];
				store.commit('timStore/setMessageList', messageList)
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.store.messageList = this.store.messageList.map((item:any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 发送语音消息
 *
 * @param {audio} audio 音频文件
 * @returns {Promise}
 */
  public sendAudioMessage(audio:any): Promise<any> {
    return new Promise<void>(async(resolve, reject) => {
      try {
        const options = this.handleMessageOptions({ file: audio }, 'file', (progress:number) => {
          this.handleUploadProgress(progress, message);
        });
        const message = this.TUICore.tim.createAudioMessage(options);
				// todo  上屏图片消息在发送之前没有尺寸，待优化
				const messageList = [...this.store.messageList, message];
				store.commit('timStore/setMessageList', messageList)
        const imResponse = await this.TUICore.tim.sendMessage(message);
        console.log('发送音频消息完成', imResponse);
        this.store.messageList = this.store.messageList.map((item:any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }
	
  /**
 * 发送文件消息
 *
 * @param {File} file 文件
 * @returns {Promise}
 */
  public sendFileMessage(file:any): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const options = this.handleMessageOptions({ file }, 'file', (progress:number) => {
          this.handleUploadProgress(progress, message);
        });
        const message = this.TUICore.tim.createFileMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        console.log('发送文件消息完成', imResponse);
        this.store.messageList = this.store.messageList.map((item:any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 发送自定义消息
 *
 * @param {Object} data 消息内容
 * @param {String} data.data 自定义消息的数据字段
 * @param {String} data.description 自定义消息的说明字段
 * @param {String} data.extension 自定义消息的扩展字段
 * @returns {Promise}
 */
  public sendCustomMessage(data:any): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const options = this.handleMessageOptions(data, 'custom');
        const message = this.TUICore.tim.createCustomMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        console.log('发送自定义消息完成', imResponse);
        this.store.messageList = this.store.messageList.map((item:any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 发送地理位置消息
 *
 * @param {Object} data 消息内容
 * @param {String} data.description 地理位置描述信息
 * @param {Number} data.longitude 经度
 * @param {Number} data.latitude 纬度
 * @returns {Promise}
 */
  public sendLocationMessage(data:any): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const options = this.handleMessageOptions(data, 'location');
        const message = this.TUICore.tim.createLocationMessage(options);
        this.store.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        console.log('发送地理位置消息完成', imResponse);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
 * 转发消息
 *
 * @param {message} message 消息实例
 * @param {any} to 转发的对象
 * @returns {Promise}
 */
  public forwardMessage(message:any, to:any): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const options = this.handleMessageOptions(message, 'forward', {}, to);
        const imMessage = this.TUICore.tim.createForwardMessage(options);
        const imResponse = await this.TUICore.tim.sendMessage(imMessage);
        if (this.store.conversation.conversationID === imResponse.data.message.conversationID) {
          this.store.messageList.push(imResponse.data.message);
        }
        console.log('消息转发完成', imResponse);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

/**
   * 发送@ 提醒功能的文本消息
   *
   * @param {Object} data 消息内容
   * @param {String} data.text 文本消息
   * @param {Array} data.atUserList 需要 @ 的用户列表，如果需要 @ALL，请传入 TIM.TYPES.MSG_AT_ALL
   * @returns {message}
   *
   * - 注：此接口仅用于群聊
   */
public sendTextAtMessage(data:Object) {
	return new Promise<void>(async(resolve, reject) => {
    try {
      const options = this.handleMessageOptions(data, 'text');
      const message = this.TUICore.tim.createTextAtMessage(options);
      this.currentStore.messageList.push(message);
      const imResponse = await this.TUICore.tim.sendMessage(message);
      this.currentStore.messageList = this.currentStore.messageList.map((item:any) => {
        if (item.ID === imResponse.data.message.ID) {
          return imResponse.data.message;
        }
        return item;
      });
      resolve(imResponse);
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * 发送合并消息
 *
 * @param {Object} data 消息内容
 * @param {Array.<Message>} data.messageList 合并的消息列表
 * @param {String} data.title 合并的标题
 * @param {String} data.abstractList 摘要列表，不同的消息类型可以设置不同的摘要信息
 * @param {String} data.compatibleText 兼容文本
 * @returns {Promise}
 */
public sendMergerMessage(data:any): Promise<any> {
  return this.handlePromiseCallback(async (resolve:any, reject:any) => {
    try {
      const options = this.handleMessageOptions(data, 'merger');
      const message = this.TUICore.tim.createMergerMessage(options);
      this.currentStore.messageList.push(message);
      const imResponse = await this.TUICore.tim.sendMessage(message);
      console.log('发送合并消息完成', imResponse);
      this.currentStore.messageList = this.currentStore.messageList.map((item:any) => {
        if (item.ID === imResponse.data.message.ID) {
          return imResponse.data.message;
        }
        return item;
      });
      resolve(imResponse);
    } catch (error) {
      reject(error);
    }
  });
}

  /**
 * 获取群成员列表
 *
 * @param {Object} options 获取群成员参数
 * @param {String} options.groupID 群组的 ID
 * @param {Number} options.count 需要拉取的数量。最大值：100
 * @param {Number} options.offset 偏移量，默认从0开始拉取
 * @returns {Promise}
 */
  public getGroupMemberList(options:any): Promise<any> {
    return this.handlePromiseCallback(async (resolve:any, reject:any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupMemberList(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }
	
	/**
	 * 获取 messageList
	 *
	 * @param {any} options 获取 messageList 参数
	 * @param {Boolean} history  是否获取历史消息
	 * @returns {Promise}
	 */
	public async getMessageList(options:any, history?:Boolean) {
		return new Promise<void>(async(resolve, reject) => {
			try {
			  const imResponse = await this.TUICore.tim.getMessageList(options);
				let messageList;
			  if (!history) {
			     messageList = imResponse.data.messageList;
			  } else {
			     messageList = [...imResponse.data.messageList, ...this.store.messageList];
			  }
			  this.currentStore.nextReqMessageID = imResponse.data.nextReqMessageID;
			  this.currentStore.isCompleted = imResponse.data.isCompleted;
				store.commit('timStore/setMessageList', messageList)
			  resolve(imResponse.data);
			} catch (error) {
			  reject(error);
			}
		});
	}
	
	/**
	 * 获取历史消息
	 *
	 * @returns {Promise}
	 */
	public async  getHistoryMessageList() {
		return new Promise<void>(async(resolve, reject) => {
			try {
				const options = {
				  conversationID: this.store.conversation.conversationID,
				  nextReqMessageID: this.currentStore.nextReqMessageID,
				  count: 15,
				};
				let  messageList = [];
				if (!this.currentStore.isCompleted) {
					messageList = await this.getMessageList(options, true);
				}
			  resolve(messageList);
			} catch (error) {
			  reject(error);
			}
		});
	}
	
	
	/**
	 * 消息撤回
	 *
	 * @param {message} message 消息实例
	 * @returns {Promise}
	 */
	public  revokeMessage(message:any): Promise<any> {
		return new Promise<void>(async(resolve, reject) => {
	    try {
	      const imResponse = await this.TUICore.tim.revokeMessage(message);
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
	    }
	  });
	}
	
	/**
	 * 重发消息
	 *
	 * @param {message} message 消息实例
	 * @returns {Promise}
	 */
	public  resendMessage(message:any): Promise<any> {
		return new Promise<void>(async(resolve, reject) => {
	    try {
	      const imResponse = await this.TUICore.tim.resendMessage(message);
	      console.log('消息重发完成', imResponse);
	      this.currentStore.messageList = this.currentStore.messageList.filter((item:any) => item.ID !== message.ID);
	      this.currentStore.messageList.push(imResponse.data.message);
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
	    }
	  });
	}
	
	/**
	 * 删除消息
	 *
	 * @param {Array.<message>} messages 消息实例
	 * @returns {Promise}
	 */
	public  deleteMessage(messages:any): Promise<any> {
		return new Promise<void>(async(resolve, reject) => {
	    try {
	      const imResponse = await this.TUICore.tim.deleteMessage(messages);
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
	    }
	  });
	}
	
	/**
	 * 获取群成员列表
	 *
	 * @param {Object} options 获取群成员参数
	 * @param {String} options.groupID 群组的 ID
	 * @param {Number} options.count 需要拉取的数量。最大值：100
	 * @param {Number} options.offset 偏移量，默认从0开始拉取
	 * @returns {Promise}
	 */
	public  getGroupMemberList(options:any): Promise<any> {
	  return this.handlePromiseCallback(async (resolve:any, reject:any) => {
	    try {
	      const imResponse = await this.TUICore.tim.getGroupMemberList(options);
	      this.currentStore.userInfo.isGroup = true;
	      if (options.offset) {
	        this.currentStore.userInfo.list = [...this.currentStore.userInfo.list, ...imResponse.data.memberList];
	      } else {
	        this.currentStore.userInfo.list = imResponse.data.memberList;
	      }
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
	    }
	  });
	}
	
	/**
	 * 获取群成员资料
	 *
	 * @param {any} options 参数
	 * @param {String} options.groupID 群组ID
	 * @param {Array.<String>} options.userIDList 要查询的群成员用户 ID 列表
	 * @param {	Array.<String>} options.memberCustomFieldFilter 群成员自定义字段筛选
	 * @returns {Promise}
	 */
	public  getGroupMemberProfile(options:any): Promise<any>  {
	  return this.handlePromiseCallback(async (resolve:any, reject:any) => {
	    try {
	      const imResponse = await this.TUICore.tim.getGroupMemberProfile(options);
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
	    }
	  });
	}
	
	
	/**
	 * 处理申请加群
	 * - 管理员
	 *
	 * @param {any} options 参数
	 * @param {String} options.handleAction 处理结果 Agree(同意) / Reject(拒绝)
	 * @param {String} options.handleMessage 附言
	 * @param {Message} options.message 对应【群系统通知】的消息实例
	 * @returns {Promise}
	 */
	public  handleGroupApplication(options:any): Promise<any>  {
	  return this.handlePromiseCallback(async (resolve:any, reject:any) => {
	    try {
	      const imResponse = await this.TUICore.tim.handleGroupApplication(options);
	      resolve(imResponse);
	    } catch (error) {
	      reject(error);
	    }
	  });
	}
}
	
/**
 * /////////////////////////////////////////////////////////////////////////////////
 * //
 * //                                 对外方法
 * //
 * /////////////////////////////////////////////////////////////////////////////////
 */




// /**
//  * 赋值
//  *
//  * @param {Object} params 使用的数据
//  * @returns {Object} 数据
//  */
// export function useStore(params:any) {
//   return this.currentStore = params;
// }
