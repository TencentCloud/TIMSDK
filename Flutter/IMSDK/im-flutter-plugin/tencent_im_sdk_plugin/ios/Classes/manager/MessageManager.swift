//
//  MessageManager.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
import ImSDK_Plus
import Hydra

class MessageManager {
	var channel: FlutterMethodChannel
    // 存放创建出的临时消息
    var messageDict =  [String: V2TIMMessage]()
	
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}
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

	func sendC2CTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let text = CommonUtils.getParam(call: call, result: result, param: "text") as! String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as! String;
		
		let msgID = V2TIMManager.sharedInstance()?.sendC2CTextMessage(text, to: userID , succ: {
			() -> Void in
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		
		if msgID is String {
			V2TIMManager.sharedInstance()?.findMessages([msgID!], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					var data = V2MessageEntity.init(message: msgs![0]).getDict()
					data["progress"] = 100
					data["status"] = 2
					CommonUtils.resultSuccess(call: call, result: result, data: data)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
				
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	func sendC2CCustomMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let customData = CommonUtils.getParam(call: call, result: result, param: "customData") as! String;
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as! String;
		let data = customData.data(using: String.Encoding.utf8, allowLossyConversion: true);
		
        var msgID = "";
		let id = V2TIMManager.sharedInstance()?.sendC2CCustomMessage(data, to: userID, succ: {
			() -> Void in
			
            V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
                (msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					var dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
        
        msgID = id!
	}
	
	func sendGroupTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let text = CommonUtils.getParam(call: call, result: result, param: "text") as! String;
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as! String;
		let priority = CommonUtils.getParam(call: call, result: result, param: "priority") as! Int;
		var msgid = "";
		
		let msgID = V2TIMManager.sharedInstance()?.sendGroupTextMessage(text, to: groupID, priority: V2TIMMessagePriority(rawValue: priority)!, succ: {
			() -> Void in
			let msg = TencentImUtils.createMessage(call: call, result: result, type: 1);
			var data = V2MessageEntity.init(message: msg).getDict()
			data["text"] = text
			data["progress"] = 100
			data["status"] = 2
			data["msgID"] = msgid;
			data["groupID"] = groupID;
			data["priority"] = priority;
			data["sender"] = V2TIMManager.sharedInstance()?.getLoginUser();
			CommonUtils.resultSuccess(call: call, result: result, data: data)
			
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		
		msgid = msgID!
	}
	
	func sendGroupCustomMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let customData = CommonUtils.getParam(call: call, result: result, param: "customData") as! String;
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as! String;
		let priority = CommonUtils.getParam(call: call, result: result, param: "priority") as! Int;
		let data = customData.data(using: String.Encoding.utf8, allowLossyConversion: true);
		
		V2TIMManager.sharedInstance()?.sendGroupCustomMessage(data, to: groupID, priority: V2TIMMessagePriority(rawValue: priority)!, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
    func setMessageMapProcess(call: FlutterMethodCall, result: @escaping FlutterResult,message: V2TIMMessage){
        let millisecond = self.getMessageMapId();
        messageDict.updateValue(message, forKey: millisecond);
        
        var resultDict =  [String: Any]();
        let dict = V2MessageEntity.init(message: message).getDict();
        
        resultDict.updateValue(millisecond, forKey: "id");
        resultDict.updateValue(dict, forKey: "messageInfo");
        
        CommonUtils.resultSuccess(call: call, result: result,data: resultDict);
    }
    
    func createMessageProcess(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int){
        let message = TencentImUtils.createMessage(call: call, result: result, type: type);
        setMessageMapProcess(call: call, result: result, message: message);
    }
    
    func createTextMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createCustomMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createImageMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createSoundMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createVideoMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    func createFileMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    func createTextAtMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createLocationMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    func createFaceMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        createMessageProcess(call: call, result: result, type: type);
    }
    
    

    func sendMessageOldEdition(call: FlutterMethodCall, result: @escaping FlutterResult, message: V2TIMMessage, id: String? = nil) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		let receiver = CommonUtils.getParam(call: call, result: result, param: "receiver") as? String;
		let priority = CommonUtils.getParam(call: call, result: result, param: "priority") as? Int;
		let onlineUserOnly = CommonUtils.getParam(call: call, result: result, param: "onlineUserOnly") as? Bool;
        let v2TIMOfflinePushInfo = CommonUtils.getV2TIMOfflinePushInfo(call: call, result: result);
        let listenerList = SDKManager.getAdvanceMsgListenerList();
		let succ = {
			() -> Void in
				
			async({
				_ -> Dictionary<String, Any> in
				
				let ret = try Hydra.await(V2MessageEntity.init(message: message).getDictAll())
				return ret
            }).then({
                        var _data = $0;
                        _data["priority"] = priority;
                        self.clearMessageMap(id: id);
                        CommonUtils.resultSuccess(call: call, result: result, data: _data) })
		}
		
		let progressfn = {
			progress -> Void in
			
            var msg = V2MessageEntity.init(message: message).getDict();
            msg["id"] = id; // 只有progress时需要传递id
            msg["progress"] = progress;
            for items in listenerList {
                TencentImSDKPlugin.invokeListener(
                    type: ListenerType.onSendMessageProgress, method: "advancedMsgListener",
                    data: ["progress": progress, "message": msg], listenerUuid: items
                )
            }
		} as V2TIMProgress
		
		let fail = {
			(code: Int32, desc: Optional<String>) -> Void in
			
			async({
				_ -> Dictionary<String, Any> in
				
				let ret = try Hydra.await(V2MessageEntity.init(message: message).getDictAll())
				return ret
			}).then({
                self.clearMessageMap(id: id);
                CommonUtils.resultFailed(desc: desc, code: code, data: $0, call: call, result: result) })
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
    
    func sendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let id = CommonUtils.getParam(call: call, result: result, param: "id") as! String; // 自定义id
        if let message = messageDict[id] {
            self.setCustomDataBeforSend(call: call, result: result, message: message);
            sendMessageOldEdition(call: call, result: result, message: message, id: id);
        } else {
            CommonUtils.resultFailed(desc: "id not exist,please create message again", code: -1, call: call, result: result);
        };
    }
	
	func sendMessageOldEdition(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) {
        let message = TencentImUtils.createMessage(call: call, result: result, type: type)
        sendMessageOldEdition(call: call, result: result, message: message);
	}
    
    func createForwardMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
            V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
                (msgs) -> Void in
                
                if msgs?.count != nil && msgs?.count != 0 {
                    let message = V2TIMManager.sharedInstance()?.createForwardMessage(msgs![0])
                    self.setMessageMapProcess(call: call, result: result, message: message!);
                } else {
                    CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
                }
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

	func sendForwardMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let message = V2TIMManager.sharedInstance()?.createForwardMessage(msgs![0])
					self.sendMessageOldEdition(call: call, result: result, message: message!)
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func reSendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			// 注意：这个findMessages 返回的对象是V2TIMMessage类型，其中不返回优先级 导致我们无法顺利拿到priority
			V2TIMManager.sharedInstance()?.findMessages(msgID == "" ? [""] : [msgID], succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let msg = msgs![0] as V2TIMMessage
					self.sendMessageOldEdition(call: call, result: result, message: msg)
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
    

	
    func downloadMergerMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
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
											CommonUtils.resultSuccess(call: call, result: result, data: messageList)

											return 1
										}
									).then({
										value in
									})
								},fail:TencentImUtils.returnErrorClosures(call: call, result: result))
							} else {
								CommonUtils.resultFailed(desc: "this message is not merge element", code: -1, call: call, result: result)
							}
						} else {
							CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
						}
					},fail:TencentImUtils.returnErrorClosures(call: call, result: result))
		}
        
    }
    
    func createMergerMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
        if let msgIDList = CommonUtils.getParam(call: call, result: result, param: "msgIDList") as? [String],
           let abstractList = CommonUtils.getParam(call: call, result: result, param: "abstractList") as? [String],
           let compatibleText = CommonUtils.getParam(call: call, result: result, param: "compatibleText") as? String,
           let title = CommonUtils.getParam(call: call, result: result, param: "title") as? String {
            V2TIMManager.sharedInstance()?.findMessages(msgIDList, succ: {
                (msgs) -> Void in
                
                if msgs?.count != nil && msgs?.count != 0 {
                    if let message = V2TIMManager.sharedInstance()?.createMergerMessage(msgs, title: title, abstractList: abstractList, compatibleText: compatibleText){
                        self.setMessageMapProcess(call: call, result: result, message: message);
                    }
                    else
                        {CommonUtils.resultFailed(desc: "create merge msgs fail", code: -1, call: call, result: result)}
                } else {
                    CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
                }
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        }
    }

	func sendMergerMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDList = CommonUtils.getParam(call: call, result: result, param: "msgIDList") as? [String],
		   let abstractList = CommonUtils.getParam(call: call, result: result, param: "abstractList") as? [String],
		   let compatibleText = CommonUtils.getParam(call: call, result: result, param: "compatibleText") as? String,
		   let title = CommonUtils.getParam(call: call, result: result, param: "title") as? String {
			V2TIMManager.sharedInstance()?.findMessages(msgIDList, succ: {
				(msgs) -> Void in
				
				if msgs?.count != nil && msgs?.count != 0 {
					let message = V2TIMManager.sharedInstance()?.createMergerMessage(msgs, title: title, abstractList: abstractList, compatibleText: compatibleText)
					self.sendMessageOldEdition(call: call, result: result, message: message!)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setC2CReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? [String],
		   let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as? Int {
			V2TIMManager.sharedInstance()?.setC2CReceiveMessageOpt(userIDList, opt: V2TIMReceiveMessageOpt.init(rawValue: opt)!, succ: {
					() -> Void in
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result)
			)
		}
	}
	
	func setGroupReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
		   let opt = CommonUtils.getParam(call: call, result: result, param: "opt") as? Int {
			V2TIMManager.sharedInstance()?.setGroupReceiveMessageOpt(groupID, opt: V2TIMReceiveMessageOpt.init(rawValue: opt)!, succ: {
					() -> Void in
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result)
			)
		}
	}
	
	func getC2CReceiveMessageOpt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? [String] {
			V2TIMManager.sharedInstance()?.getC2CReceiveMessageOpt(userIDList, succ: {
				let dict = $0!.map { [
                    "c2CReceiveMessageOpt": Int($0.receiveOpt.rawValue),
					"userID": $0.userID ?? ""
				] }
				CommonUtils.resultSuccess(call: call, result: result, data: dict)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func getC2CHistoryMessageList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let count = CommonUtils.getParam(call: call, result: result, param: "count") as? Int32,
		   let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
			let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
			
			if lastMsgID != nil {
				V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
					(msgs) -> Void in
					
					let lastMsg = msgs!.isEmpty ? nil : msgs![0]
					if lastMsg != nil {
						self.getC2CHistoryMessageListFn(userID: userID, count: count, lastMsg: lastMsg!, result: result, call: call)
					}
					
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
			} else {
				getC2CHistoryMessageListFn(userID: userID, count: count, lastMsg: nil, result: result, call: call)
			}
			
		}
	}
	
	func getC2CHistoryMessageListFn(userID: String, count: Int32, lastMsg: V2TIMMessage?, result: @escaping FlutterResult, call: FlutterMethodCall) {
		V2TIMManager.sharedInstance()?.getC2CHistoryMessageList(userID, count: count, lastMsg: lastMsg, succ: {
			msgs -> Void in
			
			var messageList: [[String: Any]] = []
			
			async({
				_ -> Int in
				
				for i in msgs! {
					
					messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
				}
				CommonUtils.resultSuccess(call: call, result: result, data: messageList)
				
				return 1
			}).then({
				value in
			})
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	
	func getHistoryMessageList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
		let count = CommonUtils.getParam(call: call, result: result, param: "count") as? UInt
	    let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String
		let getType = CommonUtils.getParam(call: call, result: result, param: "getType") as? Int
        let lastMsgSeq = CommonUtils.getParam(call: call, result: result, param: "lastMsgSeq") as? Int
		let option = V2TIMMessageListGetOption();
		
		if groupID != nil && userID != nil {
			CommonUtils.resultFailed(desc: "groupID和userID只能设置一个", code: -1, call: call, result: result)
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
		if lastMsgID != nil {
			V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
				(msgs) -> Void in
				let lastMsg = msgs!.isEmpty ? nil : msgs![0]
				if lastMsg != nil {
					option.lastMsg = lastMsg
					self.getHistoryMessageListFn(option: option, result: result, call: call)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		} else {
			getHistoryMessageListFn(option: option, result: result, call: call)
		}
	}

	func getHistoryMessageListFn(option: V2TIMMessageListGetOption, result: @escaping FlutterResult, call: FlutterMethodCall) {
		V2TIMManager.sharedInstance()?.getHistoryMessageList(option, succ: {
			msgs -> Void in

			var messageList: [[String: Any]] = []

			async({ _ -> Int in
				for i in msgs! {

					messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
				}
				CommonUtils.resultSuccess(call: call, result: result, data: messageList)

				return 1
			}).then({
				value in
			})
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	func getGroupHistoryMessageList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let count = CommonUtils.getParam(call: call, result: result, param: "count") as? Int32,
		   let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
			let lastMsgID = CommonUtils.getParam(call: call, result: result, param: "lastMsgID") as? String
			
			if lastMsgID != nil {
				V2TIMManager.sharedInstance()?.findMessages(lastMsgID == nil ? [""] : [lastMsgID!], succ: {
					(msgs) -> Void in
					
					let lastMsg = msgs!.isEmpty ? nil : msgs![0]
					if lastMsg != nil {
						self.getGroupHistoryMessageListFn(groupID: groupID, count: count, lastMsg: lastMsg!, result: result, call: call)
					}
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
			} else {
				getGroupHistoryMessageListFn(groupID: groupID, count: count, lastMsg: nil, result: result, call: call)
			}
		}
	}
	
	func getGroupHistoryMessageListFn(groupID: String, count: Int32, lastMsg: V2TIMMessage?, result: @escaping FlutterResult, call: FlutterMethodCall) {
		V2TIMManager.sharedInstance()?.getGroupHistoryMessageList(groupID, count: count, lastMsg: lastMsg, succ: {
			msgs -> Void in
			
			var messageList: [[String: Any]] = []
			
			async({
				_ -> Int in
				
				for i in msgs! {
					
					messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
				}
				CommonUtils.resultSuccess(call: call, result: result, data: messageList)
				
				return 1
			}).then({
				value in
			})
			
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	public func revokeMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().revokeMessage(msgs![0], succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	
	public func markC2CMessageAsRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
			V2TIMManager.sharedInstance().markC2CMessage(asRead: userID, succ: {
				CommonUtils.resultSuccess(call: call, result: result)
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func markGroupMessageAsRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String;
		
		V2TIMManager.sharedInstance()?.markGroupMessage(asRead: groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}

	func markAllMessageAsRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
        V2TIMManager.sharedInstance()?.markAllMessage(asRead: {
            () -> Void in
            
            CommonUtils.resultSuccess(call: call, result: result)
        }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	}
	
	func deleteMessageFromLocalStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().deleteMessage(fromLocalStorage: msgs![0], succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	func deleteMessages(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgIDs = CommonUtils.getParam(call: call, result: result, param: "msgIDs") as? Array<String> {
			V2TIMManager.sharedInstance()?.findMessages(msgIDs, succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
				V2TIMManager.sharedInstance().delete(msgs, succ: {
					CommonUtils.resultSuccess(call: call, result: result)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}

	func clearC2CHistoryMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
            V2TIMManager.sharedInstance().clearC2CHistoryMessage(userID, succ: {
                () -> Void in
                CommonUtils.resultSuccess(call: call, result: result);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func clearGroupHistoryMessage(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String {
            V2TIMManager.sharedInstance().clearGroupHistoryMessage(groupID, succ: {
                CommonUtils.resultSuccess(call: call, result: result);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	func insertGroupMessageToLocalStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupID = CommonUtils.getParam(call: call, result: result, param: "groupID") as? String,
		   let sender = CommonUtils.getParam(call: call, result: result, param: "sender") as? String {
			let message = TencentImUtils.createMessage(call: call, result: result, type: 2);
			
			var msgID = ""
			let id = V2TIMManager.sharedInstance()?.insertGroupMessage(toLocalStorage: message, to: groupID, sender: sender, succ: {
			   () -> Void in
				
				V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
					
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			 }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			
			msgID = id!
		}
	}
	
	func insertC2CMessageToLocalStorage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String,
		   let sender = CommonUtils.getParam(call: call, result: result, param: "sender") as? String {
			let message = TencentImUtils.createMessage(call: call, result: result, type: 2);
			
			var msgID = ""
			let id = V2TIMManager.sharedInstance()?.insertC2CMessage(toLocalStorage: message, to: userID, sender: sender, succ: {
			   () -> Void in
				
				V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, call: call, result: result)
				}
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			 }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			
			msgID = id!
		}
	}
    // 发送消息前，我们可以对消息 自定义设置云端数据和本地自定义消息
    func setCustomDataBeforSend(call: FlutterMethodCall, result: @escaping FlutterResult, message: V2TIMMessage) {
        if let data = CommonUtils.getParam(call: call, result: result, param: "cloudCustomData") as? String {
            message.cloudCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
            print("CloudCustomData Setting Ok");
        }
        if let data = CommonUtils.getParam(call: call, result: result, param: "localCustomData") as? String {
            message.localCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
            print("localCustomData Setting Ok");
        }
    }
    
	// 3.6.0后不推荐使用,必须在message发送钱调用才能生效
	func setCloudCustomData(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String,
		   let data = CommonUtils.getParam(call: call, result: result, param: "data") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].cloudCustomData = data.data(using: String.Encoding.utf8, allowLossyConversion: true)
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setLocalCustomInt(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String,
		   let localCustomInt = CommonUtils.getParam(call: call, result: result, param: "localCustomInt") as? Int32 {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].localCustomInt = localCustomInt
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	
	func setLocalCustomData(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let msgID = CommonUtils.getParam(call: call, result: result, param: "msgID") as? String,
		   let localCustomData = CommonUtils.getParam(call: call, result: result, param: "localCustomData") as? String {
			V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
				if $0?.count ?? 0 > 0 {
					$0![0].localCustomData = localCustomData.data(using: String.Encoding.utf8, allowLossyConversion: true)
					CommonUtils.resultSuccess(call: call, result: result, data: "ok")
				} else {
					CommonUtils.resultFailed(desc: "msg is not exist", code: -1, call: call, result: result)
				}
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}

	func searchLocalMessages(call: FlutterMethodCall, result: @escaping FlutterResult){

        let searchParam = CommonUtils.getParam(call: call, result: result, param: "searchParam") as! [String: Any];
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
            messageSearchParam.pageSize = searchParam["pageSize"] as! UInt;
        }

        if let searchTimePosition = searchParam["searchTimePosition"] as? UInt {
            messageSearchParam.searchTimePosition = searchTimePosition;
        }
        else {
           messageSearchParam.searchTimePosition = 0;
        }


        if(searchParam["pageIndex"] != nil){
            messageSearchParam.pageIndex = searchParam["pageIndex"] as! UInt;
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
            
            
            for(index,element) in list.enumerated(){
                var messageSearchResultItemMap = [String: Any]();
                messageSearchResultItemMap.updateValue(element.conversationID!, forKey: "conversationID");
                messageSearchResultItemMap.updateValue(element.messageCount, forKey: "messageCount");
                messageSearchResultItemMap.updateValue(CommonUtils.parseMessageListDict(list: element.messageList) , forKey: "messageList");
                messageSearchResultItems.append(messageSearchResultItemMap);
            };
            map.updateValue(res!.totalCount, forKey: "totalCount");
            map.updateValue(messageSearchResultItems, forKey: "messageSearchResultItems")
            CommonUtils.resultSuccess(call: call, result: result, data: map);
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        
	}
    
    
	func findMessages(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let messageIDList = CommonUtils.getParam(call: call, result: result, param: "messageIDList") as? [String] {
            V2TIMManager.sharedInstance().findMessages(messageIDList, succ: {
				(msgs) -> Void in
                var messageList: [[String: Any]] = []
                
                async({
                    _ -> Int in
                    
                    for i in msgs! {
                        
                        messageList.append(try Hydra.await(V2MessageEntity.init(message: i).getDictAll()))
                    }
                    CommonUtils.resultSuccess(call: call, result: result, data: messageList) 
                    return 1
                }).then({
                    value in
                })
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
		}
	}
	/*
					V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
					(msgs) -> Void in
					
					let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(call: call, result: result, data: dict)
				}, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
			 }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
	
	*/

}	
