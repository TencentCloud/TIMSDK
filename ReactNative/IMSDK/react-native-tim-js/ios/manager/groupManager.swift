import ImSDK_Plus

class GroupManager {
    public func createGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let groupType = param["groupType"] as? String;
		let groupName = param["groupName"] as? String;
		let notification = param["notification"] as? String;
		let introduction = param["introduction"] as? String;
		let faceURL = param["faceUrl"] as? String;
		let addOpt = param["addOpt"] as? Int;
		let memberListMap = param["memberList"] as? [[String: Any]];
        let isAllMuted = param["isAllMuted"] as? Bool;
        let isSupportTopic = param["isSupportTopic"] as? Bool;
        
		let info = V2TIMGroupInfo();
		info.groupID = groupID;
		info.groupType = groupType as String?;
		info.groupName = groupName;
		info.notification = notification;
		info.introduction = introduction;
		info.faceURL = faceURL;
		info.groupAddOpt = V2TIMGroupAddOpt(rawValue: addOpt ?? 2)!;
        info.allMuted = isAllMuted ?? false;
        info.isSupportTopic = isSupportTopic ?? false
        
		var memberList: [V2TIMCreateGroupMemberInfo] = []
		if memberListMap != nil {
			for i in memberListMap! {
				let item = V2TIMCreateGroupMemberInfo()
                item.userID = i["userID"] as? String;
                item.role = i["role"] as? UInt32 ?? 200;
				memberList.append(item);
			}
		}
		
