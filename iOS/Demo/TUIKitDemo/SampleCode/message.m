- (void)onRecvNewMessage:(V2TIMMessage *)msg
{
    // 文本消息
    if (msg.elemType == V2TIM_ELEM_TYPE_TEXT) {
        V2TIMTextElem *textElem = msg.textElem;
        NSString *text = textElem.text;
        NSLog(@"文本信息 : %@", text);
    }
    // 自定义消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        V2TIMCustomElem *customElem = msg.customElem;
        NSData *customData = customElem.data;
        NSLog(@"自定义信息 : %@",customData);
    }
    // 图片消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_IMAGE) {
        V2TIMImageElem *imageElem = msg.imageElem;
        // 一个图片消息会包含三种格式大小的图片，分别为原图、大图、微缩图（SDK 会在发送图片消息的时候自动生成微缩图、大图，客户不需要关心）
        // 大图：是将原图等比压缩，压缩后宽、高中较小的一个等于720像素。
        // 缩略图：是将原图等比压缩，压缩后宽、高中较小的一个等于198像素。
        NSArray<V2TIMImage *> *imageList = imageElem.imageList;
        for (V2TIMImage *timImage in imageList) {
            // 图片 ID，内部标识，可用于外部缓存 key
            NSString *uuid = timImage.uuid;
            // 图片类型
            V2TIMImageType type = timImage.type;
            // 图片大小（字节）
            int size = timImage.size;
            // 图片宽度
            int width = timImage.width;
            // 图片高度
            int height = timImage.height;
            // 设置图片下载路径 imagePath，这里可以用 uuid 作为标识，避免重复下载
            NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testImage%@",timImage.uuid]];
                        // 判断 imagePath 下有没有已经下载过的图片文件
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                // 下载图片
                [timImage downloadImage:imagePath progress:^(NSInteger curSize, NSInteger totalSize) {
                    // 下载进度
                    NSLog(@"下载图片进度：curSize：%lu,totalSize:%lu",curSize,totalSize);
                } succ:^{
                    // 下载成功
                    NSLog(@"下载图片完成");
                } fail:^(int code, NSString *msg) {
                    // 下载失败
                    NSLog(@"下载图片失败：code：%d,msg:%@",code,msg);
                }];
            } else {
                // 图片已存在
            }
            NSLog(@"图片信息:uuid:%@,type:%ld,size:%d,width:%d,height:%d",uuid,(long)type,size,width,height);
        }
    }
    // 语音消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_SOUND) {
        V2TIMSoundElem *soundElem = msg.soundElem;
        // 语音 ID,内部标识，可用于外部缓存 key
        NSString *uuid = soundElem.uuid;
        // 语音文件大小
        int dataSize = soundElem.dataSize;
        // 语音时长
        int duration = soundElem.duration;
        // 设置语音文件路径 soundPath，这里可以用 uuid 作为标识，避免重复下载
        NSString *soundPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testSound%@",uuid]];
                // 判断 soundPath 下有没有已经下载过的语音文件
        if (![[NSFileManager defaultManager] fileExistsAtPath:soundPath]) {
            // 下载语音
            [soundElem downloadSound:soundPath progress:^(NSInteger curSize, NSInteger totalSize) {
                // 下载进度
                NSLog(@"下载语音进度：curSize：%lu,totalSize:%lu",curSize,totalSize);
            } succ:^{
                // 下载成功
                NSLog(@"下载语音完成");
            } fail:^(int code, NSString *msg) {
                // 下载失败
                NSLog(@"下载语音失败：code：%d,msg:%@",code,msg);
            }];
        } else {
            // 语音已存在
        }
        NSLog(@"语音信息：uuid:%@,dataSize：%d,duration:%d,soundPath:%@",uuid,dataSize,duration,soundPath);
    }
    // 视频消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        V2TIMVideoElem *videoElem = msg.videoElem;
        // 视频截图 ID,内部标识，可用于外部缓存 key
        NSString *snapshotUUID = videoElem.snapshotUUID;
        // 视频截图文件大小
        int snapshotSize = videoElem.snapshotSize;
        // 视频截图宽
        int snapshotWidth = videoElem.snapshotWidth;
        // 视频截图高
        int snapshotHeight = videoElem.snapshotHeight;
        // 视频 ID,内部标识，可用于外部缓存 key
        NSString *videoUUID = videoElem.videoUUID;
        // 视频文件大小
        int videoSize = videoElem.videoSize;
        // 视频时长
        int duration = videoElem.duration;
        // 设置视频截图文件路径，这里可以用 uuid 作为标识，避免重复下载
        NSString *snapshotPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testVideoSnapshot%@",snapshotUUID]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:snapshotPath]) {
            // 下载视频截图
            [videoElem downloadSnapshot:snapshotPath progress:^(NSInteger curSize, NSInteger totalSize) {
                // 下载进度
                NSLog(@"%@", [NSString stringWithFormat:@"下载视频截图进度：curSize：%lu,totalSize:%lu",curSize,totalSize]);
            } succ:^{
                // 下载成功
                NSLog(@"下载视频截图完成");
            } fail:^(int code, NSString *msg) {
                // 下载失败
                NSLog(@"%@", [NSString stringWithFormat:@"下载视频截图失败：code：%d,msg:%@",code,msg]);
            }];
        } else {
            // 视频截图已存在
        }
        NSLog(@"视频截图信息：snapshotUUID:%@,snapshotSize:%d,snapshotWidth:%d,snapshotWidth:%d,snapshotPath:%@",snapshotUUID,snapshotSize,snapshotWidth,snapshotHeight,snapshotPath);
        
        // 设置视频文件路径，这里可以用 uuid 作为标识，避免重复下载
        NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testVideo%@",videoUUID]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
            // 下载视频
            [videoElem downloadVideo:videoPath progress:^(NSInteger curSize, NSInteger totalSize) {
                // 下载进度
                NSLog(@"%@", [NSString stringWithFormat:@"下载视频进度：curSize：%lu,totalSize:%lu",curSize,totalSize]);
            } succ:^{
                // 下载成功
                NSLog(@"下载视频完成");
            } fail:^(int code, NSString *msg) {
                // 下载失败
                NSLog(@"%@", [NSString stringWithFormat:@"下载视频失败：code：%d,msg:%@",code,msg]);
            }];
        } else {
            // 视频已存在
        }
        NSLog(@"视频信息：videoUUID:%@,videoSize:%d,duration:%d,videoPath:%@",videoUUID,videoSize,duration,videoPath);
    }
    // 文件消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_FILE) {
        V2TIMFileElem *fileElem = msg.fileElem;
        // 文件 ID,内部标识，可用于外部缓存 key
        NSString *uuid = fileElem.uuid;
        // 文件名称
        NSString *filename = fileElem.filename;
        // 文件大小
        int fileSize = fileElem.fileSize;
        // 设置文件路径，这里可以用 uuid 作为标识，避免重复下载
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"testFile%@",uuid]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            // 下载文件
            [fileElem downloadFile:filePath progress:^(NSInteger curSize, NSInteger totalSize) {
                // 下载进度
                NSLog(@"%@", [NSString stringWithFormat:@"下载文件进度：curSize：%lu,totalSize:%lu",curSize,totalSize]);
            } succ:^{
                // 下载成功
                NSLog(@"下载文件完成");
            } fail:^(int code, NSString *msg) {
                // 下载失败
                NSLog(@"%@", [NSString stringWithFormat:@"下载文件失败：code：%d,msg:%@",code,msg]);
            }];
        } else {
            // 文件已存在
        }
        NSLog(@"文件信息：uuid:%@,filename:%@,fileSize:%d,filePath:%@",uuid,filename,fileSize,filePath);
    }
    // 地理位置消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_LOCATION) {
        V2TIMLocationElem *locationElem = msg.locationElem;
        // 地理位置信息描述
        NSString *desc = locationElem.desc;
        // 经度
        double longitude = locationElem.longitude;
        // 纬度
        double latitude = locationElem.latitude;
        NSLog(@"地理位置信息：desc：%@,longitude:%f,latitude:%f",desc,longitude,latitude);
    }
    // 表情消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_FACE) {
        V2TIMFaceElem *faceElem = msg.faceElem;
        // 表情所在的位置
        int index = faceElem.index;
        // 表情自定义数据
        NSData *data = faceElem.data;
        NSLog(@"表情信息：index：%d,data:%@",index,data);
    }
    // 群 tips 消息
    else if (msg.elemType == V2TIM_ELEM_TYPE_GROUP_TIPS) {
        V2TIMGroupTipsElem *tipsElem = msg.groupTipsElem;
        // 所属群组
        NSString *groupID = tipsElem.groupID;
        // 群Tips类型
        V2TIMGroupTipsType type = tipsElem.type;
        // 操作人资料
        V2TIMGroupMemberInfo * opMember = tipsElem.opMember;
        // 被操作人资料
        NSArray<V2TIMGroupMemberInfo *> * memberList = tipsElem.memberList;
        // 群信息变更详情
        NSArray<V2TIMGroupChangeInfo *> * groupChangeInfoList = tipsElem.groupChangeInfoList;
        // 群成员变更信息
        NSArray<V2TIMGroupMemberChangeInfo *> * memberChangeInfoList = tipsElem.memberChangeInfoList;
        // 当前群在线人数
        uint32_t memberCount = tipsElem.memberCount;
        NSLog(@"群 tips 信息：groupID：%@,type:%ld,opMember:%@,memberList:%@,groupChangeInfoList:%@,memberChangeInfoList:%@,memberCount:%u",groupID,(long)type,opMember,memberList,groupChangeInfoList,memberChangeInfoList,memberCount);
    }
}
