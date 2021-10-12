import  ImSDK_Plus
import Hydra
//  腾讯云工具类

public class TencentImUtils {
  public static func createMessage(call: FlutterMethodCall, result: @escaping FlutterResult, type: Int) -> V2TIMMessage {
	var messageMap = call.arguments as! Dictionary<String, Any>
    var message: V2TIMMessage = V2TIMMessage()
	
	
	if let isExcludedFromUnreadCount = messageMap["isExcludedFromUnreadCount"] as? Bool {
		message.isExcludedFromUnreadCount = isExcludedFromUnreadCount
	}

    switch type {
      case 0:
        break
      case 1:
		if let atUserList = messageMap["atUserList"] as? NSMutableArray {
			if messageMap["text"] as! String == "" {
				messageMap["text"] = " "
			}
			message = (V2TIMManager.sharedInstance()?.createText(atMessage: messageMap["text"] as? String, atUserList: atUserList))!
        } else {
          message = (V2TIMManager.sharedInstance()?.createTextMessage(messageMap["text"] as? String))!
        }
        break
      case 2:
        message = (V2TIMManager.sharedInstance()?.createCustomMessage(
			(messageMap["data"] as! String).data(using: String.Encoding.utf8, allowLossyConversion: true),
			desc: messageMap["desc"] as? String,
			extension: messageMap["extension"] as? String
		))!
        break
      case 3:
        var imagePath = CommonUtils.getParam(call: call, result: result, param: "imagePath") as! String;
        message = (V2TIMManager.sharedInstance()?.createImageMessage(imagePath))!
        break
      case 4:
		message = (V2TIMManager.sharedInstance()?.createSoundMessage(
			(messageMap["soundPath"] as? String) ?? "",
			duration: messageMap["duration"] as! Int32
		))!
        break
      case 5:
        message = (V2TIMManager.sharedInstance()?.createVideoMessage(
			(messageMap["videoFilePath"] as? String) ?? "",
          type: messageMap["type"] as? String,
          duration: messageMap["duration"] as? Int32 ?? 0,
			snapshotPath: (messageMap["snapshotPath"] as? String) ?? ""
        ))!
        break
      case 6:
        message = (V2TIMManager.sharedInstance()?.createFileMessage(
			messageMap["filePath"] as? String,
			fileName: messageMap["fileName"] as? String
        ))!
        break
      case 7:
		message = (V2TIMManager.sharedInstance()?.createLocationMessage(messageMap["desc"] as? String, longitude: messageMap["longitude"] as! Double, latitude: messageMap["latitude"] as! Double)!)!
        break
      case 8:
        message = (V2TIMManager.sharedInstance()?.createFaceMessage(
          messageMap["index"] as! Int32,
            data: (messageMap["data"] as! String).data(using: String.Encoding.utf8, allowLossyConversion: true)
        ))!
        break
      // 新增，合并消息
      case 10:
//         message = (V2TIMManager.sharedInstance()?.createMergerMessage(
//           messageMap["index"] as! Int32,
//             data: (messageMap["data"] as! String).data(using: String.Encoding.utf8, allowLossyConversion: true)
//         ))!
         break
      default:
        message = (V2TIMManager.sharedInstance()?.createTextMessage(messageMap["text"] as! String))!
    }

    return message
  }


   /**
    * 返回[错误返回闭包]，腾讯云IM通用格式
    */
	public static func returnErrorClosures(call: FlutterMethodCall,result: @escaping FlutterResult) -> V2TIMFail {
       return {
           (code: Int32, desc: Optional<String>) -> Void in
           
		CommonUtils.resultFailed(desc: desc, code: code, call: call, result: result)
       };
   }

  

}

/**
*  获取信息成功回调
*/
public typealias GetInfoSuc = (_ array: [Any]) -> Void;

/**
*  获取信息失败回调
*/
public typealias GetInfoFail = (_ code: Int32, _ desc: Optional<String>) -> Void;

/**
*  获取TIM消息成功回调
*/
public typealias GetTimMessage = (_ message: V2TIMMessage?) -> Void;

/**
*  获取TIM消息成功回调
*/
public typealias GetMessage = (_ message: V2MessageEntity) -> Void;

/* 
    onReciveMessage时防止线程进入过多而导致线程卡死的问题，
    而为Hydra封装的一个线程数量管理类
    处理逻辑类似发布订阅，中间多加了一个limit数量的限制，使得第一次进入时避免开启的线程数量过大而导致的卡死💀
*/
public class HydraThreadManager {
   static var limit: Int = 20;
   static var bufferArr: [Promise<Int>] = [];
   static var curThreadNum = 0;
    
    
    public static func getThreadLimit()-> Int {
        return self.limit;
    }
    
    // 发布
    private static func emit(promise:Promise<Int>) -> Void {
        if(limit > curThreadNum){
        curThreadNum += 1;
        promise.then( { value in
                curThreadNum = curThreadNum - 1;

                if(bufferArr.count > 0){
                    let temp = bufferArr[0];
                    bufferArr.remove(at: 0);
                    emit(promise: temp);
                }
            })
        }else {subsc(promise:promise);}
    }
    
    // 订阅
    public static func subsc(promise:Promise<Int>) -> Void {
        
        // 当前buffer不足不足
        if(limit <= curThreadNum){
            bufferArr.append(promise);
        // 当前buffer充足
        }else{
            emit(promise: promise)
        }
    }

}
