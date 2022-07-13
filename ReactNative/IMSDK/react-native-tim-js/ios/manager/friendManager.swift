import ImSDK_Plus

class FriendManager {

    private var friendListener: FriendshipListener = FriendshipListener();

    public func addFriendListener(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance().addFriendListener(listener: friendListener)
		CommonUtils.resultSuccess(method: "addFriendListener", resolve: resolve, data: "addFriendListener is done");
	}

    public func removeFriendListener(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance().removeFriendListener(listener: friendListener)
		CommonUtils.resultSuccess(method: "removeFriendListener", resolve: resolve, data: "removeFriendListener is done");
	}

    func getFriendList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.getFriendList({
			(array) -> Void in
			
			var resultData: [[String: Any]] = []
			for item in array ?? [] {
				resultData.append(V2FriendInfoEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(method: "getFriendList", resolve: resolve, data: resultData);
			
		}, fail: TencentImUtils.returnErrorClosures(method: "getFriendList", resolve: resolve));
	}

    func getFriendsInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let userIDList = param["userIDList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getFriendsInfo(userIDList, succ: {
			(array) -> Void in
			
			var resultData: [[String: Any]] = []
			for item in array ?? [] {
				resultData.append(V2FriendInfoResultEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(method: "getFriendsInfo", resolve: resolve, data: resultData);
		}, fail: TencentImUtils.returnErrorClosures(method: "getFriendsInfo", resolve: resolve));
	}

    public func setFriendInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let userID = param["userID"] as? String {
			let friendRemark = param["friendRemark"] as? String
			let friendCustomInfo = param["friendCustomInfo"] as? Dictionary<String, String>
			let friendInfo = V2FriendInfoEntity.init(dict: [
				"userID": userID,
                "friendRemark": friendRemark as Any,
                "friendCustomInfo": friendCustomInfo as Any
			])
			V2TIMManager.sharedInstance().setFriendInfo(friendInfo, succ: {
				CommonUtils.resultSuccess(method: "setFriendInfo", resolve: resolve, data: "");
			}, fail: TencentImUtils.returnErrorClosures(method: "setFriendInfo", resolve: resolve));
		}
	}

