import ImSDK_Plus

public class CommonUtils {
    // 返回成功结果
	public static func resultSuccess(desc: String = "ok", method: String = "", resolve: RCTPromiseResolveBlock, data: Any = NSNull()) {
		var res = ["code": 0, "desc": desc] as [String : Any]
        if data != nil {
            res["data"] = data;
        }
        logFromNative(message: "Swift Response，方法名\(method)，数据：\(res)");
        resolve(res);
    }

    public static func logFromNative(message: String) {
        let timJSInstance = TimJs.shared;
        let log = ["logs": message];
        timJSInstance?.sendEvent(withName: "logFromNative",  body: log);
    }

    public static func emmitEvent(eventName: String, eventType: ListenerType, data: Any? ) -> Void {
        let timJSInstance = TimJs.shared;
        var resultParams: [String: Any] = [:];
        resultParams["type"] = "\(eventType)";
        resultParams["eventName"] = eventName;
		if data != nil {
			resultParams["data"] = data;
		}
        logFromNative(message: "Swift向Dart发送事件，事件名\(eventType)，数据\(data)");
        timJSInstance?.sendEvent(withName: eventName,  body: resultParams);
    }

    // 返回失败结果
	public static func resultFailed(desc: String? = "failed", code: Int32? = 0, method: String, resolve: RCTPromiseResolveBlock) {
        let res = ["code": code ?? -1, "desc": desc ?? ""] as [String : Any]
        logFromNative(message: "Swift Error，方法名\(method)，错误信息：\(desc)");
		resolve(res)
    }
	
	// 返回失败结果带data
	public static func resultFailed(desc: String? = "failed", code: Int32? = -1, data: Dictionary<String, Any>, method: String, resolve: RCTPromiseResolveBlock) {
        let res = ["code": code ?? -1, "desc": desc ?? "", "data": data] as [String : Any]
        logFromNative(message: "Swift Error，方法名\(method)，错误信息：\(desc)");
		resolve(res)
	}

    // 抹平img中type不同平台的差异
    public static func changeToAndroid(type:Int ) -> Int{
        // 安卓的三种类型
        let V2TIM_IMAGE_TYPE_ORIGIN_ANDROID = 0;
        let V2TIM_IMAGE_TYPE_THUMB_ANDROID = 1;
        let V2TIM_IMAGE_TYPE_LARGE_ANDROID = 2;
        if type == V2TIMImageType.IMAGE_TYPE_ORIGIN.rawValue {
            return V2TIM_IMAGE_TYPE_ORIGIN_ANDROID
        }else if type == V2TIMImageType.IMAGE_TYPE_LARGE.rawValue {
            return V2TIM_IMAGE_TYPE_LARGE_ANDROID
        }
        else {
            return V2TIM_IMAGE_TYPE_THUMB_ANDROID
        }
    }

    public static func getV2TIMOfflinePushInfo(param: [String: Any]) -> V2TIMOfflinePushInfo {
		let v2TIMOfflinePushInfo = V2TIMOfflinePushInfo()
		
		if let offlinePushInfo = param["offlinePushInfo"] as? [String: Any] {
			v2TIMOfflinePushInfo.title = offlinePushInfo["title"] as? String
			v2TIMOfflinePushInfo.desc = offlinePushInfo["desc"] as? String
			v2TIMOfflinePushInfo.disablePush = offlinePushInfo["disablePush"] as? Bool ?? true
			v2TIMOfflinePushInfo.ext = offlinePushInfo["ext"] as? String
			v2TIMOfflinePushInfo.iOSSound = offlinePushInfo["iOSSound"] as? String
			v2TIMOfflinePushInfo.ignoreIOSBadge = offlinePushInfo["ignoreIOSBadge"] as? Bool ?? true
			v2TIMOfflinePushInfo.androidOPPOChannelID = offlinePushInfo["androidOPPOChannelID"] as? String
		}
		
		return v2TIMOfflinePushInfo;
	}

    public static func parseMessageListDict( list:[V2TIMMessage]) -> [Any]{
        var messageList: [[String: Any]] = [];
        for i in list {
            
            messageList.append(V2MessageEntity.init(message: i).getDict());
        }
        
        return messageList;
    }
}