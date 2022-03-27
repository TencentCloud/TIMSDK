import timRenderInstance from "./utils/timRenderInstance";


interface CallbackData {
    type: string,
    data: any
}

interface InitListenersCallback {
    (data: CallbackData):void;
}

export default function initListeners(callback:InitListenersCallback){


    /**
     * 注销消息监听事件
     */
    timRenderInstance.TIMRemoveRecvNewMsgCallback()
    /**
    * @brief 增加接收新消息回调
    * @param cb 新消息回调函数，请参考[TIMRecvNewMsgCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note 
    * 如果用户是登录状态，ImSDK收到新消息会通过此接口设置的回调抛出，另外需要注意，抛出的消息不一定是未读的消息，
    * 只是本地曾经没有过的消息（例如在另外一个终端已读，拉取最近联系人消息时可以获取会话最后一条消息，如果本地没有，会通过此方法抛出）。
    * 在用户登录之后，ImSDK会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知。
    */
    timRenderInstance.TIMAddRecvNewMsgCallback({
        callback:(args)=>{
            callback({
                type: 'TIMAddRecvNewMsgCallback',
                data: JSON.parse(args[0])
            })
        },
        user_data: "test"
    })


    /**
    * @brief 1.3 设置消息已读回执回调
    * @param cb 消息已读回执回调，请参考[TIMMsgReadedReceiptCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note 
    * 发送方发送消息，接收方调用接口[TIMMsgReportReaded]()上报该消息已读，发送方ImSDK会通过此接口设置的回调抛出。
    */
    timRenderInstance.TIMSetMsgReadedReceiptCallback({
        callback:(...args)=>{
            callback({
                type: 'TIMSetMsgReadedReceiptCallback',
                data: JSON.parse(args[0][0])
            })
        },
        user_data: "test"
    })


    /**
    * @brief 1.4 设置接收的消息被撤回回调
    * @param cb 消息撤回通知回调,请参考[TIMMsgRevokeCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note 
    * 发送方发送消息，接收方收到消息。此时发送方调用接口[TIMMsgRevoke]()撤回该消息，接收方的ImSDK会通过此接口设置的回调抛出。
    */
    timRenderInstance.TIMSetMsgRevokeCallback({
        callback:(args)=>{
            callback({
                type: 'TIMSetMsgRevokeCallback',
                data: JSON.parse(args[0])
            });
        },
        user_data: "test"
    })



    /**
    * @brief 1.5 设置消息内元素相关文件上传进度回调
    * @param cb 文件上传进度回调，请参考[TIMMsgElemUploadProgressCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note
    * 设置消息元素上传进度回调。当消息内包含图片、声音、文件、视频元素时，ImSDK会上传这些文件，并触发此接口设置的回调，用户可以根据回调感知上传的进度
    */
    timRenderInstance.TIMSetMsgElemUploadProgressCallback({
        callback:(args)=>{
            const [message, index, cur_size, total_size, user_data] = args 
            callback({
                type: 'TIMSetMsgElemUploadProgressCallback',
                data: {
                    message: JSON.parse(message),
                    index,
                    cur_size,
                    total_size,
                    user_data
                }
            })
        },
        user_data: "test"
    })

    /**
    * @brief 1.6 设置群组系统消息回调
    * @param cb 群消息回调，请参考[TIMGroupTipsEventCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note 
    * 群组系统消息事件包括 加入群、退出群、踢出群、设置管理员、取消管理员、群资料变更、群成员资料变更。此消息是针对所有群组成员下发的
    */
    timRenderInstance.TIMSetGroupTipsEventCallback({
        callback:(args)=>{
            callback({
                type: 'TIMSetGroupTipsEventCallback',
                data:  JSON.parse(args[0])
            })
        },
        user_data: "test"
    })


    /**
    * @brief 1.7 设置群组属性变更回调
    * @param cb 群组属性变更回调，请参考[TIMGroupAttributeChangedCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note 
    * 某个已加入的群的属性被修改了，会返回所在群组的所有属性（该群所有的成员都能收到）
    */
    timRenderInstance.TIMSetGroupAttributeChangedCallback({
        callback:()=>{

        },
        user_data: "test"
    })



    /**
    * @brief 1.8 设置会话事件回调
    * @param cb 会话事件回调，请参考[TIMConvEventCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * > 会话事件包括：
    * >> 会话新增
    * >> 会话删除
    * >> 会话更新。
    * >> 会话开始
    * >> 会话结束
    * > 任何产生一个新会话的操作都会触发会话新增事件，例如调用接口[TIMConvCreate]()创建会话，接收到未知会话的第一条消息等。
    * 任何已有会话变化的操作都会触发会话更新事件，例如收到会话新消息，消息撤回，已读上报等。
    * 调用接口[TIMConvDelete]()删除会话成功时会触发会话删除事件。
    */
    timRenderInstance.TIMSetConvEventCallback({
        callback:(...args)=>{
            callback({
                type: 'TIMSetConvEventCallback',
                data: {
                    type:args[0][0],
                    data:args[0][1]!=="" ? JSON.parse(args[0][1]) : []
                }
            })
        },
        user_data:"TIMSetConvEventCallback"
    })

    /**
    * @brief 1.9 设置会话未读消息总数变更的回调
    * @param cb 会话未读消息总数变更的回调，请参考[TIMConvTotalUnreadMessageCountChangedCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    */
    timRenderInstance.TIMSetConvTotalUnreadMessageCountChangedCallback({
        callback:(...args)=>{
            callback({
                type: 'TIMSetConvTotalUnreadMessageCountChangedCallback',
                data: args[0][0]
            })
        }
    })


    /**
    * @brief 1.10 设置网络连接状态监听回调
    * @param cb 连接事件回调，请参考[TIMNetworkStatusListenerCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note
    * > 当调用接口 [TIMInit]() 时，ImSDK会去连接云后台。此接口设置的回调用于监听网络连接的状态。
    * > 网络连接状态包含四个：正在连接、连接失败、连接成功、已连接。这里的网络事件不表示用户本地网络状态，仅指明ImSDK是否与即时通信IM云Server连接状态。
    * > 可选设置，如果要用户感知是否已经连接服务器，需要设置此回调，用于通知调用者跟通讯后台链接的连接和断开事件，另外，如果断开网络，等网络恢复后会自动重连，自动拉取消息通知用户，用户无需关心网络状态，仅作通知之用
    * > 只要用户处于登录状态，ImSDK内部会进行断网重连，用户无需关心。
    */
    timRenderInstance.TIMSetNetworkStatusListenerCallback({
        callback:()=>{

        }
    })

    /**
    * @brief 1.11 设置被踢下线通知回调
    * @param cb 踢下线回调，请参考[TIMKickedOfflineCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note
    * > 用户如果在其他终端登录，会被踢下线，这时会收到用户被踢下线的通知，出现这种情况常规的做法是提示用户进行操作（退出，或者再次把对方踢下线）。
    * > 用户如果在离线状态下被踢，下次登录将会失败，可以给用户一个非常强的提醒（登录错误码ERR_IMSDK_KICKED_BY_OTHERS：6208），开发者也可以选择忽略这次错误，再次登录即可。
    * > 用户在线情况下的互踢情况：
    * +  用户在设备1登录，保持在线状态下，该用户又在设备2登录，这时用户会在设备1上强制下线，收到 TIMKickedOfflineCallback 回调。
    *    用户在设备1上收到回调后，提示用户，可继续调用login上线，强制设备2下线。这里是在线情况下互踢过程。
    * > 用户离线状态互踢:
    * +  用户在设备1登录，没有进行logout情况下进程退出。该用户在设备2登录，此时由于用户不在线，无法感知此事件，
    *    为了显式提醒用户，避免无感知的互踢，用户在设备1重新登录时，会返回（ERR_IMSDK_KICKED_BY_OTHERS：6208）错误码，表明之前被踢，是否需要把对方踢下线。
    *    如果需要，则再次调用login强制上线，设备2的登录的实例将会收到 TIMKickedOfflineCallback 回调。
    */
    timRenderInstance.TIMSetKickedOfflineCallback({
        callback:(...args)=>{
            callback({
                type: 'TIMSetKickedOfflineCallback',
                data: args
            })
        }
    })


    /**
    * @brief 1.12 设置票据过期回调
    * @param cb 票据过期回调，请参考[TIMUserSigExpiredCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * 用户票据，可能会存在过期的情况，如果用户票据过期，此接口设置的回调会调用。
    * [TIMLogin]()也将会返回70001错误码。开发者可根据错误码或者票据过期回调进行票据更换
    */
    timRenderInstance.TIMSetUserSigExpiredCallback({
        callback:()=>{

        }
    })


    /**
    * @brief 1.13 设置添加好友的回调
    * @param cb 添加好友回调，请参考[TIMOnAddFriendCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * 此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备添加了好友，B设备ImSDK会收到添加好友的推送，ImSDK通过此回调告知开发者。
    */
    timRenderInstance.TIMSetOnAddFriendCallback({
        callback:(...args)=>{
            console.log('=====添加好友=====', args);
        }
    })


    /**
    * @brief 1.14 设置删除好友的回调
    * @param cb 删除好友回调，请参考[TIMOnDeleteFriendCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * 此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备删除了好友，B设备ImSDK会收到删除好友的推送，ImSDK通过此回调告知开发者。
    */
    timRenderInstance.TIMSetOnDeleteFriendCallback({
        callback:()=>{

        }
    })

    /**
    * @brief 1.15 设置更新好友资料的回调
    * @param cb 更新好友资料回调，请参考[TIMUpdateFriendProfileCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * 此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备更新了好友资料，B设备ImSDK会收到更新好友资料的推送，ImSDK通过此回调告知开发者。
    */
    timRenderInstance.TIMSetUpdateFriendProfileCallback({
        callback:()=>{

        }
    })


    /**
    * @brief 1.16 设置好友添加请求的回调
    * @param cb 好友添加请求回调，请参考[TIMFriendAddRequestCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * 当前登入用户设置添加好友需要确认时，如果有用户请求加当前登入用户为好友，会收到好友添加请求的回调，ImSDK通过此回调告知开发者。如果多终端登入同一帐号，每个终端都会收到这个回调。
    */
    timRenderInstance.TIMSetFriendAddRequestCallback({
        callback: (...args)=>{
            console.log('=====添加好友请求=====', JSON.parse(args[0][0]));
            callback({
                type: 'TIMSetFriendAddRequestCallback',
                data: JSON.parse(args[0][0])
            })
        }
    })


    /**
    * @brief 1.17 设置好友申请删除的回调
    * @param cb 好友申请删除回调，请参考[TIMFriendApplicationListDeletedCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note 
    *  1. 主动删除好友申请
    *  2. 拒绝好友申请
    *  3. 同意好友申请
    *  4. 申请加别人好友被拒绝
    */
    timRenderInstance.TIMSetFriendApplicationListDeletedCallback({
        callback:()=>{

        }
    })

    /**
    * @brief 1.18 设置好友申请已读的回调
    * @param cb 好友申请已读回调，请参考[TIMFriendApplicationListReadCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    * @note
    * 如果调用 setFriendApplicationRead 设置好友申请列表已读，会收到这个回调（主要用于多端同步）
    */

    timRenderInstance.TIMSetFriendApplicationListReadCallback({
        callback:()=>{

        }
    })


    /**
    * @brief 1.19 设置黑名单新增的回调
    * @param cb 黑名单新增的回调，请参考[TIMFriendBlackListAddedCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    */
    timRenderInstance.TIMSetFriendBlackListAddedCallback({
        callback:()=>{

        }
    })

    /**
    * @brief  1.20 设置黑名单删除的回调
    * @param cb 黑名单删除的回调，请参考[TIMFriendBlackListDeletedCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    *
    */
    timRenderInstance.TIMSetFriendBlackListDeletedCallback({
        callback:()=>{

        }
    })


    /**
    * @brief 1.22 设置消息在云端被修改后回传回来的消息更新通知回调
    * @param cb 消息更新回调，请参考[TIMMsgUpdateCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * 
    * @note 
    * > 当您发送的消息在服务端被修改后，ImSDK会通过该回调通知给您 
    * > 您可以在您自己的服务器上拦截所有即时通信IM消息 [发单聊消息之前回调](https://cloud.tencent.com/document/product/269/1632)
    * > 设置成功之后，即时通信IM服务器会将您的用户发送的每条消息都同步地通知给您的业务服务器。
    * > 您的业务服务器可以对该条消息进行修改（例如过滤敏感词），如果您的服务器对消息进行了修改，ImSDK就会通过此回调通知您。
    */
    timRenderInstance.TIMSetMsgUpdateCallback({
        callback:()=>{

        }
    })
    timRenderInstance.TIMOnInvited({
        callback:(data)=>{
            callback({
                type: 'TIMOnInvited',
                data: data
            })
        }
    })
    timRenderInstance.TIMOnRejected({
        callback:(data)=>{
            callback({
                type: 'TIMOnRejected',
                data: data
            })
        }
    })
    timRenderInstance.TIMOnAccepted({
        callback:(data)=>{
            callback({
                type: 'TIMOnAccepted',
                data: data
            })
        }
    })
    timRenderInstance.TIMOnCanceled({
        callback:(data)=>{
            callback({
                type: 'TIMOnCanceled',
                data: data
            })
        }
    })
    
    timRenderInstance.TIMOnTimeout({
        callback:(data)=>{
            callback({
                type: 'TIMOnTimeout',
                data: data
            })
        }
    })
}