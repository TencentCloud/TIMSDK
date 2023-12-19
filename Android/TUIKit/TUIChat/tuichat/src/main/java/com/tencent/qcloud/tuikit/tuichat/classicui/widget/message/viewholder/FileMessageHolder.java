package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.NetworkConnectionListener;
import com.tencent.qcloud.tuikit.tuichat.model.ChatFileDownloadProvider;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.Locale;

public class FileMessageHolder extends MessageContentHolder {
    private static final String TAG = "FileMessageHolder";
    private TextView fileNameText;
    private TextView fileSizeText;
    private TextView fileStatusText;

    private ProgressPresenter.ProgressListener progressListener;
    private NetworkConnectionListener networkConnectionListener;
    private TUIValueCallback downloadCallback;

    private ProgressDrawable progressDrawable;
    private Drawable normalBackground;
    private String msgId;

    public FileMessageHolder(View itemView) {
        super(itemView);
        fileNameText = itemView.findViewById(R.id.file_name_tv);
        fileSizeText = itemView.findViewById(R.id.file_size_tv);
        fileStatusText = itemView.findViewById(R.id.file_status_tv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_file;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        msgId = msg.getId();
        reactView.setThemeColorId(TUIThemeManager.getAttrResId(reactView.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.chat_react_other_text_color));
        if (isForwardMode || isReplyDetailMode) {
            setMessageBubbleBackground(R.drawable.chat_bubble_other_cavity_bg);
            statusImage.setVisibility(View.GONE);
        } else {
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    setMessageBubbleBackground(properties.getRightBubble().getConstantState().newDrawable());
                } else {
                    setMessageBubbleBackground(R.drawable.chat_bubble_self_cavity_bg);
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    setMessageBubbleBackground(properties.getLeftBubble().getConstantState().newDrawable());
                } else {
                    setMessageBubbleBackground(R.drawable.chat_bubble_other_cavity_bg);
                }
            }
        }
        normalBackground = getMessageBubbleBackground();

        progressListener = new ProgressPresenter.ProgressListener() {
            @Override
            public void onProgress(int progress) {
                updateProgress(progress, msg);
            }
        };

