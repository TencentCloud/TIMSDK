import IComponentServer from '../IComponentServer';

const store: any = {};

/**
 * class TUIGroupServer
 *
 * TUIGroup 逻辑主体
 */
export default class TUIGroupServer extends IComponentServer {
  public TUICore: any;
  public store: any;
  public currentStore: any = {};
  public storeCallback: any;
  constructor(TUICore: any) {
    super();
    this.TUICore = TUICore;
    this.bindTIMEvent();
    this.store = TUICore.setComponentStore('TUIGroup', store, this.updateStore.bind(this));
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
   */
  updateStore(newValue: any, oldValue: any) {
    this.currentStore.groupList = newValue.groupList;
    this.currentStore.searchGroup = newValue.searchGroup;
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 事件监听注册接口
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.GROUP_ATTRIBUTES_UPDATED, this.handleGroupAttributesUpdated, this);
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.GROUP_ATTRIBUTES_UPDATED, this.handleGroupAttributesUpdated);
  }

  private handleGroupListUpdated(event: any) {
    this.store.groupList = event.data;
  }
  private handleGroupAttributesUpdated(event: any) {
    const { groupID, groupAttributes } = event.data; // 群组ID // 更新后的群属性
    console.log(groupID, groupAttributes);
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 处理 TIM 接口参数及回调
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 处理异步函数
   *
   * @param {callback} callback 回调函数
   * @returns {Promise} 返回异步函数
   */
  public handlePromiseCallback(callback: any) {
    return new Promise<void>((resolve, reject) => {
      const config = {
        TUIName: 'TUIGroup',
        callback: () => {
          callback && callback(resolve, reject);
        },
      };
      this.TUICore.setAwaitFunc(config.TUIName, config.callback);
    });
  }
  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 对外方法
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 获取群组列表
   *
   * @param {any} options 参数
   * @param {Array.<String>} options.groupProfileFilter 群资料过滤器
   * @returns {Promise}
   */
  public async getGroupList(options?: any) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        let imResponse: any = {};
        if (!options) {
          imResponse = await this.TUICore.tim.getGroupList();
        } else {
          imResponse = await this.TUICore.tim.getGroupList(options);
        }
        this.store.groupList = imResponse.data.groupList;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群组属性
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.groupProfileFilter 群资料过滤器
   * @returns {Promise}
   */
  public getGroupProfile(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupProfile(options);
        this.store.groupList = imResponse.data.groupList;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 创建群组
   *
   * @param {any} options 参数
   * @param {String} options.name 群组名称
   * @param {String} options.type 群组类型
   * @param {String} options.groupID 群组ID
   * @param {String} options.introduction 群简介
   * @param {String} options.notification 群公告
   * @param {String} options.avatar 群头像 URL
   * @param {Number} options.maxMemberNum 最大群成员数量
   * @param {Number} options.joinOption 申请加群处理方式
   * @param {Array.<Object>} options.memberList 初始群成员列表
   * @param {Array.<Object>} options.groupCustomField 群组维度的自定义字段
   * @returns {Promise}
   */
  public createGroup(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.createGroup(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 删除群组
   *
   * @param {String} groupID 群组ID
   * @returns {Promise}
   */
  public dismissGroup(groupID: string): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.dismissGroup(groupID);
        this.store.groupProfile = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 修改群组资料
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {String} options.name 群组名称
   * @param {String} options.introduction 群简介
   * @param {String} options.notification 群公告
   * @param {String} options.avatar 群头像 URL
   * @param {Number} options.maxMemberNum 最大群成员数量
   * @param {Number} options.joinOption 申请加群处理方式
   * @param {Array.<Object>} options.groupCustomField 群组维度的自定义字段
   * @returns {Promise}
   */
  public updateGroupProfile(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.updateGroupProfile(options);
        this.store.groupProfile = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 申请加群
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {String} options.applyMessage 附言
   * @param {String} options.type 群组类型
   * @returns {Promise}
   */
  public joinGroup(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.joinGroup(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 退出群组
   *
   * @param {String} groupID 群组ID
   * @returns {Promise}
   */
  public quitGroup(groupID: string): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.quitGroup(groupID);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 通过 groupID 搜索群组
   *
   * @param {String} groupID 群组ID
   * @returns {Promise}
   */
  public searchGroupByID(groupID: string): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.searchGroupByID(groupID);
        this.store.searchGroup = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群在线人数
   * - 只用于查询直播群在线人数
   *
   * @param {String} groupID 群组ID
   * @returns {Promise}
   */
  public getGroupOnlineMemberCount(groupID: string): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupOnlineMemberCount(groupID);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 转让群组
   * - 只有群主有权限操作
   *
   * @param {any} options 参数
   * @param {String} options.groupID 待转让的群组 ID
   * @param {String} options.newOwnerID 新群主的 ID
   * @returns {Promise}
   */
  public changeGroupOwner(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.changeGroupOwner(options);
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
  public handleGroupApplication(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.handleGroupApplication(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 初始化群属性
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Object} options.groupAttributes 群属性
   * @returns {Promise}
   */
  public initGroupAttributes(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.initGroupAttributes(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 设置群属性
   * - 仅适用于直播群
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Object} options.groupAttributes 群属性
   * @returns {Promise}
   */
  public setGroupAttributes(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.setGroupAttributes(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 删除群属性
   * - 仅适用于直播群
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.keyList 群属性 key 列表
   * @returns {Promise}
   */
  public deleteGroupAttributes(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.deleteGroupAttributes(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群属性
   * - 仅适用于直播群
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.keyList 群属性 key 列表
   * @returns {Promise}
   */
  public getGroupAttributes(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupAttributes(options);
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
  public getGroupMemberList(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupMemberList(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 添加群成员
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.userIDList 待添加的群成员 ID 数组
   * @returns {Promise}
   */
  public addGroupMember(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.addGroupMember(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 删除群成员
   * - 群主可移除群成员
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.userIDList 待删除的群成员的 ID 列表
   * @param {String} options.reason 踢人的原因
   * @returns {Promise}
   */
  public deleteGroupMember(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.deleteGroupMember(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 设置群成员的禁言时间
   * - 只有群主和管理员拥有该操作权限
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {String} options.userID 用户 ID
   * @param {Number} options.muteTime 禁言时长，单位秒; 设为0，则表示取消禁言。
   * @returns {Promise}
   */
  public setGroupMemberMuteTime(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.setGroupMemberMuteTime(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 修改群成员角色
   * - 群主拥有操作的权限
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {String} options.userID 用户 ID
   * @param {String} options.role 可选值：TIM.TYPES.GRP_MBR_ROLE_ADMIN（群管理员）,TIM.TYPES.GRP_MBR_ROLE_MEMBER（群普通成员）,TIM.TYPES.GRP_MBR_ROLE_CUSTOM（自定义群成员角色，仅社群支持）
   * @returns {Promise}
   */
  public setGroupMemberRole(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.setGroupMemberRole(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 设置群成员名片
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {String} options.userID 可选，默认修改自身的群名片
   * @param {String} options.nameCard 群成员名片
   * @returns {Promise}
   */
  public setGroupMemberNameCard(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.setGroupMemberNameCard(options);
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
  public getGroupMemberProfile(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupMemberProfile(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 赋值
   *
   * @param {Object} params 使用的数据
   * @returns {Object} 数据
   */
  public async bind(params: any) {
    this.currentStore = params;
    await this.getGroupList();
    return this.currentStore;
  }
}
