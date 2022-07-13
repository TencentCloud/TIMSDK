import Foundation
import ImSDK_Plus
import Hydra

class MessageManager {
	private var advancedMessageListener: AdvancedMsgListener = AdvancedMsgListener();

    // 存放创建出的临时消息
    var messageDict =  [String: V2TIMMessage]()
	
     func clearMessageMap(id:String? = nil){
        if( id != nil){
            messageDict.removeValue(forKey: id!);
        }
    }
    
    func getMessageMapId() -> String{
        let timeInterval = Date().timeIntervalSince1970;
        let millisecond = CLongLong(round(timeInterval*1000));
        return String(millisecond);
    }

    func getElem(message:V2TIMMessage) -> V2TIMElem {
        let type = message.elemType;
        if(type == V2TIMElemType.ELEM_TYPE_TEXT){
            return message.textElem;
        } else if(type == V2TIMElemType.ELEM_TYPE_CUSTOM){
            return message.customElem;
        } else if(type == V2TIMElemType.ELEM_TYPE_FACE){
            return message.faceElem
        } else if(type == V2TIMElemType.ELEM_TYPE_FILE){
            return message.fileElem
        } else if(type == V2TIMElemType.ELEM_TYPE_GROUP_TIPS){
            return message.groupTipsElem
        } else if(type == V2TIMElemType.ELEM_TYPE_IMAGE){
            return message.imageElem
        } else if(type == V2TIMElemType.ELEM_TYPE_LOCATION){
            return message.locationElem
        } else if(type == V2TIMElemType.ELEM_TYPE_MERGER){
            return message.mergerElem
        } else if(type == V2TIMElemType.ELEM_TYPE_SOUND){
            return message.soundElem
        } else if(type == V2TIMElemType.ELEM_TYPE_VIDEO){
            return message.videoElem
        } else{
            return message.textElem
        }
       
    }
    func setAppendMessage(appendMess:V2TIMMessage,baseMessage:V2TIMMessage){
        let bElem = getElem(message: baseMessage)
        let Aelem = getElem(message: appendMess)
        bElem.append(Aelem)
    }
    func appendMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){
        let createMessageBaseId = param["createMessageBaseId"] as? String ?? "";
        let createMessageAppendId = param["createMessageAppendId"] as? String ?? "";
        
        if(messageDict.keys.contains(createMessageBaseId) && messageDict.keys.contains(createMessageAppendId)){
            let baseMessage = messageDict[createMessageBaseId]!
            let appendMessage = messageDict[createMessageAppendId]!
            setAppendMessage(appendMess: appendMessage,baseMessage: baseMessage)
            CommonUtils.resultSuccess(method: "appendMessage", resolve: resolve, data: V2MessageEntity.init(message: baseMessage).getDict())
        }else {
            CommonUtils.resultFailed(desc: "message not found", code: -1, method: "appendMessage", resolve: resolve)
        }
    }
    
    func modifyMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        let message = param["message"] as? [String:Any];
        let msgID = message?["msgID"]
        if(msgID == nil){
            CommonUtils.resultFailed(desc: "message not found", code: -1, method: "modifyMessage",resolve: resolve)
            return
        }
        var msgIDList:[String] = [];
        
        msgIDList.append(msgID as! String)
        
        V2TIMManager.sharedInstance().findMessages(msgIDList) { messages in
            if(messages?.count == 1){
                
                if(message?["cloudCustomData"] != nil){
                    messages?[0].cloudCustomData = (message?["cloudCustomData"]  as! String).data(using: .utf8)
                }
                if(message?["localCustomInt"] != nil){
                    messages?[0].localCustomInt = message?["localCustomInt"] as! Int32
                }
                if(message?["localCustomData"] != nil){
                    messages?[0].localCustomData = (message?["localCustomData"] as! String ).data(using: .utf8)
                }
                if(messages?[0].elemType == V2TIMElemType.ELEM_TYPE_TEXT){
                    let textElem:[String:String] = message?["textElem"] as! [String : String];
                    messages?[0].textElem.text = textElem["text"];
                }
                if(messages?[0].elemType == V2TIMElemType.ELEM_TYPE_CUSTOM){
                    let customElem:[String:Any] = message?["customElem"] as! [String : Any];
                    messages?[0].customElem.data = (customElem["data"] as? String)?.data(using: .utf8)
                    messages?[0].customElem.desc = customElem["desc"]  as? String
                    messages?[0].customElem.extension = customElem["extension"] as? String ;
                }
                
                async({
                    _ -> Int in
                    
                   V2TIMManager.sharedInstance().modifyMessage(messages?[0]) { code,desc,modifyedMessage  in
                        
                        var res:[String:Any] = [:]
                        res["code"] = code
                        res["desc"] = desc
                        res["message"] = V2MessageEntity.init(message: modifyedMessage!).getDict()
                        
                        
                        CommonUtils.resultSuccess(method: "", resolve: resolve, data: res)
                    }
                    return 1
                }).then({
                    value in
                })
                
            }else{
                CommonUtils.resultFailed(desc: "message not found", code: -1, method: "modifyMessage",resolve: resolve)
            }
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "modifyMessage",resolve: resolve)
        }

    }
	
    func setMessageMapProcess(method: String, resolve: @escaping RCTPromiseResolveBlock,message: V2TIMMessage){
        let millisecond = self.getMessageMapId();
        messageDict.updateValue(message, forKey: millisecond);
        
        var resultDict =  [String: Any]();
        var dict = V2MessageEntity.init(message: message).getDict();
        dict["id"] = millisecond;
        
        resultDict.updateValue(millisecond, forKey: "id");
        resultDict.updateValue(dict, forKey: "messageInfo");
        
        CommonUtils.resultSuccess(method: method, resolve: resolve,data: resultDict);
    }
    
    func createMessageProcess(param: [String: Any],method: String, resolve: @escaping RCTPromiseResolveBlock, type: Int){
        let message = TencentImUtils.createMessage(param: param, resolve: resolve, type: type);
        setMessageMapProcess(method: "", resolve: resolve, message: message);
    }

	func createTargetedGroupMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){
        if let receiverIDList = param["receiverList"] as? [String],
           let id = param["id"] as? String {
            let message = messageDict[id];
            
            let array: NSMutableArray = [];
            
            for receiverId in receiverIDList  {
                array.add(receiverId)
            }

            let newMsg = V2TIMManager.sharedInstance()?.createTargetedGroupMessage(message, receiverList: array)
        self.clearMessageMap(id: id);
        setMessageMapProcess(method: "createTargetedGroupMessage", resolve: resolve, message: newMsg ?? V2TIMMessage());
        }
    }
    
    func createTextMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
        createMessageProcess(param: param, method: "createTextMessage", resolve: resolve, type: type);
    }
    
    func createCustomMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
        createMessageProcess(param: param, method: "createCustomMessage", resolve: resolve, type: type);
    }
    
    func createImageMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
        createMessageProcess(param: param, method: "createImageMessage", resolve: resolve, type: type);
    }
    
    func createSoundMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
		createMessageProcess(param: param, method: "createSoundMessage", resolve: resolve, type: type);
    }
    
    func createVideoMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
		createMessageProcess(param: param, method: "createVideoMessage", resolve: resolve, type: type);
    }
    func createFileMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
		createMessageProcess(param: param, method: "createFileMessage", resolve: resolve, type: type);
    }
    func createTextAtMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
		createMessageProcess(param: param, method: "createTextAtMessage", resolve: resolve, type: type);
    }
    
    func createLocationMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
		createMessageProcess(param: param, method: "createLocationMessage", resolve: resolve, type: type);
    }
    
    func createFaceMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
		createMessageProcess(param: param, method: "createFaceMessage", resolve: resolve, type: type);
    }
    
    

    func sendMessageOldEdition(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, message: V2TIMMessage, id: String? = nil) {
		let groupID = param["groupID"] as? String;
		let receiver = param["receiver"] as? String;
		let priority = param["priority"] as? Int;
		let onlineUserOnly = param["onlineUserOnly"] as? Bool;
        let v2TIMOfflinePushInfo = CommonUtils.getV2TIMOfflinePushInfo(param: param);
		let succ = {
			() -> Void in
				
			async({
				_ -> Dictionary<String, Any> in
				
				let ret = try Hydra.await(V2MessageEntity.init(message: message).getDictAll())
				return ret
            }).then({
                        var _data = $0;
                        _data["priority"] = priority;
                        _data["id"] = id;
                        self.clearMessageMap(id: id);
                        CommonUtils.resultSuccess(method: "", resolve: resolve, data: _data) })
		}
		
		let progressfn = {
			progress -> Void in
			
            var msg = V2MessageEntity.init(message: message).getDict();
            msg["id"] = id; // 只有progress时需要传递id
            msg["progress"] = progress;
			CommonUtils.emmitEvent(eventName: "messageListener", eventType: ListenerType.onSendMessageProgress, data: ["progress": progress, "message": msg]);
		} as V2TIMProgress
		
		let fail = {
			(code: Int32, desc: Optional<String>) -> Void in
			
			async({
				_ -> Dictionary<String, Any> in
				
				let ret = try Hydra.await(V2MessageEntity.init(message: message).getDictAll())
				return ret
			}).then({
                var _data = $0;
                _data["id"] = id;
                self.clearMessageMap(id: id);
                CommonUtils.resultFailed(desc: desc, code: code, data: _data, method: "", resolve: resolve) })
		}
		
		V2TIMManager.sharedInstance()?.send(
			message,
			receiver: receiver ?? message.userID,
			groupID: groupID ?? message.groupID,
			priority: V2TIMMessagePriority(rawValue: priority ?? 0)!,
			onlineUserOnly: onlineUserOnly ?? false,
			offlinePushInfo: v2TIMOfflinePushInfo,
			progress: progressfn,
			succ: succ,
			fail: fail
		);
	}
    
    func sendMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        let id =  param["id"] as! String; // 自定义id
        if let message = messageDict[id] {
            self.setCustomDataBeforSend(param: param, message: message);
            sendMessageOldEdition(param: param, resolve: resolve, message: message, id: id);
        } else {
            CommonUtils.resultFailed(desc: "id not exist,please create message again", code: -1, method: "sendMessage", resolve: resolve);
        };
    }
	
	func sendMessageOldEdition(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock, type: Int) {
        let message = TencentImUtils.createMessage(param: param, resolve: resolve, type: type)
        sendMessageOldEdition(param: param, resolve: resolve, message: message);
	}
    
    func createForwardMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        if let msgID = param["msgID"] as? String {
            V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
                (msgs) -> Void in
                
                if msgs?.count != nil && msgs?.count != 0 {
                    let message = V2TIMManager.sharedInstance()?.createForwardMessage(msgs![0])
                    self.setMessageMapProcess(method: "createForwardMessage", resolve: resolve, message: message!);
                } else {
                    CommonUtils.resultFailed(desc: "msg is not exist", code: -1, method: "createForwardMessage", resolve: resolve)
                }
            }, fail: TencentImUtils.returnErrorClosures(method: "createForwardMessage", resolve: resolve))
        }
    }

	func sendForwardMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let message = V2TIMManager.sharedInstance()?.createForwardMessage(msgs![0])
					self.sendMessageOldEdition(param: param, resolve: resolve, message: message!)
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, method: "sendForwardMessage", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "sendForwardMessage", resolve: resolve))
		}
	}
	
	func reSendMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String {
			// 注意：这个findMessages 返回的对象是V2TIMMessage类型，其中不返回优先级 导致我们无法顺利拿到priority
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
				(msgs) -> Void in
				
				if msgs != nil && msgs?.count != 0 {
					let msg = msgs![0] as V2TIMMessage
					self.sendMessageOldEdition(param: param, resolve: resolve, message: msg)
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, method: "reSendMessage", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "reSendMessage", resolve: resolve))
		}
	}
    

	
    func downloadMergerMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] :[msgID],succ:{
						(msgs) -> Void in
						
						if msgs?.count != nil && msgs?.count != 0 {
							let msg = msgs![0] as V2TIMMessage
							if let elem = msg.mergerElem {
								elem.downloadMergerMessage({
									msgList -> Void in
									var messageList: [[String: Any]] = []
									async(
										{
											_ -> Int in
											for i in msgList! {

												messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
											}
											CommonUtils.resultSuccess(method: "downloadMergerMessage", resolve: resolve, data: messageList)

											return 1
										}
									).then({
										value in
									})
								},fail:TencentImUtils.returnErrorClosures(method: "downloadMergerMessage", resolve: resolve))
							} else {
								CommonUtils.resultFailed(desc: "this message is not merge element", code: -1, method: "downloadMergerMessage", resolve: resolve)
							}
						} else {
							CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "downloadMergerMessage", resolve: resolve)
						}
					},fail:TencentImUtils.returnErrorClosures(method: "downloadMergerMessage", resolve: resolve))
		}
        
    }
    
    func createMergerMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){
        if let msgIDList = param["msgIDList"] as? [String],
           let abstractList = param["abstractList"] as? [String],
           let compatibleText = param["compatibleText"] as? String,
           let title = param["title"] as? String {
            V2TIMManager.sharedInstance()?.findMessages(msgIDList, succ: {
                (msgs) -> Void in
                
                if msgs?.count != nil && msgs?.count != 0 {
                    if let message = V2TIMManager.sharedInstance()?.createMergerMessage(msgs, title: title, abstractList: abstractList, compatibleText: compatibleText){
                        self.setMessageMapProcess(method: "createMergerMessage", resolve: resolve, message: message);
                    }
                    else
                        {CommonUtils.resultFailed(desc: "create merge msgs fail", code: -1, method: "createMergerMessage", resolve: resolve)}
                } else {
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "createMergerMessage", resolve: resolve)
                }
            }, fail: TencentImUtils.returnErrorClosures(method: "createMergerMessage", resolve: resolve))
        }
    }

	func sendMergerMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgIDList = param["msgIDList"] as? [String],
		   let abstractList = param["abstractList"] as? [String],
		   let compatibleText = param["compatibleText"] as? String,
		   let title = param["title"] as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgIDList, succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let message = V2TIMManager.sharedInstance()?.createMergerMessage(msgs, title: title, abstractList: abstractList, compatibleText: compatibleText)
					self.sendMessageOldEdition(param: param, resolve: resolve, message: message!)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "sendMergerMessage", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "sendMergerMessage", resolve: resolve))
		}
	}
	
	func setC2CReceiveMessageOpt(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let userIDList = param["userIDList"] as? [String],
		   let opt = param["opt"] as? Int {
			V2TIMManager.sharedInstance()?.setC2CReceiveMessageOpt(userIDList, opt: V2TIMReceiveMessageOpt.init(rawValue: opt)!, succ: {
					() -> Void in
					CommonUtils.resultSuccess(method: "setC2CReceiveMessageOpt", resolve: resolve, data: "ok")
				}, fail: TencentImUtils.returnErrorClosures(method: "setC2CReceiveMessageOpt", resolve: resolve)
			)
		}
	}
	
	func setGroupReceiveMessageOpt(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let groupID = param["groupID"] as? String,
		   let opt = param["opt"] as? Int {
			V2TIMManager.sharedInstance()?.setGroupReceiveMessageOpt(groupID, opt: V2TIMReceiveMessageOpt.init(rawValue: opt)!, succ: {
					() -> Void in
					CommonUtils.resultSuccess(method: "setGroupReceiveMessageOpt", resolve: resolve, data: "ok")
				}, fail: TencentImUtils.returnErrorClosures(method: "setGroupReceiveMessageOpt", resolve: resolve)
			)
		}
	}
	
	func getC2CReceiveMessageOpt(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let userIDList = param["userIDList"] as? [String] {
			V2TIMManager.sharedInstance()?.getC2CReceiveMessageOpt(userIDList, succ: {
				let dict = $0!.map { [
                    "c2CReceiveMessageOpt": Int($0.receiveOpt.rawValue),
					"userID": $0.userID ?? ""
				] }
				CommonUtils.resultSuccess(method: "getC2CReceiveMessageOpt", resolve: resolve, data: dict)
			}, fail: TencentImUtils.returnErrorClosures(method: "getC2CReceiveMessageOpt", resolve: resolve))
		}
	}
	
	func getC2CHistoryMessageList(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let count = param["count"] as? Int32,
		   let userID = param["userID"] as? String {
			let lastMsgID = param["lastMsgID"] as? String
			
			if lastMsgID != nil {
				V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
					(msgs) -> Void in
					
					let lastMsg = msgs!.isEmpty ? nil : msgs![0]
					if lastMsg != nil {
						self.getC2CHistoryMessageListFn(userID: userID, count: count, lastMsg: lastMsg!, resolve: resolve, method: "getC2CHistoryMessageList")
					}
					
				}, fail: TencentImUtils.returnErrorClosures(method: "getC2CHistoryMessageList", resolve: resolve));
			} else {
				getC2CHistoryMessageListFn(userID: userID, count: count, lastMsg: nil, resolve: resolve, method: "getC2CHistoryMessageList")
			}
			
		}
	}
	
	func getC2CHistoryMessageListFn(userID: String, count: Int32, lastMsg: V2TIMMessage?, resolve: @escaping RCTPromiseResolveBlock, method: String) {
		V2TIMManager.sharedInstance()?.getC2CHistoryMessageList(userID, count: count, lastMsg: lastMsg, succ: {
			msgs -> Void in
			
			var messageList: [[String: Any]] = []
			
			async({
				_ -> Int in
				
				for i in msgs! {
					
					messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
				}
				CommonUtils.resultSuccess(method: method, resolve: resolve, data: messageList)
				
				return 1
			}).then({
				value in
			})
		}, fail: TencentImUtils.returnErrorClosures(method: method, resolve: resolve))
	}
	
	
	func getHistoryMessageList(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let lastMsgID = param["lastMsgID"] as? String
		let count = param["count"] as? UInt
	    let userID = param["userID"] as? String
		let groupID = param["groupID"] as? String
		let getType = param["getType"] as? Int
        let lastMsgSeq = param["lastMsgSeq"] as? Int
        let messageTypeList = param["messageTypeList"] as? Array<Int>
		let option = V2TIMMessageListGetOption();
		
		if groupID != nil && userID != nil {
			CommonUtils.resultFailed(desc: "groupID和userID只能设置一个", code: -1, method: "getHistoryMessageList", resolve: resolve)
		}
		if count != nil {
			option.count = count!
		}
		if userID != nil {
			option.userID = userID
		}
		if groupID != nil {
			option.groupID = groupID
		}
		if getType != nil {
			option.getType = V2TIMMessageGetType.init(rawValue: getType!)!
		}
        if let lastMsgSeq = lastMsgSeq {
            if (lastMsgSeq >= 0) {
                option.lastMsgSeq = UInt(lastMsgSeq)
            }
        }
        if(messageTypeList != nil){
            option.messageTypeList = messageTypeList?.map({ value in
                return NSNumber.init(value: value)
            });
        }
		if lastMsgID != nil {
			V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
				(msgs) -> Void in
				let lastMsg = msgs!.isEmpty ? nil : msgs![0]
				if lastMsg != nil {
					option.lastMsg = lastMsg
					self.getHistoryMessageListFn(option: option, resolve: resolve, method: "getHistoryMessageList")
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "getHistoryMessageList", resolve: resolve));
		} else {
			getHistoryMessageListFn(option: option, resolve: resolve, method: "getHistoryMessageList")
		}
	}

	func getHistoryMessageListFn(option: V2TIMMessageListGetOption, resolve: @escaping RCTPromiseResolveBlock, method: String) {
		V2TIMManager.sharedInstance()?.getHistoryMessageList(option, succ: {
			msgs -> Void in

			var messageList: [[String: Any]] = []

			async({ _ -> Int in
				for i in msgs! {

					messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
				}
				CommonUtils.resultSuccess(method: method, resolve: resolve, data: messageList)

				return 1
			}).then({
				value in
			})
		}, fail: TencentImUtils.returnErrorClosures(method: method, resolve: resolve))
	}
	
	func getGroupHistoryMessageList(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let count = param["count"] as? Int32,
		   let groupID = param["groupID"] as? String {
			let lastMsgID = param["lastMsgID"] as? String
			
			if lastMsgID != nil {
				V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
					(msgs) -> Void in
					
					let lastMsg = msgs!.isEmpty ? nil : msgs![0]
					if lastMsg != nil {
						self.getGroupHistoryMessageListFn(groupID: groupID, count: count, lastMsg: lastMsg!, resolve: resolve, method: "getGroupHistoryMessageList")
					}
				}, fail: TencentImUtils.returnErrorClosures(method: "getGroupHistoryMessageList", resolve: resolve));
			} else {
				getGroupHistoryMessageListFn(groupID: groupID, count: count, lastMsg: nil, resolve: resolve, method: "getGroupHistoryMessageList")
			}
		}
	}
	
	func getGroupHistoryMessageListFn(groupID: String, count: Int32, lastMsg: V2TIMMessage?, resolve: @escaping RCTPromiseResolveBlock, method: String) {
		V2TIMManager.sharedInstance()?.getGroupHistoryMessageList(groupID, count: count, lastMsg: lastMsg, succ: {
			msgs -> Void in
			
			var messageList: [[String: Any]] = []
			
			async({
				_ -> Int in
				
				for i in msgs ?? [] {
					
					messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
				}
				CommonUtils.resultSuccess(method: method, resolve: resolve, data: messageList)
				
				return 1
			}).then({
				value in
			})
			
		}, fail: TencentImUtils.returnErrorClosures(method: method, resolve: resolve))
	}
	
	public func revokeMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().revokeMessage(msgs![0], succ: {
					CommonUtils.resultSuccess(method: "revokeMessage", resolve: resolve)
				}, fail: TencentImUtils.returnErrorClosures(method: "revokeMessage", resolve: resolve))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "revokeMessage", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "revokeMessage", resolve: resolve));
		}
	}
	
	
	public func markC2CMessageAsRead(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let userID = param["userID"] as? String {
			V2TIMManager.sharedInstance().markC2CMessage(asRead: userID, succ: {
				CommonUtils.resultSuccess(method: "markC2CMessageAsRead", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "markC2CMessageAsRead", resolve: resolve))
		}
	}
	
	func markGroupMessageAsRead(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		
		V2TIMManager.sharedInstance()?.markGroupMessage(asRead: groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "markGroupMessageAsRead", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "markGroupMessageAsRead", resolve: resolve));
	}

	func markAllMessageAsRead(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance()?.markAllMessage(asRead: {
            () -> Void in
            
            CommonUtils.resultSuccess(method: "markAllMessageAsRead", resolve: resolve)
        }, fail: TencentImUtils.returnErrorClosures(method: "markAllMessageAsRead", resolve: resolve))
	}
	
	func deleteMessageFromLocalStorage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().deleteMessage(fromLocalStorage: msgs![0], succ: {
					CommonUtils.resultSuccess(method: "deleteMessageFromLocalStorage", resolve: resolve)
				}, fail: TencentImUtils.returnErrorClosures(method: "deleteMessageFromLocalStorage", resolve: resolve))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "deleteMessageFromLocalStorage", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "deleteMessageFromLocalStorage", resolve: resolve));
		}
	}
	
	func deleteMessages(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgIDs = param["msgIDs"] as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().delete(msgs, succ: {
					CommonUtils.resultSuccess(method: "deleteMessages", resolve: resolve)
				}, fail: TencentImUtils.returnErrorClosures(method: "deleteMessages", resolve: resolve))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "deleteMessages", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "deleteMessages", resolve: resolve));
		}
	}

	func sendMessageReadReceipts(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgIDs = param["messageIDList"] as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
                if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().sendMessageReadReceipts(msgs, succ: {
					CommonUtils.resultSuccess(method: "sendMessageReadReceipts", resolve: resolve)
				}, fail: TencentImUtils.returnErrorClosures(method: "sendMessageReadReceipts", resolve: resolve))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "sendMessageReadReceipts", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "sendMessageReadReceipts", resolve: resolve));
		}
	}

	func getMessageReadReceipts(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgIDs = param["messageIDList"] as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
                if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().getMessageReadReceipts(msgs, succ: {
					(_ receiptList: [V2TIMMessageReceipt]!) -> Void in
			
					var data: [[String: Any]] = [];
					for item in receiptList {
						data.append(V2MessageReceiptEntity.getDict(info: item));
					}
					CommonUtils.resultSuccess(method: "getMessageReadReceipts", resolve: resolve,data: data)
				}, fail: TencentImUtils.returnErrorClosures(method: "getMessageReadReceipts", resolve: resolve))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "getMessageReadReceipts", resolve: resolve)
				}
            }, fail: TencentImUtils.returnErrorClosures(method: "getMessageReadReceipts", resolve: resolve));
		}
	}

	func getGroupMessageReadMemberList(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgIDs = param["messageID"] as? String,
		   let filter = param["filter"] as? Int,
		   let seq = param["nextSeq"] as? UInt64,
		   let count = param["count"] as? UInt32 {
			V2TIMManager.sharedInstance()?.findMessages([msgIDs], succ: {
				(msgs) -> Void in
				if msgs?.count != nil  && msgs?.count != 0 {
					let f = V2TIMGroupMessageReadMembersFilter.init(rawValue: filter)!
                    let message = msgs![0]
                    V2TIMManager.sharedInstance().getGroupMessageReadMemberList(message, filter: f, nextSeq: seq, count: count, succ: {
                        (members,nextSeq,isFinished) -> Void in
                            var res: [String: Any] = [:];
                            res["nextSeq"] = nextSeq;
                            res["isFinished"] = isFinished;
                            var data: [[String: Any]] = [];
                            for item in members! {
                                data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item as! V2TIMGroupMemberInfo));
                            }
                            res["memberInfoList"] = data;
                            CommonUtils.resultSuccess(method: "getGroupMessageReadMemberList", resolve: resolve,data: res)
                    }, fail: TencentImUtils.returnErrorClosures(method: "getGroupMessageReadMemberList", resolve: resolve))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "getGroupMessageReadMemberList", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "getGroupMessageReadMemberList", resolve: resolve));
		}
	}
	

	func clearC2CHistoryMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){
		if let userID = param["userID"] as? String {
            V2TIMManager.sharedInstance().clearC2CHistoryMessage(userID, succ: {
                () -> Void in
                CommonUtils.resultSuccess(method: "clearC2CHistoryMessage", resolve: resolve);
            }, fail: TencentImUtils.returnErrorClosures(method: "clearC2CHistoryMessage", resolve: resolve))
		}
	}
	
	func clearGroupHistoryMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){
		if let groupID = param["groupID"] as? String {
            V2TIMManager.sharedInstance().clearGroupHistoryMessage(groupID, succ: {
                CommonUtils.resultSuccess(method: "clearGroupHistoryMessage", resolve: resolve);
            }, fail: TencentImUtils.returnErrorClosures(method: "clearGroupHistoryMessage", resolve: resolve))
		}
	}

	func insertGroupMessageToLocalStorage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let groupID = param["groupID"] as? String,
		   let sender = param["sender"] as? String {
			let message = TencentImUtils.createMessage(param: param, resolve: resolve, type: 2);
			
			var msgID = ""
			let id = V2TIMManager.sharedInstance()?.insertGroupMessage(toLocalStorage: message, to: groupID, sender: sender, succ: {
			   () -> Void in
				
				V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(method: "insertGroupMessageToLocalStorage", resolve: resolve, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "insertGroupMessageToLocalStorage", resolve: resolve)
				}
					
				}, fail: TencentImUtils.returnErrorClosures(method: "insertGroupMessageToLocalStorage", resolve: resolve))
			 }, fail: TencentImUtils.returnErrorClosures(method: "insertGroupMessageToLocalStorage", resolve: resolve))
			
			if(id != nil){
				msgID = id!
			}
			
		}
	}
	
	func insertC2CMessageToLocalStorage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let userID = param["userID"] as? String,
		   let sender = param["sender"] as? String {
			let message = TencentImUtils.createMessage(param: param, resolve: resolve, type: 2);
			
			var msgID = ""
			let id = V2TIMManager.sharedInstance()?.insertC2CMessage(toLocalStorage: message, to: userID, sender: sender, succ: {
			   () -> Void in
				
				V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(method: "insertC2CMessageToLocalStorage", resolve: resolve, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "insertC2CMessageToLocalStorage", resolve: resolve)
				}
				}, fail: TencentImUtils.returnErrorClosures(method: "insertC2CMessageToLocalStorage", resolve: resolve))
			 }, fail: TencentImUtils.returnErrorClosures(method: "insertC2CMessageToLocalStorage", resolve: resolve))
			if(id != nil){
				msgID = id!
			}
			
		}
	}
    // 发送消息前，我们可以对消息 自定义设置云端数据和本地自定义消息
    func setCustomDataBeforSend(param: [String: Any], message: V2TIMMessage) {
        if let data = param["cloudCustomData"] as? String {
            message.cloudCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        if let data = param["localCustomData"] as? String {
            message.localCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
		if let data = param["isExcludedFromUnreadCount"] as? Bool {
            message.isExcludedFromUnreadCount = data;
        }
		if let data = param["isExcludedFromLastMessage"] as? Bool {
            message.isExcludedFromLastMessage = data;
        }
        if let data = param["needReadReceipt"] as? Bool {
            message.needReadReceipt = data;
        }
    }
	
	func setLocalCustomInt(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String,
		   let localCustomInt = param["localCustomInt"] as? Int32 {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].localCustomInt = localCustomInt
					CommonUtils.resultSuccess(method: "setLocalCustomInt", resolve: resolve, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, method: "setLocalCustomInt", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "setLocalCustomInt", resolve: resolve))
		}
	}
	
	func setLocalCustomData(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let msgID = param["msgID"] as? String,
		   let localCustomData = param["localCustomData"] as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].localCustomData = localCustomData.data(using: String.Encoding.utf8, allowLossyConversion: true)
					CommonUtils.resultSuccess(method: "setLocalCustomData", resolve: resolve, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, method: "setLocalCustomData", resolve: resolve)
				}
			}, fail: TencentImUtils.returnErrorClosures(method: "setLocalCustomData", resolve: resolve))
		}
	}

	func searchLocalMessages(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){

        let searchParam = param["searchParam"] as! [String: Any];
        //var l = searchParam["xx"] as! Int;
        let messageSearchParam = V2TIMMessageSearchParam();
        
        if(searchParam["keywordList"] != nil){
            messageSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["conversationID"] != nil){
            messageSearchParam.conversationID = searchParam["conversationID"] as? String ?? nil;
        }
        if(searchParam["messageTypeList"] != nil){
            let messageTypeListLength = (searchParam["messageTypeList"] as! [Any]).count;
            messageSearchParam.messageTypeList = messageTypeListLength == 0 ? nil : searchParam["messageTypeList"] as? [NSNumber];
        }
        if(searchParam["type"] != nil){

            messageSearchParam.keywordListMatchType = searchParam["type"] as! Int == 0 ? V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_OR : V2TIMKeywordListMatchType.KEYWORD_LIST_MATCH_TYPE_AND;
        }
        if(searchParam["pageSize"] != nil){
            messageSearchParam.pageSize = searchParam["pageSize"] as? UInt ?? 20;
        }

        if let searchTimePosition = searchParam["searchTimePosition"] as? UInt {
            messageSearchParam.searchTimePosition = searchTimePosition;
        }
        else {
           messageSearchParam.searchTimePosition = 0;
        }


        if(searchParam["pageIndex"] != nil){
            messageSearchParam.pageIndex = searchParam["pageIndex"] as? UInt ?? 0;
        }

        if let searchTimePeriod = searchParam["searchTimePeriod"] as? UInt {
            messageSearchParam.searchTimePeriod = searchTimePeriod;
        }
        else {
           messageSearchParam.searchTimePeriod = 0;
        }
        
        if(searchParam["userIDList"] != nil){
            let userIDListLength = (searchParam["userIDList"] as! [String]).count;
            messageSearchParam.senderUserIDList = userIDListLength == 0 ? nil : searchParam["userIDList"] as? [String];
        }
        
        
        V2TIMManager.sharedInstance().searchLocalMessages(messageSearchParam, succ: {
                (res) -> Void in
            let list = res?.messageSearchResultItems ?? [];
            var messageSearchResultItems:[Any] = [];
            var map = [String: Any]();
            
            
            for(_,element) in list.enumerated(){
                var messageSearchResultItemMap = [String: Any]();
                messageSearchResultItemMap.updateValue(element.conversationID!, forKey: "conversationID");
                messageSearchResultItemMap.updateValue(element.messageCount, forKey: "messageCount");
                messageSearchResultItemMap.updateValue(CommonUtils.parseMessageListDict(list: element.messageList) , forKey: "messageList");
                messageSearchResultItems.append(messageSearchResultItemMap);
            };
            map.updateValue(res!.totalCount, forKey: "totalCount");
            map.updateValue(messageSearchResultItems, forKey: "messageSearchResultItems")
            CommonUtils.resultSuccess(method: "searchLocalMessages", resolve: resolve, data: map);
            }, fail: TencentImUtils.returnErrorClosures(method: "searchLocalMessages", resolve: resolve))
        
	}
    
    
	func findMessages(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock){
		if let messageIDList = param["messageIDList"] as? [String] {
            V2TIMManager.sharedInstance().findMessages(messageIDList, succ: {
				(msgs) -> Void in
                var messageList: [[String: Any]] = []
                
                async({
                    _ -> Int in
                    
                    for i in msgs! {
                        
                        messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
                    }
                    CommonUtils.resultSuccess(method: "findMessages", resolve: resolve, data: messageList) 
                    return 1
                }).then({
                    value in
                })
            }, fail: TencentImUtils.returnErrorClosures(method: "findMessages", resolve: resolve))
		}
	}

	public func addAdvancedMsgListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.addAdvancedMsgListener(listener: advancedMessageListener)
		CommonUtils.resultSuccess(method: "addAdvancedMsgListener", resolve: resolve, data: "addAdvancedMsgListener is done");
	}

	public func removeAdvancedMsgListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance().removeAdvancedMsgListener(listener: advancedMessageListener);
		CommonUtils.resultSuccess(method: "removeAdvancedMsgListener", resolve: resolve, data: "removeAdvancedMsgListener is done");
	}
}	
