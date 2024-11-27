package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.os.HandlerThread;
import androidx.activity.result.ActivityResultCaller;
import com.tencent.liteav.base.util.CustomHandler;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil.MultimediaPluginFileType;
import com.tencent.ugc.TXVideoEditConstants.TXGenerateResult;
import com.tencent.ugc.TXVideoEditConstants.TXVideoInfo;
import com.tencent.ugc.TXVideoEditer.TXVideoGenerateListener;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;

public class TUIMultimediaMediaProcessor {

    private final String TAG = TUIMultimediaMediaProcessor.class.getSimpleName() + "_" + hashCode();

    public interface TUIMultimediaMediaEditListener {

        void onEditCompleted(Uri uri);
    }

    public interface TUIMultimediaMediaTranscodeListener {

        void onTranscodeFinished(TranscodeResult transcodeResult);

        void onTranscodeProgress(Uri originUri, int transcodeProgress);
    }

    public static class TranscodeResult {

        public int errorCode;
        public String errorString;
        public Uri originalUri;
        public Uri transcodeMediaUri;
    }

    private static TUIMultimediaMediaProcessor sInstance;

    public static TUIMultimediaMediaProcessor getInstance() {
        if (sInstance == null) {
            synchronized (TUIMultimediaMediaProcessor.class) {
                if (sInstance == null) {
                    sInstance = new TUIMultimediaMediaProcessor();
                }
            }
        }
        return sInstance;
    }