    public func addFriend(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let userID = param["userID"] as? String as? String,
		   let addType = param["addType"] as? Int {
			let remark = param["remark"] as? String;
			let addWording = param["addWording"] as? String;
			let addSource = param["addSource"] as? String;
			
			let request = V2TIMFriendAddApplication();
			
			request.userID = userID;
            request.addType = V2TIMFriendType(rawValue: addType )!;
			request.friendRemark = remark ?? nil;
			request.addWording = addWording ?? nil;
			request.addSource = addSource ?? nil;
			V2TIMManager.sharedInstance()?.addFriend(request, succ: {
				(r) -> Void in
				
				let res = FriendOperationResultEntity(result: r!);
				CommonUtils.resultSuccess(method: "addFriend", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
				
			}, fail: TencentImUtils.returnErrorClosures(method: "addFriend", resolve: resolve));
		}
	}

    func deleteFromFriendList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let userIDList = param["userIDList"] as? Array<Any>,
		   let deleteType = param["deleteType"] as? Int {
            let requestDeleteType = V2TIMFriendType(rawValue: deleteType )!;
			
			V2TIMManager.sharedInstance()?.delete(fromFriendList: userIDList, delete: requestDeleteType, succ: {
				(array) -> Void in
				
				var res: [Any] = []
                    for item in array ?? [] {
                        res.append(FriendOperationResultEntity(result: item));
                    }

				
				CommonUtils.resultSuccess(method: "deleteFromFriendList", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
			}, fail: TencentImUtils.returnErrorClosures(method: "deleteFromFriendList", resolve: resolve));
		}
	}

    func checkFriend(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let userIDList = param["userIDList"] as? Array<String>,
		   let checkType = param["checkType"] as? Int {
			V2TIMManager.sharedInstance()?.checkFriend(userIDList, check: V2TIMFriendType(rawValue: checkType)!, succ: {
				(array) -> Void in
				
				var res: [Any] = []
				for item in array ?? [] {
					res.append(FriendCheckResultEntity(result: item));
				}
				
				CommonUtils.resultSuccess(method: "checkFriend", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
			}, fail: TencentImUtils.returnErrorClosures(method: "checkFriend", resolve: resolve));
		}
		
	}

    func getFriendApplicationList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(list) -> Void in
			
			let res = V2FriendApplicationResultEntity(result: list!);
			let data = [
                "unreadCount": res.unreadCount as Any,
                "friendApplicationList": JsonUtil.getDictionaryOrArrayFromObject(res.applicationList as Any)
			]
			
			CommonUtils.resultSuccess(method: "getFriendApplicationList", resolve: resolve, data: data);
		}, fail: TencentImUtils.returnErrorClosures(method: "getFriendApplicationList", resolve: resolve));
	}

    func acceptFriendApplication(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let userID = param["userID"] as? String;
		let typeInt = param["responseType"] as? Int;
		let type = V2TIMFriendAcceptType(rawValue: typeInt ?? 1);
		var application = V2TIMFriendApplication();
		
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(res) -> Void in
			
            for item in res?.applicationList ?? [] {
				let app = item as! V2TIMFriendApplication;
				if(app.userID == userID) {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.accept(application, type: type!, succ: {
				(item) -> Void in
				
				let res = FriendOperationResultEntity(result: item!);
				CommonUtils.resultSuccess(method: "acceptFriendApplication", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
				
			}, fail: TencentImUtils.returnErrorClosures(method: "acceptFriendApplication", resolve: resolve));
		}, fail: TencentImUtils.returnErrorClosures(method: "acceptFriendApplication", resolve: resolve));
	}
	
	func refuseFriendApplication(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let userID = param["userID"] as? String;
		var application = V2TIMFriendApplication();
		
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(res) -> Void in
			
			for item in res?.applicationList ?? [] {
				let app = item as! V2TIMFriendApplication;
				if(app.userID == userID) {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.refuse(application, succ: {
				(item) -> Void in
				
				let res = FriendOperationResultEntity(result: item!);
				CommonUtils.resultSuccess(method: "refuseFriendApplication", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
				
			}, fail: TencentImUtils.returnErrorClosures(method: "refuseFriendApplication", resolve: resolve));
		}, fail: TencentImUtils.returnErrorClosures(method: "refuseFriendApplication", resolve: resolve));
	}
	
	func deleteFriendApplication(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let userID = param["userID"] as? String;
		var application = V2TIMFriendApplication();
		
		V2TIMManager.sharedInstance()?.getFriendApplicationList({
			(res) -> Void in
			
			for item in res?.applicationList ?? [] {
				let app = item as! V2TIMFriendApplication;
				if(app.userID == userID) {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.delete(application, succ: {
				() -> Void in
				
				CommonUtils.resultSuccess(method: "deleteFriendApplication", resolve: resolve);
			}, fail: TencentImUtils.returnErrorClosures(method: "deleteFriendApplication", resolve: resolve));
		}, fail: TencentImUtils.returnErrorClosures(method: "deleteFriendApplication", resolve: resolve));
	}

    func setFriendApplicationRead(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.setFriendApplicationRead({
			() -> Void in
			
			CommonUtils.resultSuccess(method: "setFriendApplicationRead", resolve: resolve);
		}, fail: TencentImUtils.returnErrorClosures(method: "setFriendApplicationRead", resolve: resolve));
	}

    func getBlackList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.getBlackList({
			(array) -> Void in
			
			var resultData: [[String: Any]] = []
			for item in array ?? [] {
				resultData.append(V2FriendInfoEntity.getDict(info: item));
                }
			
			CommonUtils.resultSuccess(method: "getBlackList", resolve: resolve, data: resultData);
		}, fail: TencentImUtils.returnErrorClosures(method: "getBlackList", resolve: resolve));
	}
	
	func deleteFromBlackList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let userIDList = param["userIDList"] as? Array<Any>;
		V2TIMManager.sharedInstance()?.delete(fromBlackList: userIDList, succ: {
			(array) -> Void in
			
			var resultData: [FriendOperationResultEntity] = []
			for item in array ?? [] {
				resultData.append(FriendOperationResultEntity(result: item));
			}
			
			CommonUtils.resultSuccess(method: "deleteFromBlackList", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(resultData));
		}, fail: TencentImUtils.returnErrorClosures(method: "deleteFromBlackList", resolve: resolve));
	}
	
	func addToBlackList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let userIDList = param["userIDList"] as? Array<Any>;
		V2TIMManager.sharedInstance()?.add(toBlackList: userIDList, succ: {
			(array) -> Void in
			
			var resultData: [FriendOperationResultEntity] = []
			for item in array ?? [] {
				resultData.append(FriendOperationResultEntity(result: item));
			}
			
			CommonUtils.resultSuccess(method: "addToBlackList", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(resultData));
		}, fail: TencentImUtils.returnErrorClosures(method: "addToBlackList", resolve: resolve));
	}

    public func createFriendGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let groupName = param["groupName"] as? String,
		   let userIDList = param["userIDList"] as? Array<String> {
			V2TIMManager.sharedInstance()?.createFriendGroup(groupName, userIDList: userIDList ,succ: {
				(array) -> Void in
	
				var res: [[String: Any]] = []
				for item in array ?? [] {
					let i = [
                        "userID": item.userID ?? "",
						"resultCode": item.resultCode,
                        "resultInfo": item.resultInfo as Any
					] as [String : Any]
					res.append(i)
				}
	
				CommonUtils.resultSuccess(method: "createFriendGroup", resolve: resolve, data: res);
			}, fail: TencentImUtils.returnErrorClosures(method: "createFriendGroup", resolve: resolve));
		}
	}
	
	func getFriendGroups(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupNameList = param["groupNameList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getFriendGroupList(groupNameList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for item in array ?? [] {
				let i = [
					 "name": item.groupName ?? "",
                    "friendCount": item.userCount,
                     "friendIDList": item.friendList as Any
				] as [String : Any]
				res.append(i)
			}
			
			CommonUtils.resultSuccess(method: "getFriendGroups", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(method: "getFriendGroups", resolve: resolve));
	}
	
	func deleteFriendGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupNameList = param["groupNameList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.deleteFriendGroup(groupNameList, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "deleteFriendGroup", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "deleteFriendGroup", resolve: resolve));
	}

    func renameFriendGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let oldName = param["oldName"] as? String;
		let newName = param["newName"] as? String;
		
		V2TIMManager.sharedInstance()?.renameFriendGroup(oldName, newName: newName, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "renameFriendGroup", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "renameFriendGroup", resolve: resolve));
	}
	
	func addFriendsToFriendGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupName = param["groupName"] as? String;
		let userIDList = param["userIDList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.addFriends(toFriendGroup: groupName, userIDList: userIDList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for item in array ?? [] {
				let i = [
					"userID": item.userID ?? "",
					"resultCode": item.resultCode,
					"resultInfo": item.resultInfo ?? ""
				] as [String : Any]
				res.append(i)
			}
			
			CommonUtils.resultSuccess(method: "addFriendsToFriendGroup", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(method: "addFriendsToFriendGroup", resolve: resolve));
	}
	
	func deleteFriendsFromFriendGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupName = param["groupName"] as? String;
		let userIDList = param["userIDList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.deleteFriends(fromFriendGroup: groupName, userIDList: userIDList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for item in array ?? [] {
				let i = [
					"userID": item.userID ?? "",
					"resultCode": item.resultCode,
					"resultInfo": item.resultInfo ?? ""
				] as [String : Any]
				res.append(i)
			}
			
			CommonUtils.resultSuccess(method: "deleteFriendsFromFriendGroup", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(method: "deleteFriendsFromFriendGroup", resolve: resolve));
    }

		func searchFriends(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        
            let searchParam = param["searchParam"] as! [String: Any];
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
                    for item in res ?? [] {
                        resultData.append(V2FriendInfoResultEntity.getDict(info: item));
                    }
                }
               
                CommonUtils.resultSuccess(method: "searchFriends", resolve: resolve, data: resultData)
            }, fail: TencentImUtils.returnErrorClosures(method: "searchFriends", resolve: resolve))
        
	}
}