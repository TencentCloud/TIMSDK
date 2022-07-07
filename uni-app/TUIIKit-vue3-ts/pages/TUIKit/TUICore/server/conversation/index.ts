import IComponentServer from '../IComponentServer';

import { TUIConversationStoreType } from '../types';
import { useStore } from 'vuex';
import store from '../../store';
/**
 * class TUIConversationServer
 *
 * TUIConversation 逻辑主体
 */
export default class TUIConversationServer extends IComponentServer {
	public TUICore: any;
	public store = store.state.timStore
	constructor(TUICore: any) {
		super();
		this.TUICore = uni.$TUIKit;
		uni.showLoading();
		this.bindTIMEvent();
		//   TUIConversationServer.store = uni.$TUIKit.TUICore.setComponentStore('TUIConversation', store, this.updateStore);
	}

	/**
	 * /////////////////////////////////////////////////////////////////////////////////
	 * //
	 * //                                    TIM 事件监听注册接口
	 * //
	 * /////////////////////////////////////////////////////////////////////////////////
	 */

	private bindTIMEvent() {
		uni.$TUIKit.tim.on(uni.$TUIKit.TIM.EVENT.CONVERSATION_LIST_UPDATED, this.handleConversationListUpdate, this);
	}

	private unbindTIMEvent() {
		uni.$TUIKit.tim.off(uni.$TUIKit.TIM.EVENT.CONVERSATION_LIST_UPDATED, this.handleConversationListUpdate);
	}

	public handleConversationListUpdate(res: any) {
		uni.hideLoading();
		if (res.data.length === 0) {
			uni.showToast({
				title: '暂无回话哦～'
			})
		}
		store.commit('timStore/setConversationList', res.data)
	}

	/**
	 * 组件销毁
	 *
	 */
	public destroyed() {
		this.unbindTIMEvent();
	}

	/*
	 * 获取 conversationList
	 *
	 * @returns {Promise}
	 */
	private getConversationList() {
		return new Promise<void>((resolve, reject) => {
			const config = {
				TUIName: 'TUIConversation',
				callback: async () => {
					try {
						const imResponse = await uni.$TUIKit.tim.getConversationList();
						// TUIConversationServer.store.conversationList = imResponse.data.conversationList;
						resolve(imResponse);
					} catch (error) {
						reject(error);
					}
				},
			};
		});
	}

	/**
	 * 获取 conversationList
	 *
	 * @param {string} conversationID 会话ID
	 * @returns {Promise}
	 */
	public async getConversationProfile(conversationID: string) {
		return new Promise<void>(async (resolve, reject) => {
			try {
				const imResponse = await this.TUICore.tim.getConversationProfile(conversationID);
				resolve(imResponse);
			} catch (error) {
				reject(error);
			}
		});
	}

	/**
		* 删除会话
		*
		* @param {string} conversationID 会话ID
		* @returns {Promise}
		*/

	public async deleteConversation(conversationID: string) {
		return new Promise<void>(async (resolve, reject) => {
			try {
				const imResponse: any = await this.TUICore.tim.deleteConversation(conversationID);
				resolve(imResponse);
			} catch (error) {
				reject(error);
			}
		});
	}

	/**
	 * 置顶会话
	 *
	 * @param {Object} options 置顶参数
	 * @returns {Promise}
	 */
	public async pinConversation(options: any) {
		return new Promise<void>(async (resolve, reject) => {
			try {
				const imResponse: any = await this.TUICore.tim.pinConversation(options);
				resolve(imResponse);
			} catch (error) {
				reject(error);
			}
		});
	}

	/**
	 * C2C消息免打扰
	 *
	 * @param {Object} options 消息免打扰参数
	 * @returns {Promise}
	 */
	public async muteConversation(options: any) {
		return new Promise<void>(async (resolve, reject) => {
			try {
				const imResponse: any = await this.TUICore.tim.setMessageRemindType(options);
				resolve(imResponse);
			} catch (error) {
				reject(error);
			}
		});
	}

/**
 * 设置已读
 *
 * @param {string} conversationID 会话ID
 * @returns {Promise}
 */
	public async  setMessageRead(conversationID: string) {
		return new Promise<void>(async (resolve, reject) => {
			try {
				const imResponse: any = await uni.$TUIKit.tim.setMessageRead({ conversationID });
				resolve(imResponse);
			} catch (error) {
				reject(error);
			}
		})
	}
}