import ImSDK_Plus

class SDKManager {

	private var simpleMsgListener: SimpleMsgListener = SimpleMsgListener();
	private var sdkListener: SDKListener = SDKListener();
	private var groupListener: GroupListener = GroupListener();
	private var apnsListener = APNSListener();

    /**
	* 初始化腾讯云IM，TODO：config需要配置更多信息
	*/
	public func initSDK(param: [String: Any], resolve: RCTPromiseResolveBlock) {
		if let sdkAppID = param["sdkAppID"] as? Int32,
		   let logLevel = param["logLevel"] as? Int {
                let config = V2TIMSDKConfig()
				config.logLevel = V2TIMLogLevel(rawValue: logLevel)!
				let data = V2TIMManager.sharedInstance().initSDK(sdkAppID, config: config);
				V2TIMManager.sharedInstance().add(sdkListener);
				
				CommonUtils.resultSuccess(method: "initSDK", resolve: resolve, data: data);
		}
	}

	/**
	* 登录
	*/
	public func login(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		if let userID = param["userID"] as? String,
		   let userSig = param["userSig"] as? String  {
			// 登录操作
			V2TIMManager.sharedInstance().login(
				userID,
				userSig: userSig,
				succ: {
					CommonUtils.resultSuccess(method: "login", resolve: resolve, data: "login success");
				},
				fail: TencentImUtils.returnErrorClosures(method: "login", resolve: resolve)
			)
		}
	}

	public func unInitSDK(resolve: RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance().unInitSDK();
		CommonUtils.resultSuccess(method: "unInitSDK", resolve: resolve, data: "uninit success");
	}

	public func getVersion(resolve: RCTPromiseResolveBlock) {
		CommonUtils.resultSuccess(method: "getVersion", resolve: resolve, data: V2TIMManager.sharedInstance().getVersion() as Any);
	}

	public func getServerTime(resolve: RCTPromiseResolveBlock) {
		CommonUtils.resultSuccess(method: "getServerTime", resolve: resolve, data: V2TIMManager.sharedInstance().getServerTime());
	}

	public func logout(resolve: @escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance().logout({
			CommonUtils.resultSuccess(method: "logout", resolve: resolve, data: "logout success");
		}, fail: TencentImUtils.returnErrorClosures(method: "logout", resolve: resolve));
	}

	public func getLoginUser(resolve: RCTPromiseResolveBlock) {
        CommonUtils.resultSuccess(method: "getLoginUser", resolve: resolve, data: V2TIMManager.sharedInstance().getLoginUser() as Any);
	}

	public func getLoginStatus(resolve: RCTPromiseResolveBlock) {
		CommonUtils.resultSuccess(method: "getLoginStatus", resolve: resolve, data: V2TIMManager.sharedInstance().getLoginStatus().rawValue);
	}

	public func sendC2CTextMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let text = param["text"] as? String;
		let userID = param["userID"] as? String;
		
		let msgID = V2TIMManager.sharedInstance()?.sendC2CTextMessage(text, to: userID , succ: {
			() -> Void in
		}, fail: TencentImUtils.returnErrorClosures(method: "sendC2CTextMessage", resolve: resolve));
		