    public void editMedia(Context context, Uri uri, TUIMultimediaMediaEditListener listener) {
        LiteavLog.i(TAG, "edit media uri = " + uri.toString());
        Bundle bundle = new Bundle();
        bundle.putString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH, uri.toString());
        TUICore.startActivityForResult((ActivityResultCaller) context, TUIMultimediaEditActivity.class,
                bundle, result -> {
                    Uri editedMediaUri = null;
                    if (result.getData() != null) {
                        Bundle resultBundle = result.getData().getExtras();
                        if (resultBundle != null) {
                            String editedFilePath = resultBundle
                                    .getString(TUIMultimediaConstants.PARAM_NAME_EDITED_FILE_PATH);
                            editedMediaUri = editedFilePath != null ? FileUtil.getUriFromPath(editedFilePath) : null;
                        }
                    }
                    if (listener != null) {
                        LiteavLog.i(TAG, "onEditCompleted  editedMediaUri = " + editedMediaUri);
                        listener.onEditCompleted(editedMediaUri);
                    }
                });
    }

    public void transcodeMedia(List<Uri> uris, TUIMultimediaMediaTranscodeListener listener) {
        LiteavLog.i(TAG, "transcodeMedia uris size is " + uris.size());
        MultiMediaFileTranscoder multiVideoTranscoder = new MultiMediaFileTranscoder(uris, listener);
        multiVideoTranscoder.startTranscode();
    }

    private TUIMultimediaMediaProcessor() {
    }

    private static class MultiMediaFileTranscoder {

        private static final int CONCURRENT_TRANSCODE_NUMBER = 2;
        private final String TAG = MultiMediaFileTranscoder.class.getSimpleName() + "_" + hashCode();
        private final Queue<Uri> mUriQueue;
        private final TUIMultimediaMediaTranscodeListener mListener;
        private final CustomHandler mCustomHandler;
        private final Map<Uri, TXVideoInfo> mVideoInfoMap = new HashMap<>();

        private boolean transcoding = false;

        public MultiMediaFileTranscoder(List<Uri> uris, TUIMultimediaMediaTranscodeListener listener) {
            mUriQueue = new LinkedList<>(uris);
            mListener = listener;
            HandlerThread handlerThread = new HandlerThread("multi_video_transcode");
            handlerThread.start();
            mCustomHandler = new CustomHandler(handlerThread.getLooper());
        }

        public void startTranscode() {
            mCustomHandler.runOrPost(() -> {
                if (transcoding) {
                    return;
                }

                transcoding = true;
                getVideoInfo();
                for (int i = 0; i < CONCURRENT_TRANSCODE_NUMBER; i++) {
                    transcodeMediaInQueue();
                }
            });
        }

        private void transcodeMediaInQueue() {
            if (mUriQueue.isEmpty()) {
                return;
            }

            Uri uri;
            do {
                uri = mUriQueue.poll();
                if (uri != null) {
                    transcodeMedia(uri);
                }
            } while (!mUriQueue.isEmpty() && uri == null);
        }

        private void getVideoInfo() {
            for (Uri uri : mUriQueue) {
                TXVideoInfo videoInfo = TUIMultimediaEditorCore
                        .getVideoFileInfo(TUIMultimediaPlugin.getAppContext(), uri.toString());
                mVideoInfoMap.put(uri, videoInfo);
            }
        }

        private void transcodeMedia(Uri uri) {
            LiteavLog.i(TAG, "transcode media uri is " + uri.toString());
            if (!isNeedTranscode(mVideoInfoMap.get(uri))) {
                LiteavLog.i(TAG, "do not need transcode. uri = " + uri);
                mCustomHandler.runOrPost(this::transcodeMediaInQueue);
                ThreadUtils.postOnUiThread(() -> {
                    mListener.onTranscodeProgress(uri, 100);
                    notifyTranscodeFinish(0, "", uri, uri);
                });
                return;
            }

            TUIMultimediaEditorCore tuiMultimediaEditorCore = new TUIMultimediaEditorCore(TUIMultimediaPlugin.getAppContext() );
            tuiMultimediaEditorCore.setSource(uri.toString());
            String outVideoPath = TUIMultimediaFileUtil
                    .generateFilePath(MultimediaPluginFileType.EDIT_FILE);
            tuiMultimediaEditorCore.generateVideo(outVideoPath, TUIMultimediaIConfig.getInstance().getVideoQuality(),
                    new TXVideoGenerateListener() {
                        @Override
                        public void onGenerateProgress(float progress) {
                            mListener.onTranscodeProgress(uri, (int) (progress * 100));
                        }

                        @Override
                        public void onGenerateComplete(TXGenerateResult txGenerateResult) {
                            mCustomHandler.runOrPost(() -> transcodeMediaInQueue());
                            notifyTranscodeFinish(txGenerateResult.retCode, txGenerateResult.descMsg, uri,
                                    FileUtil.getUriFromPath(outVideoPath));
                            tuiMultimediaEditorCore.release();
                        }
                    });
        }

        private void notifyTranscodeFinish(int errorCode, String errorString, Uri originalUri, Uri transcodeMediaUri) {
            TranscodeResult transcodeResult = new TranscodeResult();
            transcodeResult.errorCode = errorCode;
            transcodeResult.errorString = errorString;
            transcodeResult.transcodeMediaUri = transcodeMediaUri;
            transcodeResult.originalUri = originalUri;
            if (mListener != null) {
                mListener.onTranscodeFinished(transcodeResult);
            }
            LiteavLog.i(TAG, "onTranscodeFinished  source media uri is " + originalUri
                    + " new media uri is " + transcodeMediaUri);
        }

        private boolean isNeedTranscode(TXVideoInfo videoInfo) {
            if (videoInfo == null) {
                LiteavLog.i(TAG, "isNeedTranscode false. because video info is null");
                return false;
            }

            if (!TUIMultimediaEditorCore.isValidVideo(videoInfo)) {
                LiteavLog.i(TAG, "isNeedTranscode false. because is not valid video");
                return false;
            }

            boolean isNeedTranscode = videoInfo.bitrate == 0 ||
                    videoInfo.bitrate > TUIMultimediaEditorCore
                            .getBitrateAccordQuality(TUIMultimediaIConfig.getInstance().getVideoQuality()) * 1.2;
            if (!isNeedTranscode) {
                LiteavLog.i(TAG,
                        "isNeedTranscode false. because is source bitrate is low. bitrate is " + videoInfo.bitrate);
            }
            return isNeedTranscode;
        }
    }
}
