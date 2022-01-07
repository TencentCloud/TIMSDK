import Flutter
import ImSDK_Plus

//  通用工具类
public class CommonUtils {
    /**
     * 通用方法，获得参数值，如未找到参数，则直接中断
     *
     * @param methodCall 方法调用对象
     * @param result     返回对象
     * @param param      参数名
     */
    public static func getParam(call: FlutterMethodCall, result: @escaping FlutterResult, param: String) -> Any? {
        let value = (call.arguments as! [String: Any])[param];
        if value == nil {
//            result(
//                    FlutterError(code: "-1", message: "Missing parameter", details: "Cannot find parameter `\(param)` or `\(param)` is null!")
//            );
        }
        return value
    }

    /// 将hex string 转为Data
    public static func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while (hex.count > 0) {
            let index1 = hex.index(hex.startIndex, offsetBy: 2)
            let index2 = hex.index(hex.endIndex, offsetBy: 0)
            let c: String = String(hex[hex.startIndex..<index1])
            hex = String(hex[index1..<index2])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }

    // 存在则赋值
    public static func getRequestInstance(call: FlutterMethodCall, instance: NSObject) -> NSObject {
      for item in call.arguments as! [String: Any] {
        if item.value != nil {
          instance.setValue(item.value, forKey: item.key)
        }
      }
      return instance
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

    // 返回失败结果
	public static func resultFailed(desc: String? = "failed", code: Int32? = 0, call: FlutterMethodCall, result: @escaping FlutterResult) {
		let res = ["code": code, "desc": desc] as [String : Any]

		TencentImSDKPlugin.channel?.invokeMethod("logFromSwift", arguments: ["msg": "Swift Error，方法名\(call.method)，错误信息：", "data": desc])
		result(res)
    }
	
	// 返回失败结果带data
	public static func resultFailed(desc: String? = "failed", code: Int32? = -1, data: Dictionary<String, Any>, call: FlutterMethodCall, result: @escaping FlutterResult) {
		let res = ["code": code, "desc": desc, "data": data] as [String : Any]
	  
		TencentImSDKPlugin.channel?.invokeMethod("logFromSwift", arguments: ["msg": "Swift Error，方法名\(call.method)，错误信息：", "data": res])
		result(res)
	}

    // 返回成功结果
	public static func resultSuccess(desc: String = "ok", call: FlutterMethodCall, result: @escaping FlutterResult, data: Any = NSNull()) {
		let res = ["code": 0, "desc": desc, "data": data] as [String : Any]
		
		TencentImSDKPlugin.channel?.invokeMethod(
			"logFromSwift",
			arguments: [
				"msg": "Swift Response，方法名\(call.method)，数据：", "data": res
		])
        result(res)
    }
    
    
    public static func parseMessageListDict( list:[V2TIMMessage]) -> [Any]{
        var messageList: [[String: Any]] = [];
        for i in list {
            
            messageList.append(V2MessageEntity.init(message: i).getDict());
        }
        
        return messageList;
    }

    public static func logFromSwift(channel: FlutterMethodChannel, data: Any) {
      channel.invokeMethod("logFromSwift", arguments: data);
    }
	
	public static func getV2TIMOfflinePushInfo(call: FlutterMethodCall, result: @escaping FlutterResult) -> V2TIMOfflinePushInfo {
		let v2TIMOfflinePushInfo = V2TIMOfflinePushInfo()
		
		if let offlinePushInfo = CommonUtils.getParam(call: call, result: result, param: "offlinePushInfo") as? [String: Any] {
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
	
	
	
	
}

extension Data {
	var hexString: String {
		let hexString = map { String(format: "%02.2hhx", $0) }.joined()
		return hexString
	}
}