		V2TIMManager.sharedInstance()?.createGroup(info, memberList: memberList, succ: {
			(id) -> Void in
			
			CommonUtils.resultSuccess(method: "createGroup", resolve: resolve, data: id!)
		}, fail: TencentImUtils.returnErrorClosures(method: "createGroup", resolve: resolve));
	}

    public func joinGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
        let msg = param["message"] as? String;
		
		V2TIMManager.sharedInstance()?.joinGroup(groupID, msg: msg ?? "", succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "joinGroup", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "joinGroup", resolve: resolve));
	}

    public func quitGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		
		V2TIMManager.sharedInstance()?.quitGroup(groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "quitGroup", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "quitGroup", resolve: resolve));
	}

    public func dismissGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		
		V2TIMManager.sharedInstance()?.dismissGroup(groupID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "dismissGroup", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "dismissGroup", resolve: resolve));
	}

	func getJoinedGroupList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.getJoinedGroupList({
			(array) -> Void in
			
			var res: [[String: Any]] = []
			for info in array ?? [] {
				res.append(V2GroupInfoEntity.getDict(info: info))
			}
			CommonUtils.resultSuccess(method: "getJoinedGroupList", resolve: resolve, data: res);
		}, fail: TencentImUtils.returnErrorClosures(method: "getJoinedGroupList", resolve: resolve));
	}
	
	func getGroupsInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupIDList = param["groupIDList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getGroupsInfo(groupIDList, succ: {
			(array) -> Void in
			
			var groupList: [[String: Any]] = []
			for item in array ?? [] {
                let i = ["resultCode": item.resultCode, "resultMessage": item.resultMsg!, "groupInfo": V2GroupInfoEntity.getDict(info: item.info)] as [String : Any]
				groupList.append(i)
			}
			
			CommonUtils.resultSuccess(method: "getGroupsInfo", resolve: resolve, data: groupList);
		}, fail: TencentImUtils.returnErrorClosures(method: "getGroupsInfo", resolve: resolve));
	}

	/// 修改群资料
    public func setGroupInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let info = V2GroupInfoEntity.init(dict: param)
			V2TIMManager.sharedInstance().setGroupInfo(info, succ: {
				CommonUtils.resultSuccess(method: "setGroupInfo", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "setGroupInfo", resolve: resolve))
    }

	// 初始化群属性，会清空原有的群属性列表
    public func initGroupAttributes(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        if let groupID = param["groupID"] as? String,
           let attributes = param["attributes"] as? Dictionary<String, String> {
            V2TIMManager.sharedInstance().initGroupAttributes(groupID, attributes: attributes, succ: {
                CommonUtils.resultSuccess(method: "initGroupAttributes", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "initGroupAttributes", resolve: resolve))
        }
    }

	/// 设置群属性
    public func setGroupAttributes(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        if let groupID = param["groupID"] as? String,
           let attributes = param["attributes"]  as? Dictionary<String, String> {
            V2TIMManager.sharedInstance().setGroupAttributes(groupID, attributes: attributes, succ: {
                CommonUtils.resultSuccess(method: "setGroupAttributes", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "setGroupAttributes", resolve: resolve))
        }
    }

    /// 删除群属性
    public func deleteGroupAttributes(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        let keys = param["keys"] as? Array<String>;
        if let groupID = param["groupID"] as? String {
            V2TIMManager.sharedInstance().deleteGroupAttributes(groupID, keys: keys, succ: {
                CommonUtils.resultSuccess(method: "deleteGroupAttributes", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "deleteGroupAttributes", resolve: resolve))
        }
    }

    /// 获得群属性
    public func getGroupAttributes(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        let keys = param["keys"] as? Array<String>;
        if let groupID = param["groupID"] as? String {
            V2TIMManager.sharedInstance().getGroupAttributes(groupID, keys: keys, succ: {
                dictionary in
				CommonUtils.resultSuccess(method: "getGroupAttributes", resolve: resolve, data: dictionary!)
			}, fail: TencentImUtils.returnErrorClosures(method: "getGroupAttributes", resolve: resolve))
        }
    }
	
	/// 获得群在线人数
	public func getGroupOnlineMemberCount(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		if let groupID = param["groupID"] as? String {
			V2TIMManager.sharedInstance().getGroupOnlineMemberCount(groupID, succ: {
				count in
				CommonUtils.resultSuccess(method: "getGroupOnlineMemberCount", resolve: resolve, data: count)
			}, fail: TencentImUtils.returnErrorClosures(method: "getGroupOnlineMemberCount", resolve: resolve))
		}
	}

	func setGroupApplicationRead(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.setGroupApplicationRead({
			() -> Void in
			
			CommonUtils.resultSuccess(method: "setGroupApplicationRead", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "setGroupApplicationRead", resolve: resolve));
	}

	func searchGroups(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock){
        let searchParam = param["searchParam"] as! [String: Any];
        let groupSearchParam = V2TIMGroupSearchParam();
        
        if(searchParam["keywordList"] != nil){
            groupSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["isSearchGroupID"] != nil){
            groupSearchParam.isSearchGroupID = searchParam["isSearchGroupID"] as! Bool;
        }
        if(searchParam["isSearchGroupName"] != nil){
            groupSearchParam.isSearchGroupName = searchParam["isSearchGroupName"] as! Bool;
        }
        
            V2TIMManager.sharedInstance().searchGroups(groupSearchParam, succ: {
				array in
                var list = [[String: Any]]();
                for item in array! {
                    list.append( V2GroupInfoEntity.getDict(info: item) );
                }
				CommonUtils.resultSuccess(method: "searchGroups", resolve: resolve, data: list)
			}, fail: TencentImUtils.returnErrorClosures(method: "searchGroups", resolve: resolve))
	}

	func searchGroupMembers(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock){
        let searchParam =  param["param"] as! [String: Any];
        let groupMemberSearchParam = V2TIMGroupMemberSearchParam();
        
        if(searchParam["keywordList"] != nil){
            groupMemberSearchParam.keywordList = searchParam["keywordList"] as? [String];
        }
        if(searchParam["groupIDList"] != nil){
            groupMemberSearchParam.groupIDList = searchParam["groupIDList"] as? [String];
            if groupMemberSearchParam.groupIDList.isEmpty {
                groupMemberSearchParam.groupIDList = nil;
            }
        }
        if(searchParam["isSearchMemberUserID"] != nil){
            groupMemberSearchParam.isSearchMemberUserID = searchParam["isSearchMemberUserID"] as! Bool;
        }
        if(searchParam["isSearchGroupName"] != nil){
            groupMemberSearchParam.isSearchMemberNickName = searchParam["isSearchGroupName"] as! Bool;
        }
        if(searchParam["isSearchMemberRemark"] != nil){
            groupMemberSearchParam.isSearchMemberRemark = searchParam["isSearchMemberRemark"] as! Bool;
        }
        if(searchParam["isSearchMemberNameCard"] != nil){
            groupMemberSearchParam.isSearchMemberNameCard = searchParam["isSearchMemberNameCard"] as! Bool;
        }
            V2TIMManager.sharedInstance().searchGroupMembers(groupMemberSearchParam, succ: {
                (array) -> Void in
                
                var resMap = [String: [Any]]();
                // 第一层Map
                for (key, value) in array! {
                    var tempArr: [Any] = [];
                    // 第二层数组
                    for value01 in value {
                        tempArr.append(V2GroupMemberFullInfoEntity.getDict(info: value01));
                    }
                    resMap.updateValue(tempArr, forKey: key)
                }
                
                CommonUtils.resultSuccess(method: "searchGroupMembers", resolve: resolve, data: resMap)
            }, fail: TencentImUtils.returnErrorClosures(method: "searchGroupMembers", resolve: resolve))
	}

	// 无加群申请，sdk回调不会执行
	func getGroupApplicationList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		V2TIMManager.sharedInstance()?.getGroupApplicationList({
			(info) -> Void in
			
			CommonUtils.resultSuccess(method: "getGroupApplicationList", resolve: resolve, data: V2GroupApplicationResultEntity.getDict(info: info!))
		}, fail: TencentImUtils.returnErrorClosures(method: "getGroupApplicationList", resolve: resolve));
	}
	
	func acceptGroupApplication(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let fromUser = param["fromUser"] as? String;
		let reason = param["reason"] as? String;
		var application = V2TIMGroupApplication();
		
		V2TIMManager.sharedInstance()?.getGroupApplicationList({
			(array) -> Void in
			
			for item in array?.applicationList ?? [] {
				let app = item as! V2TIMGroupApplication;
				if app.fromUser == fromUser && app.groupID == groupID {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.accept(application, reason: reason, succ: {
				() -> Void in
				
				CommonUtils.resultSuccess(method: "acceptGroupApplication", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "acceptGroupApplication", resolve: resolve));
		}, fail: TencentImUtils.returnErrorClosures(method: "acceptGroupApplication", resolve: resolve));
	}
	
	func refuseGroupApplication(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let fromUser = param["fromUser"] as? String;
		let reason = param["reason"]as? String;
		var application = V2TIMGroupApplication();
		
		V2TIMManager.sharedInstance()?.getGroupApplicationList({
			(array) -> Void in
			
			for item in array?.applicationList ?? [] {
				let app = item as! V2TIMGroupApplication;
				if app.fromUser == fromUser && app.groupID == groupID {
					application = app
				}
			}
			
			V2TIMManager.sharedInstance()?.refuse(application, reason: reason, succ: {
				() -> Void in
				
				CommonUtils.resultSuccess(method: "refuseGroupApplication", resolve: resolve)
			}, fail: TencentImUtils.returnErrorClosures(method: "refuseGroupApplication", resolve: resolve));
		}, fail: TencentImUtils.returnErrorClosures(method: "refuseGroupApplication", resolve: resolve));
	}

	func getGroupMemberList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let filterParam = param["filter"] as? Int;
		let nextSeqParam = param["nextSeq"] as? String;
		var filter = V2TIMGroupMemberFilter(rawValue: 0);
		var nextSeq: String = "0";
		
		if(filterParam != nil) {
			filter = V2TIMGroupMemberFilter(rawValue: filterParam!)!
		}
		if(nextSeqParam != nil) {
			nextSeq = nextSeqParam!
		}
		
        V2TIMManager.sharedInstance()?.getGroupMemberList(groupID, filter: UInt32(filter!.rawValue), nextSeq: UInt64(nextSeq)!, succ: {
			(nextSeq, memberList) -> Void in
			
			var res: [[String: Any]] = []
			
			for item in memberList ?? [] {
				res.append(V2GroupMemberFullInfoEntity.getDict(info: item))
			}
			
			CommonUtils.resultSuccess(method: "getGroupMemberList", resolve: resolve, data: ["nextSeq": String(nextSeq), "memberInfoList": res]);
		}, fail: TencentImUtils.returnErrorClosures(method: "getGroupMemberList", resolve: resolve));
	}
	
	func getGroupMembersInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let memberList = param["memberList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.getGroupMembersInfo(groupID, memberList: memberList, succ: {
			(array) -> Void in
			
			var res: [[String: Any]] = []
			
			for item in array ?? [] {
				res.append(V2GroupMemberFullInfoEntity.getDict(info: item));
			}
			
			CommonUtils.resultSuccess(method: "getGroupMembersInfo", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(method: "getGroupMembersInfo", resolve: resolve));
	}
	
	
	
	func setGroupMemberInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID =  param["groupID"] as! String;
		let userID =  param["userID"] as! String;
		let nameCard =  param["nameCard"] as! String;
		let customInfo =  param["customInfo"] as? Dictionary<String, String>;
		var customInfoData: [String: Data] = [:]
		
		if customInfo != nil {
			for (key, value) in customInfo! {
				customInfoData[key] = value.data(using: String.Encoding.utf8, allowLossyConversion: true);
			}
		}
		
		V2TIMManager.sharedInstance()?.getGroupMembersInfo(groupID, memberList: userID.components(separatedBy: ","), succ: {
			(array) -> Void in
			
			var info: V2TIMGroupMemberFullInfo;
			for item in array ?? [] {
				if item.userID == userID {
					info = item
					info.nameCard = nameCard
					info.customInfo = customInfoData
					
					V2TIMManager.sharedInstance()?.setGroupMemberInfo(groupID, info: info, succ: {
						() -> Void in
						
						CommonUtils.resultSuccess(method: "setGroupMemberInfo", resolve: resolve)
					}, fail: TencentImUtils.returnErrorClosures(method: "setGroupMemberInfo", resolve: resolve));
				}
			}
		}, fail: TencentImUtils.returnErrorClosures(method: "setGroupMemberInfo", resolve: resolve));
	}
	
	func muteGroupMember(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let userID = param["userID"] as? String;
		let seconds = (param["seconds"] as? UInt32)!;
		
		V2TIMManager.sharedInstance()?.muteGroupMember(groupID, member: userID, muteTime: seconds, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "muteGroupMember", resolve: resolve);
		}, fail: TencentImUtils.returnErrorClosures(method: "muteGroupMember", resolve: resolve));
	}
	
	func inviteUserToGroup(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let userList = param["userList"] as? Array<String>;
		
		V2TIMManager.sharedInstance()?.inviteUser(toGroup: groupID, userList: userList, succ: {
			(array) -> Void in
			
			var res: [GroupMemberOperationResultEntity] = []
			
			for item in array! {
				res.append(GroupMemberOperationResultEntity(result: item))
			}
			
			CommonUtils.resultSuccess(method: "inviteUserToGroup", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(method: "inviteUserToGroup", resolve: resolve));
	}
	
	func kickGroupMember(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let memberList = param["memberList"] as? Array<String>;
		let reason = param["reason"] as? String;
		
		V2TIMManager.sharedInstance()?.kickGroupMember(groupID, memberList: memberList, reason: reason, succ: {
			(array) -> Void in
			
			var res: [GroupMemberOperationResultEntity] = []
			
			for item in array ?? [] {
				res.append(GroupMemberOperationResultEntity(result: item))
			}
			
			CommonUtils.resultSuccess(method: "kickGroupMember", resolve: resolve, data: JsonUtil.getDictionaryOrArrayFromObject(res));
		}, fail: TencentImUtils.returnErrorClosures(method: "kickGroupMember", resolve: resolve));
	}
	
	func setGroupMemberRole(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let userID = param["userID"] as? String;
		let role = param["role"] as! Int;
		
        V2TIMManager.sharedInstance()?.setGroupMemberRole(groupID, member: userID, newRole: UInt32(V2TIMGroupMemberRole(rawValue: role)!.rawValue), succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "setGroupMemberRole", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "setGroupMemberRole", resolve: resolve));
	}
	
	func transferGroupOwner(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
		let groupID = param["groupID"] as? String;
		let userID = param["userID"] as? String;
		
		V2TIMManager.sharedInstance()?.transferGroupOwner(groupID, member: userID, succ: {
			() -> Void in
			
			CommonUtils.resultSuccess(method: "transferGroupOwner", resolve: resolve)
		}, fail: TencentImUtils.returnErrorClosures(method: "transferGroupOwner", resolve: resolve));
	}


	 public func getJoinedCommunityList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        V2TIMManager.sharedInstance().getJoinedCommunityList { infos in
            var dataList: [[String: Any]]  = [];
            infos?.forEach({ info_item in
                dataList.append(V2GroupInfoEntity.getDict(info: info_item))
            })
            CommonUtils.resultSuccess(method: "getJoinedCommunityList", resolve: resolve, data:dataList);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "getJoinedCommunityList",  resolve: resolve)
        }
    }
    
    public func createTopicInCommunity(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        let groupID = param["groupID"] as? String;
        let topicInfo = param["topicInfo"] as? [String:Any] ;
        
        let info = V2TIMTopicInfoEntity.init(dict: topicInfo!);
        
        V2TIMManager.sharedInstance().createTopic(inCommunity: groupID, topicInfo: info) { groupid in
            CommonUtils.resultSuccess(method: "createTopicInCommunity", resolve: resolve, data:groupid as Any);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "createTopicInCommunity", resolve: resolve)
        }

    }
    public func deleteTopicFromCommunity(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        let groupID = param["groupID"] as? String;
        let topicIDList = param["topicIDList"] as? Array<String>;
        V2TIMManager.sharedInstance().deleteTopic(fromCommunity: groupID, topicIDList: topicIDList) { _array in
            var list: [[String: Any]]  = [];
            _array?.forEach({ item in
                let i = item as? V2TIMTopicOperationResult
                var _item:[String:Any] = [:];
                _item["errorCode"] = i?.errorCode as Any?
                _item["errorMsg"] = i?.errorMsg as Any?
                _item["topicID"] = i?.topicID as Any?
                list.append(_item)
            })
            CommonUtils.resultSuccess(method: "deleteTopicFromCommunity", resolve: resolve, data:list);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "deleteTopicFromCommunity",resolve: resolve)
        }
    }
    public func setTopicInfo(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        let topicInfo = param["topicInfo"] as? [String:Any] ;
        let info = V2TIMTopicInfoEntity.init(dict: topicInfo!);
        
        V2TIMManager.sharedInstance().setTopicInfo(info) {
            CommonUtils.resultSuccess(method: "setTopicInfo", resolve: resolve);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "setTopicInfo",resolve: resolve)
        }
        
    }
    
    public func getTopicInfoList(param: [String: Any], resolve:@escaping RCTPromiseResolveBlock) {
        let groupID = param["groupID"] as? String;
        let topicIDList = param["topicIDList"] as? Array<String>;
        
        V2TIMManager.sharedInstance().getTopicInfoList(groupID, topicIDList: topicIDList) { _array in
            var list: [[String: Any]]  = [];
        
            _array?.forEach({ item in
                let i = item as? V2TIMTopicInfoResult
                
                var _item:[String:Any] = [:];
                _item["errorCode"] = i?.errorCode as Any?
                _item["errorMsg"] = i?.errorMsg as Any?
                _item["topicInfo"] = V2TIMTopicInfoEntity.getDict(info: i!.topicInfo)
                list.append(_item)
            })
            CommonUtils.resultSuccess(method: "getTopicInfoList", resolve: resolve, data:list);
        } fail: { code, desc in
            CommonUtils.resultFailed(desc: desc, code: code, method: "getTopicInfoList",resolve: resolve)
        }

    }
}