        if msgID != nil {
			V2TIMManager.sharedInstance()?.findMessages([msgID!], succ: {
				(msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
					var data = V2MessageEntity.init(message: msgs![0]).getDict()
					data["progress"] = 100
					data["status"] = 2
					CommonUtils.resultSuccess(method: "sendC2CTextMessage", resolve: resolve, data: data)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "sendC2CTextMessage", resolve: resolve)
				}
				
			}, fail: TencentImUtils.returnErrorClosures(method: "sendC2CTextMessage", resolve: resolve));
		}
	}

	public func sendC2CCustomMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let customData = param["customData"] as? String;
		let userID = param["userID"] as? String;
        let data = customData?.data(using: String.Encoding.utf8, allowLossyConversion: true);
		
        var msgID = "";
		let id = V2TIMManager.sharedInstance()?.sendC2CCustomMessage(data, to: userID, succ: {
			() -> Void in
			
            V2TIMManager.sharedInstance()?.findMessages([msgID], succ: {
                (msgs) -> Void in
				if msgs?.count != nil && msgs?.count != 0 {
                    let dict = V2MessageEntity.init(message: msgs![0]).getDict()
					CommonUtils.resultSuccess(method: "sendC2CCustomMessage", resolve: resolve, data: dict)
				} else {
					CommonUtils.resultFailed(desc: "msgs is not exist", code: -1, method: "sendC2CCustomMessage", resolve: resolve)
				}
            }, fail: TencentImUtils.returnErrorClosures(method: "sendC2CCustomMessage", resolve: resolve))
		}, fail: TencentImUtils.returnErrorClosures(method: "sendC2CCustomMessage", resolve: resolve));
        if(id != nil){
			msgID = id!
		}
	}

	public func sendGroupTextMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let text = param["text"] as? String;
		let groupID = param["groupID"] as? String;
		let priority = param["priority"] as! Int;
		var msgid = "";
		
		let msgID = V2TIMManager.sharedInstance()?.sendGroupTextMessage(text, to: groupID, priority: V2TIMMessagePriority(rawValue: priority)!, succ: {
			() -> Void in
			let msg = TencentImUtils.createMessage(param: param, resolve: resolve, type: 1);
			var data = V2MessageEntity.init(message: msg).getDict()
			data["text"] = text
			data["progress"] = 100
			data["status"] = 2
			data["msgID"] = msgid;
			data["groupID"] = groupID;
			data["priority"] = priority;
			data["sender"] = V2TIMManager.sharedInstance()?.getLoginUser();
			CommonUtils.resultSuccess(method: "sendGroupTextMessage", resolve: resolve, data: data)
			
		}, fail: TencentImUtils.returnErrorClosures(method: "sendGroupTextMessage", resolve: resolve));
		
        if(msgID != nil){
            msgid = msgID!;
        }

		
	}

	public func sendGroupCustomMessage(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let customData = param["customData"] as! String;
		let groupID = param["groupID"] as! String;
		let priority = param["priority"] as! Int;
		let data = customData.data(using: String.Encoding.utf8, allowLossyConversion: true);
		
		V2TIMManager.sharedInstance()?.sendGroupCustomMessage(data, to: groupID, priority: V2TIMMessagePriority(rawValue: priority)!, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "sendGroupCustomMessage", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "sendGroupCustomMessage", resolve: resolve) );
	}

	public func getUsersInfo(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) { 
		let userIDList = param["userIDList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getUsersInfo(userIDList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			
			for info in array ?? [] {
				let item = V2UserFullInfoEntity.getDict(info: info)
				res.append(item)
			}
			
			CommonUtils.resultSuccess(method: "getUsersInfo", resolve: resolve, data: res);
			
		}, fail: TencentImUtils.returnErrorClosures(method: "getUsersInfo", resolve: resolve));
	}

	public func setSelfInfo(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		let nickName = param["nickName"] as? String;
		let faceURL = param["faceUrl"] as? String;
		let selfSignature = param["selfSignature"] as? String;
		let gender = param["gender"] as? Int;
		let allowType = param["allowType"] as? Int;
		let birthday = param["birthday"] as? UInt32;
		let level = param["level"] as? UInt32;
		let role = param["role"] as? UInt32;
		let customInfo = param["customInfo"] as? Dictionary<String, String>;
		var customInfoData: [String: Data] = [:]
		
        let info = V2TIMUserFullInfo();
		if nickName != nil {
			info.nickName = nickName
		}
		if faceURL != nil {
			info.faceURL = faceURL
		}
		if selfSignature != nil {
			info.selfSignature = selfSignature
		}
		if gender != nil {
			info.gender = V2TIMGender(rawValue: gender!)!
		}
		if allowType != nil {
			info.allowType = V2TIMFriendAllowType(rawValue: allowType!)!
		}
		if birthday != nil {
            info.birthday = birthday!
		}
		if level != nil {
            info.level = level!
		}
		if role != nil {
            info.role = role!
		}
		if customInfo != nil {
            for (key, value) in customInfo ?? [:] {
				customInfoData[key] = value.data(using: String.Encoding.utf8, allowLossyConversion: true);
			}
			info.customInfo = customInfoData
		}
		
		V2TIMManager.sharedInstance()?.setSelfInfo(info, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "setSelfInfo", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "setSelfInfo", resolve: resolve));
	}

	public func callExperimentalAPI(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
       if let api = param["api"] as? String,
          let param = param["param"] as? NSObject{
           V2TIMManager.sharedInstance().callExperimentalAPI(api, param: param as NSObject?, succ: {value in
            CommonUtils.resultSuccess(method: "callExperimentalAPI", resolve: resolve, data: value as Any);
        }, fail: TencentImUtils.returnErrorClosures(method: "callExperimentalAPI", resolve: resolve));
       }
	}

	public func addSimpleMsgListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance()?.addSimpleMsgListener(listener: simpleMsgListener);
		CommonUtils.resultSuccess(method: "addSimpleMsgListener", resolve: resolve, data: "addSimpleMsgListener is done");
	}

	public func removeSimpleMsgListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.removeSimpleMsgListener(listener: simpleMsgListener);
		CommonUtils.resultSuccess(method: "removeSimpleMsgListener", resolve: resolve, data: "removeSimpleMsgListener is done");
	}

	public func addGroupListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance().addGroupListener(listener: groupListener)
		CommonUtils.resultSuccess(method: "addGroupListener", resolve: resolve, data: "addGroupListener is done");
	}

	public func removeGroupListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance().removeGroupListener(listener: groupListener);
		CommonUtils.resultSuccess(method: "removeGroupListener", resolve: resolve, data: "removeGroupListener is done");
	}

	public func setAPNSListener(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance().setAPNSListener(apnsListener)
		CommonUtils.resultSuccess(method: "setAPNSListener", resolve: resolve, data: "setAPNSListener is done")
	}

	public func setSelfStatus(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        let status = param["status"] as? String;
        let s = V2TIMUserStatus();
        s.customStatus = status;
        V2TIMManager.sharedInstance().setSelfStatus(s) {
            CommonUtils.resultSuccess(method: "setSelfStatus", resolve: resolve)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "setSelfStatus", resolve: resolve)
        }
    }

	public func getUserStatus(param: [String: Any], resolve: @escaping RCTPromiseResolveBlock) {
        let userIDList:[String] = param["userIDList"] as! [String];
        
        V2TIMManager.sharedInstance().getUserStatus(userIDList) { statusList in
            var res: [[String: Any]] = []
            statusList?.forEach({ status in
                var item: [String: Any] = [:]
                item["customStatus"] = status.customStatus ?? "";
                item["statusType"] = status.statusType.rawValue;
                item["userID"] = status.userID;
                res.append(item)
            })
            print(res)
            CommonUtils.resultSuccess(desc: "ok", method: "getUserStatus", resolve: resolve, data: res)
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "getUserStatus", resolve: resolve)
        }

    }
}