package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.model.ChatFileDownloadProvider;
import java.io.File;

public class ChatFileDownloadPresenter {
    public static String getSoundPath(SoundMessageBean soundMessageBean) {
        String soundPath = ChatFileDownloadProvider.getSoundSelfPath(soundMessageBean);
        if (TextUtils.isEmpty(soundPath) || !FileUtil.isFileExists(soundPath)) {
            String uuid = ChatFileDownloadProvider.getSoundUUID(soundMessageBean);
            if (TextUtils.isEmpty(uuid)) {
                uuid = soundMessageBean.getId();
            }
            soundPath = TUIConfig.getRecordDownloadDir() + uuid;
        }
        return soundPath;
    }

    public static String getFilePath(FileMessageBean fileMessageBean) {
        String filePath = ChatFileDownloadProvider.getFileSelfPath(fileMessageBean);
        if (TextUtils.isEmpty(filePath) || !FileUtil.isFileExists(filePath)) {
            String uuid = ChatFileDownloadProvider.getFileUUID(fileMessageBean);
            if (TextUtils.isEmpty(uuid)) {
                uuid = fileMessageBean.getId() + "_" + ChatFileDownloadProvider.getFileName(fileMessageBean);
            }
            filePath = TUIConfig.getFileDownloadDir() + uuid;
        }
        return filePath;
    }

    public static String getVideoPath(VideoMessageBean videoMessageBean) {
        String videoPath = ChatFileDownloadProvider.getVideoSelfPath(videoMessageBean);
        if (TextUtils.isEmpty(videoPath) || !FileUtil.isFileExists(videoPath)) {
            String uuid = ChatFileDownloadProvider.getVideoUUID(videoMessageBean);
            if (TextUtils.isEmpty(uuid)) {
                uuid = videoMessageBean.getId() + "_Video";
            }
            videoPath = TUIConfig.getVideoDownloadDir() + uuid;
        }
        return videoPath;
    }

    public static String getVideoSnapshotPath(VideoMessageBean videoMessageBean) {
        String videoSnapshotPath = ChatFileDownloadProvider.getVideoSnapshotSelfPath(videoMessageBean);
        if (TextUtils.isEmpty(videoSnapshotPath) || !FileUtil.isFileExists(videoSnapshotPath)) {
            String uuid = ChatFileDownloadProvider.getVideoSnapshotUUID(videoMessageBean);
            if (TextUtils.isEmpty(uuid)) {
                uuid = videoMessageBean.getId() + "_Snapshot";
            }
            videoSnapshotPath = TUIConfig.getVideoDownloadDir() + uuid;
        }
        return videoSnapshotPath;
    }

    public static String getImagePath(ImageMessageBean imageMessageBean, int type) {
        String imagePath = ChatFileDownloadProvider.getImageSelfPath(imageMessageBean);
        if (TextUtils.isEmpty(imagePath) || !FileUtil.isFileExists(imagePath)) {
            ImageMessageBean.ImageBean imageBean = imageMessageBean.getImageBean(type);
            String uuid = ChatFileDownloadProvider.getImageUUID(imageBean);
            if (TextUtils.isEmpty(uuid)) {
                imagePath = ImageUtil.generateImagePath(imageMessageBean.getId(), type);
            } else {
                imagePath = ImageUtil.generateImagePath(uuid, type);
            }
        }
        return imagePath;
    }

    public static String getImagePath(ImageMessageBean imageMessageBean) {
        return getImagePath(imageMessageBean, ImageMessageBean.IMAGE_TYPE_THUMB);
    }

    public static File getSoundMessageFile(SoundMessageBean soundMessageBean) {
        String filePath = getSoundPath(soundMessageBean);
        if (FileUtil.isFileExists(filePath)) {
            return new File(filePath);
        }
        return null;
    }

    public static File getVideoMessageVideoFile(VideoMessageBean videoMessageBean) {
        String filePath = getVideoPath(videoMessageBean);
        if (FileUtil.isFileExists(filePath)) {
            return new File(filePath);
        }
        return null;
    }

    public static File getVideoMessageSnapshotFile(VideoMessageBean videoMessageBean) {
        String filePath = getVideoSnapshotPath(videoMessageBean);
        if (FileUtil.isFileExists(filePath)) {
            return new File(filePath);
        }
        return null;
    }

    public static File getFileMessageFile(FileMessageBean fileMessageBean) {
        String filePath = getFilePath(fileMessageBean);
        if (FileUtil.isFileExists(filePath)) {
            return new File(filePath);
        }
        return null;
    }

    public static File getImageMessageFile(ImageMessageBean imageMessageBean, int type) {
        String filePath = getImagePath(imageMessageBean, type);
        if (FileUtil.isFileExists(filePath)) {
            return new File(filePath);
        }
        return null;
    }

    public static File getImageMessageFile(ImageMessageBean imageMessageBean) {
        return getImageMessageFile(imageMessageBean, ImageMessageBean.IMAGE_TYPE_THUMB);
    }

    public static void downloadSound(SoundMessageBean soundMessageBean, TUIValueCallback callback) {
        if (soundMessageBean != null) {
            final String path = getSoundPath(soundMessageBean);
            ChatFileDownloadProvider provider = new ChatFileDownloadProvider(soundMessageBean);
            ChatFileDownloadProxy.proxy(provider).downloadSound(path, callback);
        }
    }

    public static void downloadFile(FileMessageBean fileMessageBean, TUIValueCallback callback) {
        if (fileMessageBean != null) {
            final String path = getFilePath(fileMessageBean);
            ChatFileDownloadProvider provider = new ChatFileDownloadProvider(fileMessageBean);
            ChatFileDownloadProxy.proxy(provider).downloadFile(path, callback);
        }
    }

    public static void downloadImage(ImageMessageBean imageMessageBean, int type, TUIValueCallback callback) {
        if (imageMessageBean != null) {
            final String path = getImagePath(imageMessageBean, type);
            ImageMessageBean.ImageBean imageBean = imageMessageBean.getImageBean(type);
            ChatFileDownloadProvider provider = new ChatFileDownloadProvider(imageBean);
            ChatFileDownloadProxy.proxy(provider).downloadImage(path, callback);
        }
    }

    public static void downloadImage(ImageMessageBean imageMessageBean, TUIValueCallback callback) {
        downloadImage(imageMessageBean, ImageMessageBean.IMAGE_TYPE_THUMB, callback);
    }

    public static void downloadVideo(VideoMessageBean videoMessageBean, TUIValueCallback callback) {
        if (videoMessageBean != null) {
            final String path = getVideoPath(videoMessageBean);
            ChatFileDownloadProvider provider = new ChatFileDownloadProvider(videoMessageBean);
            ChatFileDownloadProxy.proxy(provider).downloadVideo(path, callback);
        }
    }

    public static void downloadVideoSnapshot(VideoMessageBean videoMessageBean, TUIValueCallback callback) {
        if (videoMessageBean != null) {
            final String path = getVideoSnapshotPath(videoMessageBean);
            ChatFileDownloadProvider provider = new ChatFileDownloadProvider(videoMessageBean);
            ChatFileDownloadProxy.proxy(provider).downloadVideoSnapshot(path, callback);
        }
    }

    public static boolean isDownloading(String path) {
        return ChatFileDownloadProxy.isDownloading(path);
    }
}
