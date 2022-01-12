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
    var id:String?; // 只有在onProgress时才能拿掉此id
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

	// ios差异化问题，message不会返回这两个字段就不进行设置
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
            
            if self.v2message.groupAtUserList == nil {
                dict["groupAtUserList"] = []
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
        result["id"] = self.id;
		result["timestamp"] = (self.timestamp == nil) ? Int(Date().timeIntervalSince1970) : Int(self.timestamp!.timeIntervalSince1970)
		
		return result
	}
    
    func convertTextMessage(textElem:V2TIMTextElem) -> [String: Any] {
        return [
            "text": textElem.text ?? ""
        ];
    }
    
    func convertCustomMessageElem(customElem:V2TIMCustomElem) -> [String:Any] {
        return [
            "data": String.init(data: customElem.data!, encoding: String.Encoding.utf8)!,
            "desc": customElem.desc,
            "extension": customElem.extension
        ]
    }
    
    func convertImageMessageElem(imageElem:V2TIMImageElem) -> [String:Any] {
        var result:[String:Any] = [:];
        var list:[[String: Any]] = [];
        result["path"] = imageElem.path ?? "";
        
        if imageElem.imageList.isEmpty {
            result["imageList"] = [["img": ""]]
        }
        
        for image in imageElem.imageList! {
            var item: [String: Any] = [:];
            let fileManager = FileManager.default;
            let path = NSTemporaryDirectory() + "\(image.uuid!)";
            item["uuid"] = image.uuid;
            item["type"] = CommonUtils.changeToAndroid(type: image.type.rawValue);
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
            result["imageList"] = list;
            result["url"] = item["url"]
        }
        return result;
    }
    
    func convertSoundMessageElem(soundElem:V2TIMSoundElem) -> [String:Any] {
        let url = "";
        let tempPath = NSTemporaryDirectory() + "\(soundElem.uuid ?? "")";
        let fileManager = FileManager.default;
        let path = soundElem.path ?? tempPath;
        if !fileManager.fileExists(atPath: path) {
            soundElem.downloadSound(path, progress: {
                (curSize, totalSize) -> Void in
            }, succ: {
            }, fail: {
                (code, msg) -> Void in
            })
        } else {}

        return [
            "uuid": soundElem.uuid,
            "dataSize": soundElem.dataSize,
            "duration": soundElem.duration,
            "url": url,
            "path": path
        ]

    }
    
    func convertVideoMessageElem(videoElem:V2TIMVideoElem) -> [String:Any] {
        let pathSnapshot = videoElem.snapshotPath ?? NSTemporaryDirectory() + "\(videoElem.snapshotUUID)";
        let pathVideo = videoElem.videoPath ?? NSTemporaryDirectory() + "\(videoElem.videoUUID)";
        let fileManager = FileManager.default;
        let videoUrl: String? = nil;
        let snapshotUrl: String? = nil;
        
        if !fileManager.fileExists(atPath: pathSnapshot) {
            videoElem.downloadSnapshot(pathSnapshot, progress: {
                (curSize, totalSize) -> Void in
            }, succ: {
            }, fail: {
                (code, msg) -> Void in
            })
        } else {}

        if !fileManager.fileExists(atPath: pathVideo) {
            videoElem.downloadVideo(pathVideo, progress: {
                (curSize, totalSize) -> Void in
            }, succ: {
            }, fail: {
                (code, msg) -> Void in
            })
        } else {}
        
       return [
            "snapshotUUID": videoElem.snapshotUUID,
            "snapshotPath": videoElem.snapshotPath,
            "snapshotUrl": snapshotUrl,
            "snapshotSize": videoElem.snapshotSize,
            "snapshotWidth": videoElem.snapshotWidth,
            "snapshotHeight": videoElem.snapshotHeight,
            "UUID": videoElem.videoUUID,
            "videoPath": videoElem.videoPath,
            "videoUrl": videoUrl,
            "videoSize": videoElem.videoSize,
            "duration": videoElem.duration
        ];
    }
    
    func convertFileElem(fileElem:V2TIMFileElem) -> [String:Any] {
        let path = fileElem.path ?? NSTemporaryDirectory() + "\(fileElem.uuid ?? "")";
        let fileManager = FileManager.default;
        
        if !fileManager.fileExists(atPath: path) {
            fileElem.downloadFile(path, progress: {
                (curSize, totalSize) -> Void in
            }, succ: {
            }, fail: {
                (code, msg) -> Void in
            })
        } else {}
        return  [
            "UUID": fileElem.uuid ?? "",
            "path": fileElem.path ?? NSTemporaryDirectory() + (fileElem.uuid ?? ""),
            "url": fileElem.path ?? NSTemporaryDirectory() + (fileElem.uuid ?? ""),
            "fileName": fileElem.filename!,
            "fileSize":fileElem.fileSize
        ];
    }
    
    func convertLocationElem(locationElem:V2TIMLocationElem) -> [String:Any] {
        return [
            "desc": locationElem.desc ?? "",
            "longitude": locationElem.longitude,
            "latitude": locationElem.latitude
        ];
    }
    
    func convertFaceElem(faceElem:V2TIMFaceElem) -> [String:Any] {
        return [
            "index": faceElem.index,
            "data": String.init(data: faceElem.data!, encoding: String.Encoding.utf8)!
        ];
    }
    
    func convertMergerElem(mergerElem:V2TIMMergerElem) -> [String:Any] {
        return [
            "layersOverLimit": mergerElem.layersOverLimit,
            "title": mergerElem.title ?? "",
            "abstractList": mergerElem.abstractList ?? []
        ];
    }
    
    func convertGroupTipsElem(groupTipsElem:V2TIMGroupTipsElem) -> [String:Any] {
        var result:[String:Any] = [:];
        var memberList: [[String: Any]] = []
        var groupChangeInfoList: [[String: Any]] = []
        var memberChangeInfoList: [[String: Any]] = []
        
        result = [
            "groupID": groupTipsElem.groupID!,
            "type": groupTipsElem.type.rawValue,
            "opMember": TIMGroupMemberInfo.getDict(simpleInfo: groupTipsElem.opMember!),
            "memberCount": groupTipsElem.memberCount
        ];
        
        for info in groupTipsElem.memberList {
            let item = TIMGroupMemberInfo.getDict(simpleInfo: info)
            memberList.append(item)
        }
        
        for info in groupTipsElem.groupChangeInfoList {
            let item: [String: Any] = [
                "type": info.type.rawValue,
                "value": info.value,
                "key": info.key
            ]
            groupChangeInfoList.append(item)
        }
        
        for info in groupTipsElem.memberChangeInfoList {
            let item: [String: Any] = [
                "userID": info.userID!,
                "muteTime": info.muteTime
            ]
            memberChangeInfoList.append(item)
        }
        
       
        result["memberList"] = memberList
        result["groupChangeInfoList"] = groupChangeInfoList
        result["memberChangeInfoList"] = memberChangeInfoList
        return result;
    }
    
    func convertMessageElem(nextElem:V2TIMElem) -> [String: Any] {
        var result: [String: Any] = [:];
        if nextElem != nil {
            if nextElem is V2TIMTextElem {
                let textElem:V2TIMTextElem = nextElem as! V2TIMTextElem;
                result = self.convertTextMessage(textElem: textElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_TEXT.rawValue;
            } else if nextElem is V2TIMCustomElem {
                let customElem:V2TIMCustomElem = nextElem as! V2TIMCustomElem;
                result = self.convertCustomMessageElem(customElem: customElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_CUSTOM.rawValue;
            } else if nextElem is V2TIMImageElem {
                let imageElem:V2TIMImageElem = nextElem as! V2TIMImageElem;
                result = self.convertImageMessageElem(imageElem: imageElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_IMAGE.rawValue;
            } else if nextElem is V2TIMSoundElem {
                let soundElem:V2TIMSoundElem = nextElem as! V2TIMSoundElem;
                result = self.convertSoundMessageElem(soundElem: soundElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_SOUND.rawValue;
            } else if nextElem is V2TIMVideoElem {
                let videoElem:V2TIMVideoElem = nextElem as! V2TIMVideoElem;
                result = self.convertVideoMessageElem(videoElem: videoElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_VIDEO.rawValue;
            } else if nextElem is V2TIMFileElem {
                let fileElem:V2TIMFileElem = nextElem as! V2TIMFileElem;
                result = self.convertFileElem(fileElem: fileElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_FILE.rawValue;
            } else if nextElem is V2TIMLocationElem {
                let locationElem = nextElem as! V2TIMLocationElem;
                result = self.convertLocationElem(locationElem: locationElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_LOCATION.rawValue;
            } else if nextElem is V2TIMFaceElem {
                let faceElem:V2TIMFaceElem = nextElem as! V2TIMFaceElem;
                result = self.convertFaceElem(faceElem: faceElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_FACE.rawValue;
            } else if nextElem is V2TIMMergerElem {
                let meregerElem:V2TIMMergerElem = nextElem as! V2TIMMergerElem;
                result = self.convertMergerElem(mergerElem: meregerElem);
                result["elemType"] = V2TIMElemType.ELEM_TYPE_MERGER.rawValue;
            }
            if nextElem.next() != nil {
                result["nextElem"] = self.convertMessageElem(nextElem: nextElem.next());
            }
        }
        return result;
    }
	// V2TIMMessage没有 progress和priority 字段
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
            if let localCustomData = message.localCustomData  as? Data {
                let dataStr = String(data: localCustomData, encoding: .utf8) ?? "";
                self.localCustomData = dataStr;
            }
		}
		if message.cloudCustomData != nil {
            if let cloudCustomData = message.cloudCustomData  as? Data {
                let dataStr = String(data: cloudCustomData, encoding: .utf8) ?? "";
                self.cloudCustomData = dataStr;
            }
		}
		// 文本消息
		if message.textElem != nil {
            var textElem = self.convertTextMessage(textElem: message.textElem);
            if message.textElem.next() != nil {
                textElem["nextElem"] = self.convertMessageElem(nextElem: message.textElem.next());
            }
            self.textElem = textElem;
		}
		// 自定义消息
		if let elem = message.customElem {
            var customElem = self.convertCustomMessageElem(customElem: elem);
            if message.customElem.next() != nil {
                customElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            };
            self.customElem = customElem;
		}

		// 3图片消息
		/*
        native 图片下type字段不统一
		ios返回1、2、4 安卓返回0、1、2 对应 原图、缩略图、大图
		全部统一化为安卓的类型
		*/
		if let elem = message.imageElem {
            var imageElem = self.convertImageMessageElem(imageElem: elem);
            if elem.next() != nil {
                imageElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
			self.imageElem = [:];
            self.imageElem = imageElem;
		}
		// 4语音消息
		if message.soundElem != nil {
            var soundElem = self.convertSoundMessageElem(soundElem: message.soundElem);
            if message.soundElem.next() != nil {
                soundElem["nextElem"] = self.convertMessageElem(nextElem: message.soundElem.next());
            }
            self.soundElem = soundElem;
		}
		
		// 5视频消息
		if let elem = message.videoElem {
            var videoElem = self.convertVideoMessageElem(videoElem: elem);
            if elem.next() != nil {
                videoElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            };
            self.videoElem = videoElem;
		}
		// 6文件消息
		if let elem = message.fileElem {
            var fileElem = self.convertFileElem(fileElem: elem);
            if elem.next() != nil {
                fileElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
            self.fileElem = fileElem;
		}
		
		// 7地理位置消息
		if let elem = message.locationElem {
            var locationElem = self.convertLocationElem(locationElem: elem);
            if elem.next() != nil {
                locationElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
			self.locationElem = locationElem
		}
		
		// 8表情消息
		if let elem = message.faceElem {
            var faceElem = self.convertFaceElem(faceElem: elem);
            if elem.next() != nil {
                faceElem["nextElem"] = self.convertMessageElem(nextElem: elem.next());
            }
			self.faceElem = faceElem
		}
		
		// 9群tips消息
		if message.groupTipsElem != nil {
            self.groupTipsElem = self.convertGroupTipsElem(groupTipsElem: message.groupTipsElem);
		}
		// 10合并消息
		if let elem = message.mergerElem {
            var mergerElem = self.convertMergerElem(mergerElem: elem);
            if elem.next() != nil {
                mergerElem["nextElem"] = self.convertMessageElem(nextElem: elem.next())
            }
            self.mergerElem = mergerElem;
		}
		
	}
}
