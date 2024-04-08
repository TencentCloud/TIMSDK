
@Override
public void onRecvNewMessage(V2TIMMessage msg) {
    int elemType = msg.getElemType();
    if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
        
        V2TIMTextElem v2TIMTextElem = msg.getTextElem();
        String text = v2TIMTextElem.getText();
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
        
        V2TIMCustomElem v2TIMCustomElem = msg.getCustomElem();
        byte[] customData = v2TIMCustomElem.getData();
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
        
        V2TIMImageElem v2TIMImageElem = msg.getImageElem();
        
        List<V2TIMImageElem.V2TIMImage> imageList = v2TIMImageElem.getImageList();
        for (V2TIMImageElem.V2TIMImage v2TIMImage : imageList) {
            
            String uuid = v2TIMImage.getUUID();
            
            int imageType = v2TIMImage.getType();
            
            int size = v2TIMImage.getSize();
            
            int width = v2TIMImage.getWidth();
            
            int height = v2TIMImage.getHeight();
            
            String imagePath = "/sdcard/im/image/" + "myUserID" + uuid;
            File imageFile = new File(imagePath);
            
            if (!imageFile.exists()) {
                
                v2TIMImage.downloadImage(imagePath, new V2TIMDownloadCallback() {
                    @Override
                    public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                        
                    }
                    @Override
                    public void onError(int code, String desc) {
                        
                    }
                    @Override
                    public void onSuccess() {
                        
                    }
                });
            } else {
                
            }
        }
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
        
        V2TIMSoundElem v2TIMSoundElem = msg.getSoundElem();
        
        String uuid = v2TIMSoundElem.getUUID();
        
        int dataSize = v2TIMSoundElem.getDataSize();
        
        int duration = v2TIMSoundElem.getDuration();
        
        String soundPath = "/sdcard/im/sound/" + "myUserID" + uuid;
        File imageFile = new File(soundPath);
        
        if (!imageFile.exists()) {
            v2TIMSoundElem.downloadSound(soundPath, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    
                }
                @Override
                public void onError(int code, String desc) {
                    
                }
                @Override
                public void onSuccess() {
                    
                }
            });
        } else {
            
        }
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
        
        V2TIMVideoElem v2TIMVideoElem = msg.getVideoElem();
        
        String snapshotUUID = v2TIMVideoElem.getSnapshotUUID();
        
        int snapshotSize = v2TIMVideoElem.getSnapshotSize();
        
        int snapshotWidth = v2TIMVideoElem.getSnapshotWidth();
        
        int snapshotHeight = v2TIMVideoElem.getSnapshotHeight();
        
        String videoUUID = v2TIMVideoElem.getVideoUUID();
        
        int videoSize = v2TIMVideoElem.getVideoSize();
        
        int duration = v2TIMVideoElem.getDuration();
        
        String snapshotPath = "/sdcard/im/snapshot/" + "myUserID" + snapshotUUID;
        File snapshotFile = new File(snapshotPath);
        if (!snapshotFile.exists()) {
            v2TIMVideoElem.downloadSnapshot(snapshotPath, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    
                }
                @Override
                public void onError(int code, String desc) {
                    
                }
                @Override
                public void onSuccess() {
                    
                }
            });
        } else {
            
        }

        
        String videoPath = "/sdcard/im/video/" + "myUserID" + snapshotUUID;
        File videoFile = new File(videoPath);
        if (!snapshotFile.exists()) {
            v2TIMVideoElem.downloadSnapshot(videoPath, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    
                }
                @Override
                public void onError(int code, String desc) {
                    
                }
                @Override
                public void onSuccess() {
                    
                }
            });
        } else {
            
        }
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
        
        V2TIMFileElem v2TIMFileElem = msg.getFileElem();
        
        String uuid = v2TIMFileElem.getUUID();
        
        String fileName = v2TIMFileElem.getFileName();
        
        int fileSize = v2TIMFileElem.getFileSize();
        
        String filePath = "/sdcard/im/file/" + "myUserID" + uuid;
        File file = new File(filePath);
        if (!file.exists()) {
            v2TIMFileElem.downloadFile(filePath, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    
                }
                @Override
                public void onError(int code, String desc) {
                    
                }
                @Override
                public void onSuccess() {
                    
                }
            });
        } else {
            
        }
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_LOCATION) {
        
        V2TIMLocationElem v2TIMLocationElem = msg.getLocationElem();
        
        String desc = v2TIMLocationElem.getDesc();
        
        double longitude = v2TIMLocationElem.getLongitude();
        
        double latitude = v2TIMLocationElem.getLatitude();
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
        
        V2TIMFaceElem v2TIMFaceElem = msg.getFaceElem();
        
        int index = v2TIMFaceElem.getIndex();
        
        byte[] data = v2TIMFaceElem.getData();
    } else if (elemType == V2TIMMessage.V2TIM_ELEM_TYPE_GROUP_TIPS) {
        
        V2TIMGroupTipsElem v2TIMGroupTipsElem = msg.getGroupTipsElem();
        
        String groupId = v2TIMGroupTipsElem.getGroupID();
        
        int type = v2TIMGroupTipsElem.getType();
        
        V2TIMGroupMemberInfo opMember = v2TIMGroupTipsElem.getOpMember();
        
        List<V2TIMGroupMemberInfo> memberList = v2TIMGroupTipsElem.getMemberList();
        
        List<V2TIMGroupChangeInfo> groupChangeInfoList = v2TIMGroupTipsElem.getGroupChangeInfoList();
        
        List<V2TIMGroupMemberChangeInfo> memberChangeInfoList v2TIMGroupTipsElem.getMemberChangeInfoList();
        
        int memberCount = v2TIMGroupTipsElem.getMemberCount();
    }
}

