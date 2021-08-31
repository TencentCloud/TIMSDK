package com.tencent.qcloud.tim.uikit.modules.forward.message;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMFaceElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.component.face.FaceManager;
import com.tencent.qcloud.tim.uikit.component.photoview.PhotoViewActivity;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.component.video.VideoViewActivity;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;
import com.tencent.qcloud.tim.uikit.utils.ImageUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

public class ForwardMessageImageHolder extends ForwardMessageBaseHolder {

    private static final int DEFAULT_MAX_SIZE = 540;
    private static final int DEFAULT_RADIUS = 10;
    private final List<String> downloadEles = new ArrayList<>();
    private ImageView contentImage;
    private ImageView videoPlayBtn;
    private TextView videoDurationText;
    private boolean mClicking;
    private String mImagePath = null;

    public ForwardMessageImageHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_image;
    }

    @Override
    public void initVariableViews() {
        contentImage = rootView.findViewById(R.id.content_image_iv);
        videoPlayBtn = rootView.findViewById(R.id.video_play_btn);
        videoDurationText = rootView.findViewById(R.id.video_duration_tv);
    }

    @Override
    public void layoutVariableViews(MessageInfo msg, int position) {
        msgContentFrame.setBackground(null);
        switch (msg.getMsgType()) {
            case MessageInfo.MSG_TYPE_CUSTOM_FACE:
            case MessageInfo.MSG_TYPE_CUSTOM_FACE + 1:
                performCustomFace(msg, position);
                break;
            case MessageInfo.MSG_TYPE_IMAGE:
            case MessageInfo.MSG_TYPE_IMAGE + 1:
                performImage(msg, position);
                break;
            case MessageInfo.MSG_TYPE_VIDEO:
            case MessageInfo.MSG_TYPE_VIDEO + 1:
                performVideo(msg, position);
                break;
        }
    }

    private void performCustomFace(final MessageInfo msg, final int position) {
        videoPlayBtn.setVisibility(View.GONE);
        videoDurationText.setVisibility(View.GONE);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.CENTER_IN_PARENT);
        contentImage.setLayoutParams(params);
        V2TIMMessage message = msg.getTimMessage();
        if (message.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_FACE) {
            return;
        }
        V2TIMFaceElem faceEle = message.getFaceElem();
        String filter = new String(faceEle.getData());
        if (!filter.contains("@2x")) {
            filter += "@2x";
        }
        Bitmap bitmap = FaceManager.getCustomBitmap(faceEle.getIndex(), filter);
        if (bitmap == null) {
            // 自定义表情没有找到，用emoji再试一次
            bitmap = FaceManager.getEmoji(new String(faceEle.getData()));
            if (bitmap == null) {
                // TODO 临时找的一个图片用来表明自定义表情加载失败
                contentImage.setImageDrawable(rootView.getContext().getResources().getDrawable(R.drawable.face_delete));
            } else {
                contentImage.setImageBitmap(bitmap);
            }
        } else {
            contentImage.setImageBitmap(bitmap);
        }
    }

    private ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, final MessageInfo msg) {
        if (msg.getImgWidth() == 0 || msg.getImgHeight() == 0) {
            return params;
        }
        if (msg.getImgWidth() > msg.getImgHeight()) {
            params.width = DEFAULT_MAX_SIZE;
            params.height = DEFAULT_MAX_SIZE * msg.getImgHeight() / msg.getImgWidth();
        } else {
            params.width = DEFAULT_MAX_SIZE * msg.getImgWidth() / msg.getImgHeight();
            params.height = DEFAULT_MAX_SIZE;
        }
        return params;
    }

    private void resetParentLayout() {
        ((FrameLayout) contentImage.getParent().getParent()).setPadding(17, 0, 13, 0);
    }

    private void performImage(final MessageInfo msg, final int position) {
        contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), msg));
        resetParentLayout();
        videoPlayBtn.setVisibility(View.GONE);
        videoDurationText.setVisibility(View.GONE);
        V2TIMMessage timMessage = msg.getTimMessage();
        if (timMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
            return;
        }
        final V2TIMImageElem imageEle = timMessage.getImageElem();
        final List<V2TIMImageElem.V2TIMImage> imgs = imageEle.getImageList();
        String imagePath = msg.getDataPath();
        String originImagePath = ImageUtil.getOriginImagePath(msg);
        if (!TextUtils.isEmpty(originImagePath)) {
            imagePath = originImagePath;
        }
        if (!TextUtils.isEmpty(imagePath)) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, imagePath, null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(contentImage);
            for (int i = 0; i < imgs.size(); i++) {
                final V2TIMImageElem.V2TIMImage img = imgs.get(i);
                if (img.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB) {
                    synchronized (downloadEles) {
                        if (downloadEles.contains(img.getUUID())) {
                            break;
                        }
                        downloadEles.add(img.getUUID());
                    }
                    final String path = ImageUtil.generateImagePath(img.getUUID(), V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB);
                    // 如果contentImage的路径和当前图片路径不同，说明图片未加载过或者recyclerView复用了之前的缓存，为了避免显示错乱需要清空
                    if (!path.equals(mImagePath)) {
                        GlideEngine.clear(contentImage);
                    }
                    img.downloadImage(path, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                            TUIKitLog.i("downloadImage progress current:",
                                    progressInfo.getCurrentSize() + ", total:" + progressInfo.getTotalSize());
                        }

                        @Override
                        public void onError(int code, String desc) {
                            downloadEles.remove(img.getUUID());
                            TUIKitLog.e("MessageListAdapter img getImage", code + ":" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            downloadEles.remove(img.getUUID());
                            msg.setDataPath(path);
                            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getDataPath(), new RequestListener() {
                                @Override
                                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target target, boolean isFirstResource) {
                                    mImagePath = null;
                                    return false;
                                }

                                @Override
                                public boolean onResourceReady(Object resource, Object model, Target target, DataSource dataSource, boolean isFirstResource) {
                                    mImagePath = path;
                                    return false;
                                }
                            }, DEFAULT_RADIUS);
                        }
                    });
                    break;
                }
            }
        }
        contentImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String localImgPath = ImageUtil.getOriginImagePath(msg);
                boolean isOriginImg = localImgPath != null;
                // 点击后的预览图片路径 如果是原图直接放原图，否则用缩略图
                String previewImgPath = localImgPath;
                for (int i = 0; i < imgs.size(); i++) {
                    V2TIMImageElem.V2TIMImage img = imgs.get(i);
                    if (img.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN) {
                        PhotoViewActivity.mCurrentOriginalImage = img;
                    }
                    if (img.getType() == V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB) {
                        if (!isOriginImg) {
                            previewImgPath = ImageUtil.generateImagePath(img.getUUID(), V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB);
                        }
                    }
                }
                Intent intent = new Intent(TUIKit.getAppContext(), PhotoViewActivity.class);
                intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra(TUIKitConstants.IMAGE_PREVIEW_PATH, previewImgPath);
                intent.putExtra(TUIKitConstants.IS_ORIGIN_IMAGE, isOriginImg);
                TUIKit.getAppContext().startActivity(intent);
            }
        });
        contentImage.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onMessageLongClick(view, position, msg);
                }
                return true;
            }
        });
    }

    private void performVideo(final MessageInfo msg, final int position) {
        contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), msg));
        resetParentLayout();

        videoPlayBtn.setVisibility(View.VISIBLE);
        videoDurationText.setVisibility(View.VISIBLE);
        V2TIMMessage timMessage = msg.getTimMessage();
        if (timMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
            return;
        }
        final V2TIMVideoElem videoEle = timMessage.getVideoElem();

        if (!TextUtils.isEmpty(msg.getDataPath())) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getDataPath(), null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(contentImage);
            synchronized (downloadEles) {
                if (!downloadEles.contains(videoEle.getSnapshotUUID())) {
                    downloadEles.add(videoEle.getSnapshotUUID());
                }
            }

            final String path = TUIKitConstants.IMAGE_DOWNLOAD_DIR + videoEle.getSnapshotUUID();
            videoEle.downloadSnapshot(path, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    TUIKitLog.i("downloadSnapshot progress current:", progressInfo.getCurrentSize() + ", total:" + progressInfo.getTotalSize());
                }

                @Override
                public void onError(int code, String desc) {
                    downloadEles.remove(videoEle.getSnapshotUUID());
                    TUIKitLog.e("MessageListAdapter video getImage", code + ":" + desc);
                }

                @Override
                public void onSuccess() {
                    downloadEles.remove(videoEle.getSnapshotUUID());
                    msg.setDataPath(path);
                    GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getDataPath(), null, DEFAULT_RADIUS);
                }
            });
        }

        String durations = DateTimeUtil.formatSecondsTo00(videoEle.getDuration());
        videoDurationText.setText(durations);

        final String videoPath = TUIKitConstants.VIDEO_DOWNLOAD_DIR + videoEle.getVideoUUID();
        final File videoFile = new File(videoPath);
        //以下代码为zanhanding修改，用于fix视频消息发送失败后不显示红色感叹号的问题
        if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_SUCCESS) {
            //若发送成功，则不显示红色感叹号和发送中动画
            statusImage.setVisibility(View.GONE);
            sendingProgress.setVisibility(View.GONE);
        } else if (videoFile.exists() && msg.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
            //若存在正在发送中的视频文件（消息），则显示发送中动画（隐藏红色感叹号）
            statusImage.setVisibility(View.GONE);
            sendingProgress.setVisibility(View.VISIBLE);
        } else if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL) {
            //若发送失败，则显示红色感叹号（不显示发送中动画）
            statusImage.setVisibility(View.VISIBLE);
            sendingProgress.setVisibility(View.GONE);

        }
        //以上代码为zanhanding修改，用于fix视频消息发送失败后不显示红色感叹号的问题
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mClicking) {
                    return;
                }
                sendingProgress.setVisibility(View.VISIBLE);
                mClicking = true;
                //以下代码为zanhanding修改，用于fix点击发送失败视频后无法播放，并且红色感叹号消失的问题
                final File videoFile = new File(videoPath);
                if (videoFile.exists() && videoEle.getVideoSize() == videoFile.length()) {//若存在本地文件则优先获取本地文件
                    mAdapter.notifyItemChanged(position);
                    mClicking = false;
                    play(msg);
                    // 有可能播放的Activity还没有显示，这里延迟200ms，拦截压力测试的快速点击
                    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            mClicking = false;
                        }
                    }, 200);
                } else {
                    getVideo(videoEle, videoPath, msg, true, position);
                }
                //以上代码为zanhanding修改，用于fix点击发送失败视频后无法播放，并且红色感叹号消失的问题
            }
        });
    }

    private void getVideo(V2TIMVideoElem videoElem, String videoPath, final MessageInfo msg, final boolean autoPlay, final int position) {
        videoElem.downloadVideo(videoPath, new V2TIMDownloadCallback() {
            @Override
            public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                TUIKitLog.i("downloadVideo progress current:", progressInfo.getCurrentSize() + ", total:" + progressInfo.getTotalSize());
            }

            @Override
            public void onError(int code, String desc) {
                ToastUtil.toastLongMessage(TUIKit.getAppContext().getString(R.string.download_file_error) + code + "=" + desc);
                msg.setStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
                sendingProgress.setVisibility(View.GONE);
                statusImage.setVisibility(View.VISIBLE);
                mAdapter.notifyItemChanged(position);
                mClicking = false;
            }

            @Override
            public void onSuccess() {
                mAdapter.notifyItemChanged(position);
                if (autoPlay) {
                    play(msg);
                }
                // 有可能播放的Activity还没有显示，这里延迟200ms，拦截压力测试的快速点击
                new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        mClicking = false;
                    }
                }, 200);
            }
        });
    }

    private void play(final MessageInfo msg) {
        statusImage.setVisibility(View.GONE);
        sendingProgress.setVisibility(View.GONE);
        Intent intent = new Intent(TUIKit.getAppContext(), VideoViewActivity.class);
        intent.putExtra(TUIKitConstants.CAMERA_IMAGE_PATH, msg.getDataPath());
        intent.putExtra(TUIKitConstants.CAMERA_VIDEO_PATH, msg.getDataUri());
        intent.setFlags(FLAG_ACTIVITY_NEW_TASK);
        TUIKit.getAppContext().startActivity(intent);
    }

}