        sendingProgress.setVisibility(View.GONE);
        FileMessageBean message = (FileMessageBean) msg;
        final String path = ChatFileDownloadPresenter.getFilePath(message);
        boolean isFileExists = FileUtil.isFileExists(path);
        fileNameText.setText(message.getFileName());
        String size = FileUtil.formatFileSize(message.getFileSize());
        final String fileName = message.getFileName();
        fileSizeText.setText(size);
        if (!isMultiSelectMode) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (isFileExists) {
                        FileUtil.openFile(path, fileName);
                    }
                }
            });
        } else {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, msg);
                    }
                }
            });
        }

        if (isFileExists) {
            String selfPath = ChatFileDownloadProvider.getFileSelfPath(message);
            // send from current device
            if (FileUtil.isFileExists(selfPath)) {
                if (message.getStatus() == TUIMessageBean.MSG_STATUS_SEND_SUCCESS) {
                    fileStatusText.setText(R.string.sended);
                } else if (message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
                    fileStatusText.setText(R.string.sending);
                } else if (message.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                    fileStatusText.setText(R.string.send_failed);
                } else {
                    fileStatusText.setText(R.string.sended);
                }
            } else {
                fileStatusText.setText(R.string.downloaded);
            }
        } else {
            if (ChatFileDownloadPresenter.isDownloading(path)) {
                fileStatusText.setText(R.string.downloading);
            } else {
                fileStatusText.setText(R.string.un_download);
            }
        }

        if (!isFileExists) {
            if (isMultiSelectMode) {
                return;
            }
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    downloadFile(message);
                }
            });
            if (ChatFileDownloadPresenter.isDownloading(path)) {
                downloadFile(message);
            }
        }
        networkConnectionListener = new NetworkConnectionListener() {
            @Override
            public void onConnected() {
                String filePath = ChatFileDownloadPresenter.getFilePath(message);
                if (!FileUtil.isFileExists(filePath) && message.isDownloading()) {
                    downloadFile(message);
                }
            }
        };
        TUIChatService.getInstance().registerNetworkListener(networkConnectionListener);
        ProgressPresenter.registerProgressListener(msg.getId(), progressListener);
    }

    private void downloadFile(FileMessageBean message) {
        String path = ChatFileDownloadPresenter.getFilePath(message);
        if (FileUtil.isFileExists(path)) {
            return;
        }
        message.setDownloading(true);
        fileStatusText.setText(R.string.downloading);
        downloadCallback = new TUIValueCallback() {
            @Override
            public void onProgress(long currentSize, long totalSize) {
                int progress = (int) (currentSize * 100 / totalSize);
                ProgressPresenter.updateProgress(message.getId(), progress);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, String.format(Locale.US, "download file %s failed code %d,message %s", path, code, desc));
                ToastUtil.toastLongMessage(ErrorMessageConverter.convertIMError(code, desc));
                if (mAdapter != null) {
                    mAdapter.onItemRefresh(message);
                }
            }

            @Override
            public void onSuccess(Object obj) {
                message.setDownloading(false);
                updateProgress(100, message);
                if (mAdapter != null) {
                    mAdapter.onItemRefresh(message);
                }
            }
        };
        ChatFileDownloadPresenter.downloadFile(message, downloadCallback);
    }

    private void updateProgress(int progress, TUIMessageBean msg) {
        if (!TextUtils.equals(msg.getId(), msgId)) {
            return;
        }

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            fileStatusText.setText(R.string.sending);
        } else {
            fileStatusText.setText(R.string.downloading);
        }

        if (progress == 0 || progress == 100) {
            setMessageBubbleBackground(normalBackground);
            if (progressDrawable != null) {
                progressDrawable.setProgress(0);
            }
            return;
        }

        Drawable drawable = getMessageBubbleBackground();
        if (drawable != null) {
            if (progressDrawable == null) {
                progressDrawable = new ProgressDrawable();
                progressDrawable.setProgress(progress);
                Context context = itemView.getContext();
                progressDrawable.setPaintColor(
                    context.getResources().getColor(TUIThemeManager.getAttrResId(context, com.tencent.qcloud.tuicore.R.attr.core_bubble_bg_color)));
                progressDrawable.setBorderColor(context.getResources().getColor(R.color.chat_message_bubble_bg_stoke_color));
                progressDrawable.setSelf(msg.isSelf());
                progressDrawable.setBackgroundDrawable(drawable);
                setMessageBubbleBackground(progressDrawable);
            } else {
                progressDrawable.setProgress(progress);
                setMessageBubbleBackground(progressDrawable);
                getMessageBubbleBackground().invalidateSelf();
            }
        }
    }

    @Override
    public void setHighLightBackground(int color) {
        if (normalBackground != null) {
            normalBackground.setColorFilter(color, PorterDuff.Mode.SRC_IN);
        }
        if (progressDrawable != null) {
            progressDrawable.setHighLightColor(color);
            progressDrawable.invalidateSelf();
        }
    }

    @Override
    public void clearHighLightBackground() {
        if (normalBackground != null) {
            normalBackground.setColorFilter(null);
        }
        if (progressDrawable != null) {
            progressDrawable.clearHighLightColor();
            progressDrawable.invalidateSelf();
        }
    }

    @Override
    public void onRecycled() {
        super.onRecycled();
        progressListener = null;
        ProgressPresenter.unregisterProgressListener(msgId, progressListener);
    }

    static class ProgressDrawable extends Drawable {
        private Drawable backgroundDrawable;
        private int progress;
        private boolean isSelf;
        private final Paint paint;
        private final Paint borderPaint;
        private final Paint highLightPaint;
        private final Path rectPath = new Path();
        private final Path solidPath = new Path();
        private final Path highLightPath = new Path();
        private final float borderWidth = ScreenUtil.dip2px(0.96f);
        private final boolean isRTL;

        ProgressDrawable() {
            paint = new Paint();
            borderPaint = new Paint();
            paint.setStyle(Paint.Style.FILL);
            borderPaint.setStyle(Paint.Style.STROKE);
            borderPaint.setStrokeWidth(borderWidth);
            paint.setAntiAlias(true);
            borderPaint.setAntiAlias(true);
            highLightPaint = new Paint();
            highLightPaint.setAntiAlias(true);
            highLightPaint.setStyle(Paint.Style.FILL);
            highLightPaint.setColor(Color.TRANSPARENT);
            isRTL = LayoutUtil.isRTL();
        }

        public void setPaintColor(int color) {
            paint.setColor(color);
        }

        public void setBorderColor(int color) {
            borderPaint.setColor(color);
        }

        public void setProgress(int progress) {
            this.progress = progress;
        }

        public void setHighLightColor(int color) {
            highLightPaint.setColor(color);
        }

        public void clearHighLightColor() {
            highLightPaint.setColor(Color.TRANSPARENT);
        }

        public void setBackgroundDrawable(Drawable backgroundDrawable) {
            this.backgroundDrawable = backgroundDrawable;
        }

        public void setSelf(boolean self) {
            isSelf = self;
        }

        @Override
        public void draw(@NonNull Canvas canvas) {
            if (progress == 0) {
                return;
            }

            float[] radius;
            float normalRadius = ScreenUtil.dip2px(10.96f);
            float specialRadius = ScreenUtil.dip2px(2.19f);
            float[] selfRadius = new float[] {normalRadius, normalRadius, specialRadius, specialRadius, normalRadius, normalRadius, normalRadius, normalRadius};
            float[] otherRadius =
                new float[] {specialRadius, specialRadius, normalRadius, normalRadius, normalRadius, normalRadius, normalRadius, normalRadius};
            if (isSelf) {
                radius = selfRadius;
                if (isRTL) {
                    radius = otherRadius;
                }
            } else {
                radius = otherRadius;
                if (isRTL) {
                    radius = selfRadius;
                }
            }
            rectPath.reset();
            solidPath.reset();
            highLightPath.reset();
            Rect rect = backgroundDrawable.getBounds();
            int height = rect.bottom;
            int width = rect.right;
            rectPath.addRoundRect(new RectF(borderWidth / 2, borderWidth / 2, width - borderWidth / 2, height - borderWidth / 2), radius, Path.Direction.CW);
            highLightPath.set(rectPath);
            canvas.drawPath(rectPath, borderPaint);
            int solidWidth = width * progress / 100;
            if (isRTL) {
                solidPath.addRect(new RectF(width - solidWidth, borderWidth / 2, width - borderWidth / 2, height - borderWidth / 2), Path.Direction.CW);
            } else {
                solidPath.addRect(new RectF(borderWidth / 2, borderWidth / 2, solidWidth - borderWidth / 2, height - borderWidth / 2), Path.Direction.CW);
            }
            rectPath.op(solidPath, Path.Op.INTERSECT);
            canvas.drawPath(rectPath, paint);
            canvas.drawPath(highLightPath, highLightPaint);
        }

        @Override
        public void setAlpha(int alpha) {}

        @Override
        public void setColorFilter(@Nullable ColorFilter colorFilter) {}

        @Override
        public int getOpacity() {
            return PixelFormat.UNKNOWN;
        }
    }
}