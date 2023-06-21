package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.net.Uri;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.RecyclerView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMVideoElem;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.photoview.listener.OnMatrixChangedListener;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.photoview.listener.OnPhotoTapListener;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.photoview.listener.OnSingleFlingListener;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.photoview.view.PhotoView;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.video.VideoView;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.video.proxy.IPlayer;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ChatRingProgressBar;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ImageVideoScanAdapter extends RecyclerView.Adapter<ImageVideoScanAdapter.ViewHolder> {
    private static final String TAG = ImageVideoScanAdapter.class.getSimpleName();

    private static final String DOWNLOAD_ORIGIN_IMAGE_PATH = "downloadOriginImagePath";
    private static final String BROADCAST_DOWNLOAD_COMPLETED_ACTION = "PhotoViewActivityDownloadOriginImageCompleted";

    private List<TUIMessageBean> mDataSource = new ArrayList<>();
    private BroadcastReceiver downloadReceiver;
    private Context mContext = null;

    private TUIMessageBean mOldLocateMessage;
    private TUIMessageBean mNewLocateMessage;

    private Handler durationHandler;
    private boolean mIsVideoPlay = false;
    private String mCacheImagePath = null;

    private Set<String> loadingIdList = new HashSet<>();

    public ImageVideoScanAdapter() {
        mContext = TUIChatService.getAppContext();
    }

    private ImageVideoScanActivity.OnItemClickListener onItemClickListener;

    private Runnable updateSeekBarTime;

    public void resetVideo(ViewHolder holder) {
        holder.videoView.stop();
        holder.videoView.resetVideo();
        holder.playButton.setImageResource(R.drawable.ic_play_icon);
        holder.pauseCenterView.setVisibility(View.VISIBLE);
        holder.snapImageView.setVisibility(View.GONE);
        holder.progressBar.setVisibility(View.GONE);
        holder.playSeekBar.setProgress(0);
        mIsVideoPlay = false;
        String durations = DateTimeUtil.formatSecondsTo00(0);
        holder.timeBeginView.setText(durations);
    }

    public void setOnItemClickListener(ImageVideoScanActivity.OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.image_video_scan_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        TUIMessageBean messageBean = getItem(position);
        if (messageBean == null) {
            return;
        }

        holder.playSeekBar.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                v.getParent().requestDisallowInterceptTouchEvent(true);
                return false;
            }
        });

        holder.progressContainer.setVisibility(View.GONE);
        holder.progressContainer.setOnClickListener(null);
        holder.progressListener = progress -> {
            holder.progressContainer.setVisibility(View.VISIBLE);
            holder.progressIcon.setVisibility(View.GONE);
            holder.progressText.setVisibility(View.VISIBLE);
            holder.progressBar.setVisibility(View.VISIBLE);
            holder.progressBar.setProgress(progress);
            holder.progressText.setText(progress + "%");
            if (progress == 100) {
                holder.progressContainer.setVisibility(View.GONE);
            }
        };
        ProgressPresenter.registerProgressListener(messageBean.getId(), holder.progressListener);

        if (messageBean instanceof ImageMessageBean) {
            performPhotoView(holder, messageBean, position);
        } else if (messageBean instanceof VideoMessageBean) {
            performVideoView(holder, messageBean, position);
        } else {
            TUIChatLog.d(TAG, "error message type");
        }
    }

    @Override
    public int getItemCount() {
        return mDataSource.size();
    }

    public TUIMessageBean getItem(int position) {
        if (mDataSource == null || mDataSource.isEmpty()) {
            return null;
        }

        return mDataSource.get(position);
    }

    public void onDataChanged(TUIMessageBean messageBean) {
        for (TUIMessageBean dataBean : mDataSource) {
            if (TextUtils.equals(messageBean.getId(), dataBean.getId())) {
                dataBean.update(messageBean);
                break;
            }
        }
        notifyDataSetChanged();
    }

    private void loadPhotoView(ViewHolder holder, ImageMessageBean imageMessageBean, int positon) {
        final List<ImageMessageBean.ImageBean> imgs = imageMessageBean.getImageBeanList();
        String imagePath = null;
        String originImagePath = TUIChatUtils.getOriginImagePath(imageMessageBean);
        if (!TextUtils.isEmpty(originImagePath)) {
            imagePath = originImagePath;
        } else {
            String largePath = TUIChatUtils.generateLargeImagePath(imageMessageBean);
            File file = new File(largePath);
            if (file.exists()) {
                imagePath = largePath;
            }
        }
        if (TextUtils.isEmpty(imagePath)) {
            for (int i = 0; i < imgs.size(); i++) {
                final ImageMessageBean.ImageBean img = imgs.get(i);
                if (img.getType() == ImageMessageBean.IMAGE_TYPE_LARGE) {
                    final String path = ImageUtil.generateImagePath(img.getUUID(), ImageMessageBean.IMAGE_TYPE_LARGE);
                    if (loadingIdList.contains(path)) {
                        return;
                    }
                    loadingIdList.add(path);
                    img.downloadImage(path, new ImageMessageBean.ImageBean.ImageDownloadCallback() {
                        @Override
                        public void onProgress(long currentSize, long totalSize) {
                            int progress = Math.round(currentSize * 1.0f * 100 / totalSize);
                            ProgressPresenter.updateProgress(imageMessageBean.getId(), progress);

                            TUIChatLog.i("downloadImage progress current:", currentSize + ", total:" + totalSize);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            loadingIdList.remove(path);
                            TUIChatLog.e("MessageAdapter img getImage", code + ":" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            loadingIdList.remove(path);
                            ProgressPresenter.updateProgress(imageMessageBean.getId(), 100);
                            ThreadUtils.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    notifyDataSetChanged();
                                }
                            });
                        }
                    });
                    break;
                }
            }
            return;
        }

        V2TIMImageElem.V2TIMImage currentOriginalImage = null;
        String largePath = null;
        for (int i = 0; i < imgs.size(); i++) {
            ImageMessageBean.ImageBean img = imgs.get(i);
            if (img.getType() == ImageMessageBean.IMAGE_TYPE_ORIGIN) {
                currentOriginalImage = img.getV2TIMImage();
            }
            if (img.getType() == ImageMessageBean.IMAGE_TYPE_LARGE) {
                largePath = ImageUtil.generateImagePath(img.getUUID(), ImageMessageBean.IMAGE_TYPE_LARGE);
            }
        }
        String localImgPath = TUIChatUtils.getOriginImagePath(imageMessageBean);
        boolean isOriginImg = localImgPath != null && currentOriginalImage != null && !TextUtils.isEmpty(localImgPath)
            && currentOriginalImage.getSize() == FileUtil.getFileSize(localImgPath);
        String previewImgPath;
        if (!isOriginImg) {
            previewImgPath = largePath;
        } else {
            previewImgPath = localImgPath;
        }
        Uri uri = FileUtil.getUriFromPath(previewImgPath);
        if (uri != null) {
            holder.progressBar.setVisibility(View.GONE);
        }
        Matrix mCurrentDisplayMatrix = new Matrix();
        holder.photoView.setDisplayMatrix(mCurrentDisplayMatrix);
        holder.photoView.setOnMatrixChangeListener(new MatrixChangeListener());
        holder.photoView.setOnPhotoTapListener(new PhotoTapListener());
        holder.photoView.setOnSingleFlingListener(new SingleFlingListener());
        // 如果是原图就直接显示原图， 否则显示缩略图，点击查看原图按钮后下载原图显示
        // If it is the original image, the original image will be displayed directly, otherwise, the thumbnail image will be displayed. Click the View Original
        // Image button to download the original image and display it.

        loadImageIntoView(holder.photoView, previewImgPath);
        if (!isOriginImg) {
            V2TIMImageElem.V2TIMImage finalMCurrentOriginalImage = currentOriginalImage;
            holder.viewOriginalButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (finalMCurrentOriginalImage == null) {
                        TUIChatLog.e(TAG, "finalMCurrentOriginalImage is null");
                        return;
                    }
                    final String path = ImageUtil.generateImagePath(finalMCurrentOriginalImage.getUUID(), finalMCurrentOriginalImage.getType());

                    finalMCurrentOriginalImage.downloadImage(path, new V2TIMDownloadCallback() {
                        @Override
                        public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                            int progress = Math.round(progressInfo.getCurrentSize() * 1.0f * 100 / progressInfo.getTotalSize());
                            if (holder.viewOriginalButton.getVisibility() != View.INVISIBLE && holder.viewOriginalButton.getVisibility() != View.GONE) {
                                holder.viewOriginalButton.setText(progress + "%");
                            }
                        }

                        @Override
                        public void onError(int code, String desc) {
                            ToastUtil.toastLongMessage("Download origin image failed , errCode = " + code + ", " + desc);
                        }

                        @Override
                        public void onSuccess() {
                            ThreadUtils.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    loadImageIntoView(holder.photoView, path);
                                    holder.viewOriginalButton.setText(mContext.getString(R.string.completed));
                                    holder.viewOriginalButton.setOnClickListener(null);
                                    holder.viewOriginalButton.setVisibility(View.INVISIBLE);
                                    Intent intent = new Intent();
                                    intent.setAction(BROADCAST_DOWNLOAD_COMPLETED_ACTION);
                                    intent.putExtra(DOWNLOAD_ORIGIN_IMAGE_PATH, path);
                                    LocalBroadcastManager.getInstance(mContext).sendBroadcast(intent);
                                }
                            });
                        }
                    });
                }
            });
            // 因为图片还没下载下来 ， 加载失败, 接收下载成功的广播来刷新显示
            // Because the picture has not been downloaded yet, the loading fails, receive the broadcast of the successful download to refresh the display
            if (!TextUtils.isEmpty(localImgPath)) {
                ToastUtil.toastShortMessage(mContext.getString(R.string.downloading));
                downloadReceiver = new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        String action = intent.getAction();
                        if (BROADCAST_DOWNLOAD_COMPLETED_ACTION.equals(action)) {
                            String originImagePath = intent.getStringExtra(DOWNLOAD_ORIGIN_IMAGE_PATH);
                            if (originImagePath != null) {
                                loadImageIntoView(holder.photoView, originImagePath);
                            }
                        }
                    }
                };
                IntentFilter filter = new IntentFilter();
                filter.addAction(BROADCAST_DOWNLOAD_COMPLETED_ACTION);
                LocalBroadcastManager.getInstance(mContext).registerReceiver(downloadReceiver, filter);
            } else {
                holder.viewOriginalButton.setVisibility(View.VISIBLE);
                holder.viewOriginalButton.setText(R.string.view_original_image);
            }
        } else {
            holder.viewOriginalButton.setVisibility(View.INVISIBLE);
        }
    }

    private void performPhotoView(ViewHolder holder, TUIMessageBean messageBean, int positon) {
        holder.photoViewLayout.setVisibility(View.VISIBLE);
        holder.videoView.setVisibility(View.GONE);
        holder.closeButton.setVisibility(View.GONE);
        holder.playControlLayout.setVisibility(View.GONE);
        holder.pauseCenterView.setVisibility(View.GONE);
        holder.videoViewLayout.setVisibility(View.GONE);
        ImageMessageBean imageMessageBean;
        if (messageBean instanceof ImageMessageBean) {
            imageMessageBean = (ImageMessageBean) messageBean;
        } else {
            TUIChatLog.e(TAG, "is not ImageMessageBean");
            return;
        }

        loadPhotoView(holder, imageMessageBean, positon);
    }

    private void loadImageIntoView(ImageView imageView, Object resObj) {
        Glide.with(TUIChatService.getAppContext())
            .load(resObj)
            .centerInside()
            .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
            .into(imageView);
    }

    private void loadVideoView(ViewHolder holder, VideoMessageBean videoMessageBean, int position) {
        if (TextUtils.isEmpty(videoMessageBean.getSnapshotPath())) {
            final String path = TUIConfig.getImageDownloadDir() + videoMessageBean.getSnapshotUUID();
            videoMessageBean.downloadSnapshot(path, new VideoMessageBean.VideoDownloadCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    int progress = Math.round(currentSize * 1.0f * 100 / totalSize);
                    ProgressPresenter.updateProgress(videoMessageBean.getId(), progress);
                    TUIChatLog.i("downloadSnapshot progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e("MessageAdapter video getImage", code + ":" + desc);
                }

                @Override
                public void onSuccess() {
                    ProgressPresenter.updateProgress(videoMessageBean.getId(), 100);
                    holder.pauseCenterView.setVisibility(View.VISIBLE);
                    videoMessageBean.setSnapshotPath(path);
                    mCacheImagePath = path;
                    holder.snapImageView.setVisibility(View.VISIBLE);
                    loadImageIntoView(holder.snapImageView, path);
                    getOrPlayVideo(holder, videoMessageBean, position);
                }
            });
        } else {
            String imagePath = videoMessageBean.getSnapshotPath();
            holder.snapImageView.setVisibility(View.VISIBLE);
            loadImageIntoView(holder.snapImageView, imagePath);
        }

        if (videoMessageBean.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.sending));
            return;
        }
        if (videoMessageBean.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.send_failed));
            holder.progressBar.setVisibility(View.GONE);
            return;
        }

        getOrPlayVideo(holder, videoMessageBean, position);
    }

    private void getOrPlayVideo(ViewHolder holder, VideoMessageBean videoMessageBean, int position) {
        final String videoPath = videoMessageBean.getVideoPath();
        final File videoFile = new File(videoPath);
        if (videoFile.exists() && videoMessageBean.getVideoSize() == videoFile.length()) {
            playVideo(holder, videoMessageBean);
        } else {
            if (!holder.downloadVideoFailed && !holder.downloadVideoFinished) {
                holder.progressContainer.setVisibility(View.VISIBLE);
                holder.progressIcon.setVisibility(View.VISIBLE);
                holder.progressText.setVisibility(View.GONE);
                holder.progressBar.setProgress(0);
                holder.progressContainer.setOnClickListener(v -> getVideo(holder, videoPath, videoMessageBean, true, position));
            }
        }
    }

    private void performVideoView(ViewHolder holder, TUIMessageBean messageBean, int position) {
        holder.photoViewLayout.setVisibility(View.GONE);
        holder.videoView.setVisibility(View.VISIBLE);
        holder.closeButton.setVisibility(View.VISIBLE);
        holder.playControlLayout.setVisibility(View.VISIBLE);
        holder.pauseCenterView.setVisibility(View.GONE);
        holder.progressBar.setVisibility(View.VISIBLE);
        holder.videoViewLayout.setVisibility(View.VISIBLE);
        holder.progressContainer.setVisibility(View.GONE);
        VideoMessageBean videoMessageBean;
        if (messageBean instanceof VideoMessageBean) {
            videoMessageBean = (VideoMessageBean) messageBean;
        } else {
            TUIChatLog.e(TAG, "is not VideoMessageBean");
            return;
        }

        mIsVideoPlay = false;
        playControlInit(holder);
        loadVideoView(holder, videoMessageBean, position);
    }

    private void playControlInit(ViewHolder holder) {
        holder.closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (holder.videoView != null) {
                    holder.videoView.stop();
                } else {
                    TUIChatLog.e(TAG, "videoView is null");
                }
                onItemClickListener.onClickItem();
            }
        });
        holder.playButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                clickPlayVideo(holder);
            }
        });

        holder.playSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String durations = DateTimeUtil.formatSecondsTo00(progress);
                holder.timeBeginView.setText(durations);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                int progress = seekBar.getProgress();
                TUIChatLog.i(TAG, "onStartTrackingTouch progress == " + progress);
                if (holder.videoView != null) {
                    holder.videoView.seekTo(progress * 1000);
                }
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                int progress = seekBar.getProgress();
                TUIChatLog.i(TAG, "onStopTrackingTouch progress == " + progress);
                if (holder.videoView != null && holder.videoView.isPlaying()) {
                    holder.videoView.seekTo(progress * 1000);
                    holder.videoView.start();
                } else if (holder.videoView != null) {
                    holder.videoView.seekTo(progress * 1000);
                }
            }
        });

        holder.pauseCenterView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clickPlayVideo(holder);
            }
        });
    }

    private void clickPlayVideo(ViewHolder holder) {
        if (!holder.videoView.isPrepared()) {
            mIsVideoPlay = false;
            TUIChatLog.e(TAG, "!holder.videoView.isPrepared()");
            return;
        }
        if (holder.videoView.isPlaying()) {
            TUIChatLog.d(TAG, "holder.videoView.isPlaying()");
            holder.videoView.pause();
            holder.playButton.setImageResource(R.drawable.ic_play_icon);
            holder.pauseCenterView.setVisibility(View.VISIBLE);
            holder.progressBar.setVisibility(View.GONE);
            mIsVideoPlay = false;
        } else {
            float times = holder.videoView.getDuration() * 1.0f / 1000;
            if (times <= 0) {
                TUIChatLog.e(TAG, "onClick, downloading video");
                // ToastUtil.toastShortMessage("downloading video");
                holder.pauseCenterView.setVisibility(View.GONE);
                holder.progressBar.setVisibility(View.VISIBLE);
                resetVideo(holder);
                return;
            }

            int duration = Math.round(holder.videoView.getDuration() * 1.0f / 1000);
            int progress = Math.round(holder.videoView.getCurrentPosition() * 1.0f / 1000);
            TUIChatLog.d(TAG, "onClick playSeekBar duration == " + duration + " playSeekBar progress = " + progress);
            if (holder.playSeekBar.getProgress() >= duration) {
                TUIChatLog.e(TAG, "getProgress() >= duration");
                resetVideo(holder);
                return;
            }
            holder.videoView.start();
            holder.playButton.setImageResource(R.drawable.ic_pause_icon);
            holder.pauseCenterView.setVisibility(View.GONE);
            holder.progressBar.setVisibility(View.GONE);
            holder.snapImageView.setVisibility(View.GONE);
            mIsVideoPlay = true;

            holder.playSeekBar.setMax(duration);
            holder.playSeekBar.setProgress(progress);
            String durations = DateTimeUtil.formatSecondsTo00(duration);
            holder.timeEndView.setText(durations);
            if (durationHandler != null) {
                durationHandler.postDelayed(updateSeekBarTime, 100);
            }
        }
    }

    private Uri processVideoMessage(VideoMessageBean videoMessageBean) {
        V2TIMMessage timMessage = videoMessageBean.getV2TIMMessage();
        V2TIMVideoElem videoEle = timMessage.getVideoElem();
        if (timMessage.isSelf() && !TextUtils.isEmpty(videoEle.getSnapshotPath())) {
            return FileUtil.getUriFromPath(videoEle.getVideoPath());
        } else {
            final String videoPath = TUIConfig.getVideoDownloadDir() + videoEle.getVideoUUID();
            return Uri.parse(videoPath);
        }
    }

    private void playVideo(ViewHolder holder, VideoMessageBean videoMessageBean) {
        Uri videoUri = processVideoMessage(videoMessageBean);

        holder.pauseCenterView.setVisibility(View.VISIBLE);
        holder.progressBar.setVisibility(View.GONE);

        if (videoUri == null) {
            TUIChatLog.e(TAG, "playVideo videoUri == null");
            return;
        }
        Matrix matrix = new Matrix(holder.snapImageView.getImageMatrix());
        holder.videoView.setTransform(matrix);
        holder.videoView.invalidate();

        holder.videoView.setVideoURI(videoUri);
        holder.videoView.setOnPreparedListener(new IPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IPlayer mediaPlayer) {
                TUIChatLog.e(TAG, "onPrepared()");
                holder.videoView.start();
                holder.videoView.pause();
                holder.playButton.setImageResource(R.drawable.ic_play_icon);
                holder.pauseCenterView.setVisibility(View.VISIBLE);
                holder.progressBar.setVisibility(View.GONE);
                mIsVideoPlay = false;
                if (durationHandler != null) {
                    durationHandler = null;
                }
                if (updateSeekBarTime != null) {
                    updateSeekBarTime = null;
                }
                durationHandler = new Handler();
                durationHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        holder.snapImageView.setVisibility(View.GONE);
                    }
                }, 300);
                updateSeekBarTime = new Runnable() {
                    public void run() {
                        // TUIChatLog.e(TAG, "mIsVideoPlay = " + mIsVideoPlay);
                        // get current position
                        int timeElapsed = holder.videoView.getCurrentPosition();

                        if (holder.playSeekBar.getProgress() >= holder.playSeekBar.getMax()) {
                            TUIChatLog.e(TAG, "getProgress() >= getMax()");
                            resetVideo(holder);
                            return;
                        }
                        // set seekbar progress
                        // TUIChatLog.e(TAG, "Runnable playSeekBar setProgress = " + (int) timeElapsed/1000);
                        holder.playSeekBar.setProgress(Math.round(timeElapsed * 1.0f / 1000));

                        String durations = DateTimeUtil.formatSecondsTo00(Math.round(holder.videoView.getCurrentPosition() * 1.0f / 1000));
                        holder.timeBeginView.setText(durations);
                        // repeat yourself that again in 100 miliseconds
                        if (mIsVideoPlay) {
                            durationHandler.postDelayed(this, 100);
                        }
                    }
                };

                int duration = Math.round(mediaPlayer.getDuration() * 1.0f / 1000);
                int progress = Math.round(mediaPlayer.getCurrentPosition() * 1.0f / 1000);
                holder.playSeekBar.setMax(duration);
                holder.playSeekBar.setProgress(progress);
                String durations = DateTimeUtil.formatSecondsTo00(duration);
                holder.timeEndView.setText(durations);
                durationHandler.postDelayed(updateSeekBarTime, 100);
            }
        });
        holder.videoView.setOnSeekCompleteListener(new IPlayer.OnSeekCompleteListener() {
            @Override
            public void onSeekComplete(IPlayer mp) {}
        });
    }

    private void getVideo(ViewHolder holder, String videoPath, final VideoMessageBean msg, final boolean autoPlay, final int position) {
        if (loadingIdList.contains(msg.getId())) {
            return;
        }
        loadingIdList.add(msg.getId());
        msg.downloadVideo(videoPath, new VideoMessageBean.VideoDownloadCallback() {
            @Override
            public void onProgress(long currentSize, long totalSize) {
                int progress = Math.round(currentSize * 1.0f * 100 / totalSize);
                ProgressPresenter.updateProgress(msg.getId(), progress);
                TUIChatLog.i("downloadVideo progress current:", currentSize + ", total:" + totalSize);
                holder.downloadVideoFinished = false;
            }

            @Override
            public void onError(int code, String desc) {
                loadingIdList.remove(msg.getId());
                String errorMessage = ErrorMessageConverter.convertIMError(code, desc);
                ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.download_file_error) + code + " " + errorMessage);
                msg.setStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
                notifyItemChanged(position);
                holder.downloadVideoFailed = true;
            }

            @Override
            public void onSuccess() {
                loadingIdList.remove(msg.getId());
                ProgressPresenter.updateProgress(msg.getId(), 100);
                holder.pauseCenterView.setVisibility(View.VISIBLE);
                notifyItemChanged(position);
                holder.downloadVideoFailed = false;
                holder.downloadVideoFinished = true;
                if (autoPlay) {
                    playVideo(holder, msg);
                }
            }
        });
    }

    public void destroyView(RecyclerView mRecyclerView, int index) {
        View itemView = mRecyclerView.getChildAt(index);
        if (itemView != null) {
            VideoView videoView = itemView.findViewById(R.id.video_play_view);
            SeekBar playSeekBar = itemView.findViewById(R.id.play_seek);
            if (videoView != null) {
                videoView.stop();
            }
            if (playSeekBar != null) {
                playSeekBar.setProgress(0);
            }
        }

        if (downloadReceiver != null) {
            LocalBroadcastManager.getInstance(mContext).unregisterReceiver(downloadReceiver);
            downloadReceiver = null;
        }
    }

    public void setDataSource(List<TUIMessageBean> dataSource) {
        if (dataSource != null && !dataSource.isEmpty()) {
            mOldLocateMessage = dataSource.get(0);
            mNewLocateMessage = dataSource.get(dataSource.size() - 1);
        } else {
            TUIChatLog.d(TAG, "setDataSource dataSource is Empty");
            mOldLocateMessage = null;
            mNewLocateMessage = null;
        }
        this.mDataSource = dataSource;

        for (TUIMessageBean messageBean : mDataSource) {
            TUIChatLog.d(TAG, "message seq = " + messageBean.getV2TIMMessage().getSeq());
        }
        Log.d(TAG, "mOldLocateMessage seq:" + mOldLocateMessage.getV2TIMMessage().getSeq());
        Log.d(TAG, "mNewLocateMessage seq:" + mNewLocateMessage.getV2TIMMessage().getSeq());
    }

    public List<TUIMessageBean> getDataSource() {
        return mDataSource;
    }

    public TUIMessageBean getOldLocateMessage() {
        return mOldLocateMessage;
    }

    public TUIMessageBean getNewLocateMessage() {
        return mNewLocateMessage;
    }

    public int addDataToSource(List<TUIMessageBean> dataSource, int type, int oldPositon) {
        int newPositon = oldPositon;
        if (dataSource == null || dataSource.isEmpty()) {
            return newPositon;
        }
        if (mDataSource == null) {
            TUIChatLog.e(TAG, "addDataToSource mDataSource is null");
            return newPositon;
        }

        TUIMessageBean messageBean = mDataSource.get(oldPositon);
        if (type == TUIChatConstants.GET_MESSAGE_FORWARD) {
            mOldLocateMessage = dataSource.get(0);
            Log.d(TAG, "mOldLocateMessage seq:" + mOldLocateMessage.getV2TIMMessage().getSeq());

            mDataSource.addAll(0, dataSource);
            newPositon = dataSource.size();
        } else if (type == TUIChatConstants.GET_MESSAGE_BACKWARD) {
            mNewLocateMessage = dataSource.get(dataSource.size() - 1);
            Log.d(TAG, "mNewLocateMessage seq:" + mNewLocateMessage.getV2TIMMessage().getSeq());

            mDataSource.addAll(dataSource);
            newPositon = oldPositon;
        } else {
            TUIChatLog.e(TAG, "addDataToSource error type");
        }

        for (TUIMessageBean tuiMessageBean : mDataSource) {
            TUIChatLog.d(TAG, "message seq = " + tuiMessageBean.getV2TIMMessage().getSeq());
        }

        if (messageBean == null) {
            TUIChatLog.e(TAG, "messageBean == null");
            return newPositon;
        }

        return newPositon;
    }

    private class PhotoTapListener implements OnPhotoTapListener {
        @Override
        public void onPhotoTap(ImageView view, float x, float y) {
            if (onItemClickListener != null) {
                onItemClickListener.onClickItem();
            }
        }
    }

    private class MatrixChangeListener implements OnMatrixChangedListener {
        @Override
        public void onMatrixChanged(RectF rect) {}
    }

    private class SingleFlingListener implements OnSingleFlingListener {
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
            return true;
        }
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        RelativeLayout photoViewLayout;
        PhotoView photoView;
        TextView viewOriginalButton;

        FrameLayout videoViewLayout;
        VideoView videoView;
        boolean downloadVideoFailed = false;
        boolean downloadVideoFinished = false;
        ImageView closeButton;
        LinearLayout playControlLayout;
        ImageView playButton;
        SeekBar playSeekBar;
        TextView timeBeginView;
        TextView timeEndView;
        ImageView pauseCenterView;
        ImageView snapImageView;
        FrameLayout progressContainer;
        ChatRingProgressBar progressBar;
        ImageView progressIcon;
        TextView progressText;
        private ProgressPresenter.ProgressListener progressListener;

        public ViewHolder(View itemView) {
            super(itemView);
            photoViewLayout = itemView.findViewById(R.id.photo_view_layout);
            photoView = itemView.findViewById(R.id.photo_view);
            viewOriginalButton = itemView.findViewById(R.id.view_original_btn);
            videoView = itemView.findViewById(R.id.video_play_view);
            closeButton = itemView.findViewById(R.id.close_button);
            playControlLayout = itemView.findViewById(R.id.play_control_layout);
            playButton = itemView.findViewById(R.id.play_button);
            playSeekBar = itemView.findViewById(R.id.play_seek);
            timeEndView = itemView.findViewById(R.id.time_end);
            timeBeginView = itemView.findViewById(R.id.time_begin);
            pauseCenterView = itemView.findViewById(R.id.pause_button_center);
            snapImageView = itemView.findViewById(R.id.content_image_iv);
            videoViewLayout = itemView.findViewById(R.id.video_view_layout);
            progressContainer = itemView.findViewById(R.id.progress_container);
            progressText = itemView.findViewById(R.id.file_progress_text);
            progressBar = itemView.findViewById(R.id.file_progress_bar);
            progressIcon = itemView.findViewById(R.id.file_progress_icon);
        }
    }
}
