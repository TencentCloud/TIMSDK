//
//  FriendManager.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
import ImSDK_Plus

class FriendManager {
	var channel: FlutterMethodChannel
	
	init(channel: FlutterMethodChannel) {
		self.channel = channel
	}
	
	/**
	* 获得好友列表
	*
	* @param methodCall 方法调用对象
	* @param result     返回结果对象
	*/
	func getFriendList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.getFriendList({
			(array) -> Void in
			
			var resultData: [[String: Any]] = []
			for item in array! {
				resultData.append(V2FriendInfoEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: resultData);
			
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func getFriendsInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getFriendsInfo(userIDList, succ: {
			(array) -> Void in
			
			var resultData: [[String: Any]] = []
			for item in array! {
				resultData.append(V2FriendInfoResultEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: resultData);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	/// 设置好友资料
	public func setFriendInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String {
			let friendRemark = CommonUtils.getParam(call: call, result: result, param: "friendRemark") as? String
			let friendCustomInfo = CommonUtils.getParam(call: call, result: result, param: "friendCustomInfo") as? Dictionary<String, String>
			let friendInfo = V2FriendInfoEntity.init(dict: [
				"userID": userID,
				"friendRemark": friendRemark,
				"friendCustomInfo": friendCustomInfo
			])
			V2TIMManager.sharedInstance().setFriendInfo(friendInfo, succ: {
				CommonUtils.resultSuccess(call: call, result: result, data: "");
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	func checkFriend(call: FlutterMethodCall, result: @escaping FlutterResult) {
		
		
		if let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<String>,
		   let checkType = CommonUtils.getParam(call: call, result: result, param: "checkType") as? Int {
			V2TIMManager.sharedInstance()?.checkFriend(userIDList, check: V2TIMFriendType(rawValue: checkType)!, succ: {
				(array) -> Void in
				
				var res: [Any] = []
				for item in array! {
					res.append(FriendCheckResultEntity(result: item));
				}
				
				CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
		
	}
	
	func getFriendApplicationList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(list) -> Void in
			
			let res = V2FriendApplicationResultEntity(result: list!);
			let data = [
				"unreadCount": res.unreadCount,
				"friendApplicationList": JsonUtil.getDictionaryOrArrayFromObject(res.applicationList)
			]
			
			CommonUtils.resultSuccess(call: call, result: result, data: data);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func addFriend(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String,
		   let addType = CommonUtils.getParam(call: call, result: result, param: "addType") as? Int {
			let remark = CommonUtils.getParam(call: call, result: result, param: "remark") as? String;
			let addWording = CommonUtils.getParam(call: call, result: result, param: "addWording") as? String;
			let addSource = CommonUtils.getParam(call: call, result: result, param: "addSource") as? String;
			
			let request = V2TIMFriendAddApplication();
			
			request.userID = userID;
			request.addType = V2TIMFriendType(rawValue: addType ?? 2)!;
			request.friendRemark = remark ?? nil;
			request.addWording = addWording ?? nil;
			request.addSource = addSource ?? nil;
			V2TIMManager.sharedInstance()?.addFriend(request, succ: {
				(r) -> Void in
				
				let res = FriendOperationResultEntity(result: r!);
				CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
				
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
		
		
	}
	
	func deleteFromFriendList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<Any>,
		   let deleteType = CommonUtils.getParam(call: call, result: result, param: "deleteType") as? Int {
			let requestDeleteType = V2TIMFriendType(rawValue: deleteType ?? 2)!;
			
			V2TIMManager.sharedInstance()?.delete(fromFriendList: userIDList, delete: requestDeleteType, succ: {
				(array) -> Void in
				
				var res: [Any] = []
				for item in array! {
					res.append(FriendOperationResultEntity(result: item));
				}
				
				CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
		
	}
	
	
	func getBlackList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.getBlackList({
			(array) -> Void in
			
			var resultData: [[String: Any]] = []
			for item in array! {
				resultData.append(V2FriendInfoEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: resultData);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func deleteFromBlackList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<Any>;
		
		V2TIMManager.sharedInstance()?.delete(fromBlackList: userIDList, succ: {
			(array) -> Void in
			
			var resultData: [FriendOperationResultEntity] = []
			for item in array! {
				resultData.append(FriendOperationResultEntity(result: item));
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(resultData));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func addToBlackList(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<Any>;
		
		
		V2TIMManager.sharedInstance()?.add(toBlackList: userIDList, succ: {
			(array) -> Void in
			
			var resultData: [FriendOperationResultEntity] = []
			for item in array! {
				resultData.append(FriendOperationResultEntity(result: item));
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(resultData));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func acceptFriendApplication(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		let typeInt = CommonUtils.getParam(call: call, result: result, param: "responseType") as? Int;
		let type = V2TIMFriendAcceptType(rawValue: typeInt ?? 1);
		var application = V2TIMFriendApplication();
		
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(res) -> Void in
			
			for item in res!.applicationList {
				let app = item as! V2TIMFriendApplication;
				if(app.userID == userID) {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.accept(application, type: type!, succ: {
				(item) -> Void in
				
				let res = FriendOperationResultEntity(result: item!);
				CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
				
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func refuseFriendApplication(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		var application = V2TIMFriendApplication();
		
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(res) -> Void in
			
			for item in res!.applicationList {
				let app = item as! V2TIMFriendApplication;
				if(app.userID == userID) {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.refuse(application, succ: {
				(item) -> Void in
				
				let res = FriendOperationResultEntity(result: item!);
				CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
				
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func deleteFriendApplication(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let userID = CommonUtils.getParam(call: call, result: result, param: "userID") as? String;
		var application = V2TIMFriendApplication();
		
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(res) -> Void in
			
			for item in res!.applicationList {
				let app = item as! V2TIMFriendApplication;
				if(app.userID == userID) {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.delete(application, succ: {
				() -> Void in
				
				CommonUtils.resultSuccess(call: call, result: result);
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func setFriendApplicationRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
		V2TIMManager.sharedInstance()?.setFriendApplicationRead({
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result);
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	/// 新建好友分组
	public func createFriendGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let groupName = CommonUtils.getParam(call: call, result: result, param: "groupName") as? String,
		   let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<String> {
			V2TIMManager.sharedInstance()?.createFriendGroup(groupName, userIDList: userIDList ,succ: {
				(array) -> Void in
	
				var res: [[String: Any]] = []
				for item in array! {
					let i = [
						"userID": item.userID!,
						"resultCode": item.resultCode,
						"resultInfo": item.resultInfo
					] as [String : Any]
					res.append(i)
				}
	
				CommonUtils.resultSuccess(call: call, result: result, data: res);
			}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
		}
	}
	
	func getFriendGroups(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupNameList = CommonUtils.getParam(call: call, result: result, param: "groupNameList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getFriendGroupList(groupNameList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for item in array! {
				let i = [
					 "name": item.groupName!,
                    "friendCount": item.userCount,
                    "friendIDList": item.friendList
				] as [String : Any]
				res.append(i)
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func deleteFriendGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupNameList = CommonUtils.getParam(call: call, result: result, param: "groupNameList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.deleteFriendGroup(groupNameList, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func renameFriendGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let oldName = CommonUtils.getParam(call: call, result: result, param: "oldName") as! String;
		let newName = CommonUtils.getParam(call: call, result: result, param: "newName") as! String;
		
		V2TIMManager.sharedInstance()?.renameFriendGroup(oldName, newName: newName, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(call: call, result: result)
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func addFriendsToFriendGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupName = CommonUtils.getParam(call: call, result: result, param: "groupName") as! String;
		let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.addFriends(toFriendGroup: groupName, userIDList: userIDList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for item in array! {
				let i = [
					"userID": item.userID!,
					"resultCode": item.resultCode,
					"resultInfo": item.resultInfo ?? ""
				] as [String : Any]
				res.append(i)
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
	}
	
	func deleteFriendsFromFriendGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let groupName = CommonUtils.getParam(call: call, result: result, param: "groupName") as! String;
		let userIDList = CommonUtils.getParam(call: call, result: result, param: "userIDList") as? Array<String>;
		
		V2TIMManager.sharedInstance()?.deleteFriends(fromFriendGroup: groupName, userIDList: userIDList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for item in array! {
				let i = [
					"userID": item.userID!,
					"resultCode": item.resultCode,
					"resultInfo": item.resultInfo ?? ""
				] as [String : Any]
				res.append(i)
			}
			
			CommonUtils.resultSuccess(call: call, result: result, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(call: call, result: result));
    }

		func searchFriends(call: FlutterMethodCall, result: @escaping FlutterResult){
        
            let searchParam = CommonUtils.getParam(call: call, result: result, param: "searchParam") as! [String: Any];
			let friendSearchParam = V2TIMFriendSearchParam();
            if (searchParam["keywordList"] != nil) {
                friendSearchParam.keywordList = searchParam["keywordList"] as? [String] ?? friendSearchParam.keywordList;
            }
            if (searchParam["isSearchNickName"] != nil) {
                friendSearchParam.isSearchNickName = searchParam["isSearchNickName"] as? Bool ?? friendSearchParam.isSearchNickName;
            }
            if(searchParam["isSearchUserID"] != nil) {
                friendSearchParam.isSearchUserID = searchParam["isSearchUserID"] as? Bool ?? friendSearchParam.isSearchUserID;
            }
            if(searchParam["isSearchRemark"] != nil) {
                friendSearchParam.isSearchRemark = searchParam["isSearchRemark"] as? Bool ?? friendSearchParam.isSearchRemark;
            }

            V2TIMManager.sharedInstance().searchFriends(friendSearchParam, succ: {
                res in
                var resultData: [[String: Any]] = [];
                if(!res!.isEmpty){
                    for item in res! {
                        resultData.append(V2FriendInfoResultEntity.getDict(info: item));
                    }
                }
               
                CommonUtils.resultSuccess(call: call, result: result, data: resultData)
            }, fail: TencentImUtils.returnErrorClosures(call: call, result: result))
        
	}
}
