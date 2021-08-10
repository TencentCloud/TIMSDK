import  ImSDK_Plus
import Hydra

public class V2MessageEntity {
	var msgID: String?;
	var timestamp: Date? = Date();
	var sender: String?;
	var nickName: String?;
	var friendRemark: String?;
	var nameCard: String?;
	var faceUrl: String?;
	var groupID: String?;
	var userID: String?;
	var status: Int?;
	var isSelf: Bool?;
	var isRead: Bool?;
	var isPeerRead: Bool?;
	var groupAtUserList: [String]?;
	var elemType: Int?;
	var textElem: [String: Any]?;
	var customElem: [String: Any]?;
	var imageElem: [String: Any]?;
	var soundElem: [String: Any]?;
	var videoElem: [String: Any]?;
	var fileElem: [String: Any]?;
	var locationElem: [String: Any]?;
	var faceElem: [String: Any]?;
	var mergerElem: [String: Any]?;
	var groupTipsElem: [String: Any]?;
	var localCustomData: String?;
	var cloudCustomData: String?;
	var localCustomInt: Int32?;
	var seq: String?;
	var random: UInt64?;
	var isExcludedFromUnreadCount: Bool?;
	var v2message: V2TIMMessage;
	
	func getUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.soundElem.getUrl({ resolve($0 ?? "") })
		})
	}
	
	func getVideoUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.videoElem.getVideoUrl({ resolve($0 ?? "") })
		})
	}
	
	func getSnapshotUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.videoElem.getSnapshotUrl({ resolve($0 ?? "") })
		})
	}
	
	func getFileUrl(_ message: V2TIMMessage) -> Promise<String> {
		return Promise<String>(in: .main, { resolve, reject, _ in
			message.fileElem.getUrl({ resolve($0 ?? "") })
		})
	}
	
	func downloadMergerMessage(_ message: V2TIMMessage) -> Promise<Array<V2TIMMessage>> {
		return Promise<Array<V2TIMMessage>>(in: .main, { resolve, reject, _ in
			message.mergerElem.downloadMergerMessage({ resolve($0 ?? []) }, fail: {_,_ in })
		})
	}

	func getDictAll(progress: Int? = 100, status: Int? = nil) -> Promise<Dictionary<String, Any>> {
		return async({
			_ -> Dictionary<String, Any> in
			
			var dict = self.getDict(progress: progress, status: status)
			
			if self.v2message.soundElem != nil {
				let url = try Hydra.await(self.getUrl(self.v2message))
				self.soundElem!["url"] = url
				dict["soundElem"] = self.soundElem
			}
			
			if self.v2message.fileElem != nil {
				let url = try Hydra.await(self.getFileUrl(self.v2message))
				self.fileElem!["url"] = url
				dict["fileElem"] = self.fileElem
			}
			
			if self.v2message.videoElem != nil {
				let videoUrl = try Hydra.await(self.getVideoUrl(self.v2message))
				let snapshotUrl = try Hydra.await(self.getSnapshotUrl(self.v2message))
				self.videoElem!["videoUrl"] = videoUrl
				self.videoElem!["snapshotUrl"] = snapshotUrl
				dict["videoElem"] = self.videoElem
			}
			
			if self.mergerElem != nil {
				let messageList = try Hydra.await(self.downloadMergerMessage(self.v2message))
				var list: Array<Dictionary<String, Any>> = []
				for item in messageList {
					let msg = try Hydra.await(V2MessageEntity.init(message: item).getDictAll())
					list.append(msg)
				}
				self.mergerElem!["messageList"] = list
				dict["mergerElem"] = self.mergerElem
			}
			
			return dict
		}).then({ $0 })
	}
	
	func getDict(progress: Int? = nil, status: Int? = nil) -> [String: Any] {
		var result: [String: Any] = [:]
		result["msgID"] = self.msgID
		result["sender"] = self.sender
		result["nickName"] = self.nickName
		result["friendRemark"] = self.friendRemark
		result["nameCard"] = self.nameCard
		result["faceUrl"] = self.faceUrl
		result["groupID"] = self.groupID
		result["userID"] = self.userID
		result["status"] = self.status
		result["isSelf"] = self.isSelf
		result["isRead"] = self.isRead
		result["isPeerRead"] = self.isPeerRead
		result["groupAtUserList"] = self.groupAtUserList
		result["elemType"] = self.elemType
		result["localCustomInt"] = self.localCustomInt
		result["textElem"] = self.textElem;
		result["customElem"] = self.customElem;
		result["imageElem"] = self.imageElem;
		result["soundElem"] = self.soundElem;
		result["videoElem"] = self.videoElem;
		result["fileElem"] = self.fileElem;
		result["locationElem"] = self.locationElem;
		result["faceElem"] = self.faceElem;
		result["mergerElem"] = self.mergerElem;
		result["groupTipsElem"] = self.groupTipsElem;
		result["localCustomData"] = self.localCustomData;
		result["localCustomInt"] = self.localCustomInt;
		result["cloudCustomData"] = self.cloudCustomData;
        result["seq"] = String(self.seq!)
		result["random"] = self.random;
		result["isExcludedFromUnreadCount"] = self.isExcludedFromUnreadCount;
		result["timestamp"] = (self.timestamp == nil) ? Int(Date().timeIntervalSince1970) : Int(self.timestamp!.timeIntervalSince1970)
		
		return result
	}
	
	init(message : V2TIMMessage) {
		let base = NSTemporaryDirectory()
		self.msgID = message.msgID;
		self.timestamp = message.timestamp as Date?;
		self.sender = message.sender;
		self.nickName = message.nickName;
		self.friendRemark = message.friendRemark;
		self.nameCard = message.nameCard;
		self.faceUrl = message.faceURL;
		self.groupID = message.groupID;
		self.userID = message.userID;
		self.status = message.status.rawValue;
		self.isSelf = message.isSelf;
		self.isRead = message.isRead;
		self.groupAtUserList = message.groupAtUserList as? [String];
		self.isPeerRead = message.isPeerRead;
		self.elemType = message.elemType.rawValue;
		self.localCustomInt = message.localCustomInt;
		self.seq = String(message.seq);
		self.random = message.random;
		self.isExcludedFromUnreadCount = message.isExcludedFromUnreadCount;
		self.v2message = message
		
		if message.localCustomData != nil {
			self.localCustomData = String.init(data: message.localCustomData!, encoding: String.Encoding.utf8)!;
		}
		if message.cloudCustomData != nil {
			self.cloudCustomData = String.init(data: message.cloudCustomData!, encoding: String.Encoding.utf8)!;
		}
		// 文本消息
		if message.textElem != nil {
			self.textElem = ["text": message.textElem.text ?? ""];
		}
		// 自定义消息
		if let elem = message.customElem {
			self.customElem = [
				"data": String.init(data: message.customElem.data!, encoding: String.Encoding.utf8)!,
				"desc": message.customElem.desc,
				"extension": message.customElem.extension
			];
		}
		// 3图片消息
		if let elem = message.imageElem {
			var list:[[String: Any]] = [];
			self.imageElem = [:];
			self.imageElem!["path"] = message.imageElem.path ?? "";
			
			if elem.imageList.isEmpty {
				self.imageElem!["imageList"] = [["img": ""]]
			}
			
			for image in elem.imageList! {
				var item: [String: Any] = [:];
				let fileManager = FileManager.default;
				let path = base + "\(image.uuid!)";
				item["uuid"] = image.uuid;
				item["type"] = image.type.rawValue;
				item["size"] = image.size;
				item["width"] = image.width;
				item["height"] = image.height;
				item["url"] = image.url;
				
				if !fileManager.fileExists(atPath: path) && (item["url"] as! String).count > 10 {
					image.downloadImage(path, progress: {
						(curSize, totalSize) -> Void in
						// print(curSize);
					}, succ: {
						
					}, fail: {
						(code, msg) -> Void in
						item["url"] = "";
					})
					
				} else {
					// 图片存在，无需处理
				}
				list.append(item);
				self.imageElem!["imageList"] = list;
				self.imageElem!["url"] = item["url"]
			}
		}
		// 4语音消息
		if message.soundElem != nil {
			let url = "";
			let path = base + "\(message.soundElem.uuid ?? "")";
			let fileManager = FileManager.default;

			self.soundElem = [
				"uuid": message.soundElem.uuid,
				"dataSize": message.soundElem.dataSize,
				"duration": message.soundElem.duration,
				"url": url,
				"path": path
			]
			
			if !fileManager.fileExists(atPath: path) {
				message.soundElem.downloadSound(path, progress: {
					(curSize, totalSize) -> Void in
				}, succ: {
				}, fail: {
					(code, msg) -> Void in
				})
			} else {}
		}
		
		// 5视频消息
		if let elem = message.videoElem {
			let pathSnapshot = base + "\(message.videoElem.snapshotUUID)";
			let pathVideo = base + "\(message.videoElem.videoUUID)";
			let fileManager = FileManager.default;
			var videoUrl: String? = nil;
			var snapshotUrl: String? = nil;
			
			self.videoElem = [
				"snapshotUUID": message.videoElem.snapshotUUID,
				"snapshotPath": message.videoElem.snapshotPath,
				"snapshotUrl": snapshotUrl,
				"snapshotSize": message.videoElem.snapshotSize,
				"snapshotWidth": message.videoElem.snapshotWidth,
				"snapshotHeight": message.videoElem.snapshotHeight,
				"UUID": message.videoElem.videoUUID,
				"videoPath": message.videoElem.videoPath,
				"videoUrl": videoUrl,
				"videoSize": message.videoElem.videoSize,
				"duration": message.videoElem.duration
			];
			
			if !fileManager.fileExists(atPath: pathSnapshot) {
				message.videoElem.downloadSnapshot(pathSnapshot, progress: {
					(curSize, totalSize) -> Void in
				}, succ: {
				}, fail: {
					(code, msg) -> Void in
				})
			} else {}

			if !fileManager.fileExists(atPath: pathVideo) {
				message.videoElem.downloadVideo(pathVideo, progress: {
					(curSize, totalSize) -> Void in
				}, succ: {
				}, fail: {
					(code, msg) -> Void in
				})
			} else {}
		}
		// 6文件消息
		if let elem = message.fileElem {
			self.fileElem = [
				"UUID": message.fileElem.uuid,
				"path": base + (message.fileElem.uuid ?? ""),
				"url": base + (message.fileElem.uuid ?? ""),
				"fileName": message.fileElem.filename!,
				"fileSize": message.fileElem.fileSize
			]
			
			let path = base + "\(message.fileElem.uuid)";
			let fileManager = FileManager.default;
			
			if !fileManager.fileExists(atPath: path) {
				message.fileElem.downloadFile(path, progress: {
					(curSize, totalSize) -> Void in
				}, succ: {
				}, fail: {
					(code, msg) -> Void in
				})
			} else {}
		}
		
		// 7地理位置消息
		if let elem = message.locationElem {
			self.locationElem = [
				"desc": message.locationElem.desc,
				"longitude": message.locationElem.longitude,
				"latitude": message.locationElem.latitude
			];
		}
		
		// 8表情消息
		if let elem = message.faceElem {
			self.faceElem = [
				"index": message.faceElem.index,
				"data": String.init(data: message.faceElem.data!, encoding: String.Encoding.utf8)!
			];
		}
		
		// 9群tips消息
		if message.groupTipsElem != nil {
			var memberList: [[String: Any]] = []
			var groupChangeInfoList: [[String: Any]] = []
			var memberChangeInfoList: [[String: Any]] = []
			
			self.groupTipsElem = [
				"groupID": message.groupTipsElem.groupID!,
				"type": message.groupTipsElem.type.rawValue,
				"opMember": V2GroupMemberFullInfoEntity.getDict(simpleInfo: message.groupTipsElem.opMember!),
				"memberCount": message.groupTipsElem.memberCount
			];
			
			for info in message.groupTipsElem.memberList {
				let item = V2GroupMemberFullInfoEntity.getDict(simpleInfo: info)
				memberList.append(item)
			}
			
			for info in message.groupTipsElem.groupChangeInfoList {
				let item: [String: Any] = [
					"type": info.type.rawValue,
					"value": info.value,
					"key": info.key
				]
				groupChangeInfoList.append(item)
			}
			
			for info in message.groupTipsElem.memberChangeInfoList {
				let item: [String: Any] = [
					"userID": info.userID!,
					"muteTime": info.muteTime
				]
				memberChangeInfoList.append(item)
			}
			self.groupTipsElem!["memberList"] = memberList
			self.groupTipsElem!["groupChangeInfoList"] = groupChangeInfoList
			self.groupTipsElem!["memberChangeInfoList"] = memberChangeInfoList
		}
		// 10合并消息
		if let elem = message.mergerElem {
			self.mergerElem = [
				"layersOverLimit": elem.layersOverLimit,
				"title": elem.title ?? "",
				"abstractList": elem.abstractList ?? []
			];
		}
		
	}
}
