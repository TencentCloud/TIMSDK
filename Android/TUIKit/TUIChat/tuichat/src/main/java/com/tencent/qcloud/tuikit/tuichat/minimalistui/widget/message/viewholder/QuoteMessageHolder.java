package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FaceReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FileReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.ImageReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.MergeReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.SoundReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TextReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.VideoReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.List;

public class QuoteMessageHolder extends TextMessageHolder {
    private final TextView senderNameTv;
    private FrameLayout quoteContentFrameLayout;

    // text/merge
    private final FrameLayout textFrame;
    private final TextView textTv;
    // image/video/face
    private final FrameLayout imageFrame;
    private final ImageView imageIv;
    private final ImageView playIv;
    protected final List<String> downloadEles = new ArrayList<>();
    protected String mImagePath = null;
    // file
    private final FrameLayout fileFrame;
    private final TextView fileNameTv;
    private final ImageView fileIconIv;
    // sound
    private final FrameLayout soundFrame;
    private final TextView soundTimeTv;
    private final ImageView soundIconIv;

    public QuoteMessageHolder(View itemView) {
        super(itemView);
        quoteContentFrameLayout = itemView.findViewById(com.tencent.qcloud.tuikit.timcommon.R.id.quote_content_fl);
        quoteContentFrameLayout.setVisibility(View.VISIBLE);
        LayoutInflater.from(itemView.getContext()).inflate(R.layout.minimalist_quote_message_content_layout, quoteContentFrameLayout);
        senderNameTv = quoteContentFrameLayout.findViewById(R.id.sender_name_tv);

        textFrame = quoteContentFrameLayout.findViewById(R.id.text_msg_area);
        textTv = quoteContentFrameLayout.findViewById(R.id.msg_abstract_tv);

        imageFrame = quoteContentFrameLayout.findViewById(R.id.image_video_msg_area);
        imageIv = quoteContentFrameLayout.findViewById(R.id.msg_image_iv);
        playIv = quoteContentFrameLayout.findViewById(R.id.msg_play_iv);

        fileFrame = quoteContentFrameLayout.findViewById(R.id.file_msg_area);
        fileNameTv = quoteContentFrameLayout.findViewById(R.id.file_name_tv);
        fileIconIv = quoteContentFrameLayout.findViewById(R.id.file_icon_iv);

        soundFrame = quoteContentFrameLayout.findViewById(R.id.sound_msg_area);
        soundTimeTv = quoteContentFrameLayout.findViewById(R.id.sound_msg_time_tv);
        soundIconIv = quoteContentFrameLayout.findViewById(R.id.sound_msg_icon_iv);
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        extraInfoArea.setVisibility(View.VISIBLE);

        msg.setSelectText(msg.getExtra());
        QuoteMessageBean quoteMessageBean = (QuoteMessageBean) msg;
        TUIMessageBean replyContentBean = quoteMessageBean.getContentMessageBean();
        String replyContent = replyContentBean.getExtra();
        FaceManager.handlerEmojiText(timeInLineTextLayout.getTextView(), replyContent, false);
        String senderName = quoteMessageBean.getOriginMsgSender();
        senderNameTv.setText(senderName + ": ");

        performMsgAbstract(quoteMessageBean);

        msgArea.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                return true;
            }
        });

        quoteContentFrameLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (onItemClickListener != null) {
                    onItemClickListener.onReplyMessageClick(view, position, quoteMessageBean);
                }
            }
        });
        if (isForwardMode || isMessageDetailMode) {
            return;
        }
        if (!TextUtils.isEmpty(replyContent)) {
            FaceManager.handlerEmojiText(timeInLineTextLayout.getTextView(), replyContent, false);
        }

        if (floatMode) {
            quoteContentFrameLayout.setVisibility(View.GONE);
        }
    }

    private void performMsgAbstract(QuoteMessageBean quoteMessageBean) {
        resetAll();
        TUIMessageBean originMessage = quoteMessageBean.getOriginMessageBean();

        TUIReplyQuoteBean replyQuoteBean = quoteMessageBean.getReplyQuoteBean();
        if (originMessage != null) {
            performQuote(replyQuoteBean, quoteMessageBean);
        } else {
            performNotFound(replyQuoteBean, quoteMessageBean);
        }
    }

    private void resetAll() {
        textFrame.setVisibility(View.GONE);
        imageFrame.setVisibility(View.GONE);
        fileFrame.setVisibility(View.GONE);
        soundFrame.setVisibility(View.GONE);
        playIv.setVisibility(View.GONE);
    }

    private void performNotFound(TUIReplyQuoteBean quoteMessageBean, QuoteMessageBean replyMessageBean) {
        String typeStr = ChatMessageParser.getMsgTypeStr(quoteMessageBean.getMessageType());
        String abstractStr = quoteMessageBean.getDefaultAbstract();
        if (ChatMessageParser.isFileType(quoteMessageBean.getMessageType())) {
            abstractStr = "";
        }
        performTextMessage(typeStr + abstractStr);
    }

    private void performTextMessage(String text) {
        textFrame.setVisibility(View.VISIBLE);
        FaceManager.handlerEmojiText(textTv, text, false);
    }

    private void performImage(TUIReplyQuoteBean replyQuoteBean) {
        imageFrame.setVisibility(View.VISIBLE);
        int imageRadius = ScreenUtil.dip2px(1.92f);

        if (replyQuoteBean instanceof FaceReplyQuoteBean) {
            FaceReplyQuoteBean faceReplyQuoteBean = (FaceReplyQuoteBean) replyQuoteBean;
            String faceKey = new String(faceReplyQuoteBean.getData());
            ViewGroup.LayoutParams params = imageIv.getLayoutParams();
            if (params != null) {
                int maxSize = itemView.getResources().getDimensionPixelSize(R.dimen.reply_message_image_size);
                params.width = maxSize;
                params.height = maxSize;
                imageIv.setLayoutParams(params);
            }
            FaceManager.loadFace(faceReplyQuoteBean.getIndex(), faceKey, imageIv);

        } else if (replyQuoteBean instanceof ImageReplyQuoteBean) {
            ImageMessageBean messageBean = (ImageMessageBean) replyQuoteBean.getMessageBean();
            imageIv.setLayoutParams(getImageParams(imageIv.getLayoutParams(), messageBean.getImgWidth(), messageBean.getImgHeight()));
            final List<ImageMessageBean.ImageBean> imgs = messageBean.getImageBeanList();
            String imagePath = messageBean.getDataPath();
            String originImagePath = TUIChatUtils.getOriginImagePath(messageBean);
            if (!TextUtils.isEmpty(originImagePath)) {
                imagePath = originImagePath;
            }
            if (!TextUtils.isEmpty(imagePath)) {
                GlideEngine.loadCornerImageWithoutPlaceHolder(imageIv, imagePath, null, imageRadius);
            } else {
                GlideEngine.clear(imageIv);
                for (int i = 0; i < imgs.size(); i++) {
                    final ImageMessageBean.ImageBean img = imgs.get(i);
                    if (img.getType() == ImageMessageBean.IMAGE_TYPE_THUMB) {
                        synchronized (downloadEles) {
                            if (downloadEles.contains(img.getUUID())) {
                                break;
                            }
                            downloadEles.add(img.getUUID());
                        }
                        final String path = ImageUtil.generateImagePath(img.getUUID(), ImageMessageBean.IMAGE_TYPE_THUMB);
                        if (!path.equals(mImagePath)) {
                            GlideEngine.clear(imageIv);
                        }
                        img.downloadImage(path, new ImageMessageBean.ImageBean.ImageDownloadCallback() {
                            @Override
                            public void onProgress(long currentSize, long totalSize) {
                                TUIChatLog.i("downloadImage progress current:", currentSize + ", total:" + totalSize);
                            }

                            @Override
                            public void onError(int code, String desc) {
                                downloadEles.remove(img.getUUID());
                                TUIChatLog.e("MessageAdapter img getImage", code + ":" + desc);
                            }

                            @Override
                            public void onSuccess() {
                                downloadEles.remove(img.getUUID());
                                messageBean.setDataPath(path);
                                GlideEngine.loadCornerImageWithoutPlaceHolder(imageIv, messageBean.getDataPath(), new RequestListener() {
                                    @Override
                                    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target target, boolean isFirstResource) {
                                        mImagePath = null;
                                        return false;
                                    }

                                    @Override
                                    public boolean onResourceReady(
                                        Object resource, Object model, Target target, DataSource dataSource, boolean isFirstResource) {
                                        mImagePath = path;
                                        return false;
                                    }
                                }, imageRadius);
                            }
                        });
                        break;
                    }
                }
            }
        } else if (replyQuoteBean instanceof VideoReplyQuoteBean) {
            VideoMessageBean messageBean = (VideoMessageBean) replyQuoteBean.getMessageBean();
            ViewGroup.LayoutParams layoutParams = getImageParams(imageIv.getLayoutParams(), messageBean.getImgWidth(), messageBean.getImgHeight());
            imageIv.setLayoutParams(layoutParams);
            playIv.setLayoutParams(layoutParams);
            playIv.setVisibility(View.VISIBLE);
            if (!TextUtils.isEmpty(messageBean.getSnapshotPath())) {
                GlideEngine.loadCornerImageWithoutPlaceHolder(imageIv, messageBean.getSnapshotPath(), null, imageRadius);
            } else {
                GlideEngine.clear(imageIv);
                synchronized (downloadEles) {
                    if (!downloadEles.contains(messageBean.getSnapshotUUID())) {
                        downloadEles.add(messageBean.getSnapshotUUID());
                    }
                }

                final String path = TUIConfig.getImageDownloadDir() + messageBean.getSnapshotUUID();
                messageBean.downloadSnapshot(path, new VideoMessageBean.VideoDownloadCallback() {
                    @Override
                    public void onProgress(long currentSize, long totalSize) {
                        TUIChatLog.i("downloadSnapshot progress current:", currentSize + ", total:" + totalSize);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        downloadEles.remove(messageBean.getSnapshotUUID());
                        TUIChatLog.e("MessageAdapter video getImage", code + ":" + desc);
                    }

                    @Override
                    public void onSuccess() {
                        downloadEles.remove(messageBean.getSnapshotUUID());
                        messageBean.setSnapshotPath(path);
                        GlideEngine.loadCornerImageWithoutPlaceHolder(imageIv, messageBean.getSnapshotPath(), null, imageRadius);
                    }
                });
            }
        }
    }

    protected ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, int width, int height) {
        if (width == 0 || height == 0) {
            return params;
        }
        int maxSize = itemView.getResources().getDimensionPixelSize(R.dimen.reply_message_image_size);
        if (width > height) {
            params.width = maxSize;
            params.height = maxSize * height / width;
        } else {
            params.width = maxSize * width / height;
            params.height = maxSize;
        }
        return params;
    }

    private void performFile(FileReplyQuoteBean fileReplyQuoteBean) {
        fileFrame.setVisibility(View.VISIBLE);
        fileNameTv.setText(fileReplyQuoteBean.getFileName());
    }

    private void performSound(SoundReplyQuoteBean soundReplyQuoteBean) {
        soundFrame.setVisibility(View.VISIBLE);
        soundTimeTv.setText(soundReplyQuoteBean.getDuring() + "''");
    }

    private void performQuote(TUIReplyQuoteBean replyQuoteBean, QuoteMessageBean messageBean) {
        if (replyQuoteBean instanceof TextReplyQuoteBean || replyQuoteBean instanceof MergeReplyQuoteBean) {
            String text;
            if (replyQuoteBean instanceof TextReplyQuoteBean) {
                text = ((TextReplyQuoteBean) replyQuoteBean).getText();
            } else {
                text = messageBean.getOriginMsgAbstract();
            }
            performTextMessage(text);
        } else if (replyQuoteBean instanceof FileReplyQuoteBean) {
            performFile((FileReplyQuoteBean) replyQuoteBean);
        } else if (replyQuoteBean instanceof SoundReplyQuoteBean) {
            performSound((SoundReplyQuoteBean) replyQuoteBean);
        } else if (replyQuoteBean instanceof ImageReplyQuoteBean || replyQuoteBean instanceof VideoReplyQuoteBean
            || replyQuoteBean instanceof FaceReplyQuoteBean) {
            performImage(replyQuoteBean);
        }
    }
}
