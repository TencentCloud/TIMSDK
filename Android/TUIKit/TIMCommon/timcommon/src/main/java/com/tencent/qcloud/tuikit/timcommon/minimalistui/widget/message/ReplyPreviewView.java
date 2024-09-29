package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class ReplyPreviewView extends FrameLayout {
    private ImageView firstImg;
    private ImageView secondImg;
    private ImageView thirdImg;
    private TextView replyText;

    private MessageRepliesBean messageRepliesBean;

    public ReplyPreviewView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public ReplyPreviewView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public ReplyPreviewView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    public void setMessageRepliesBean(MessageRepliesBean messageRepliesBean) {
        this.messageRepliesBean = messageRepliesBean;
        setView();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public ReplyPreviewView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.chat_minimalist_reply_preview_layout, this);
        firstImg = findViewById(R.id.first_avatar);
        secondImg = findViewById(R.id.second_avatar);
        thirdImg = findViewById(R.id.third_avatar);
        replyText = findViewById(R.id.reply_text);
    }

    private void setView() {
        if (messageRepliesBean != null && messageRepliesBean.getRepliesSize() > 0) {
            setVisibility(VISIBLE);
            firstImg.setVisibility(GONE);
            secondImg.setVisibility(GONE);
            thirdImg.setVisibility(GONE);
            replyText.setText(String.format(Locale.US, getResources().getString(R.string.chat_reply_num), messageRepliesBean.getRepliesSize()));
            List<MessageRepliesBean.ReplyBean> repliesBeanList = messageRepliesBean.getReplies();
            List<String> iconList = getReplyUserIconLt(repliesBeanList);
            if (iconList.isEmpty()) {
                return;
            }
            String secondIconUrl = null;
            String thirdIconUrl = null;

            if (iconList.size() > 1) {
                secondIconUrl = iconList.get(1);
            }
            if (iconList.size() > 2) {
                thirdIconUrl = iconList.get(2);
            }
            String firstIconUrl = iconList.get(0);
            firstImg.setVisibility(VISIBLE);
            loadAvatar(firstImg, firstIconUrl);
            if (secondIconUrl != null) {
                secondImg.setVisibility(VISIBLE);
                loadAvatar(secondImg, secondIconUrl);
            }

            if (iconList.size() == 3 && thirdIconUrl != null) {
                thirdImg.setVisibility(VISIBLE);
                loadAvatar(thirdImg, thirdIconUrl);
            } else if (iconList.size() > 3) {
                thirdImg.setVisibility(VISIBLE);
                loadAvatar(thirdImg, R.drawable.chat_reply_more_icon);
            }
        } else {
            setVisibility(GONE);
        }
    }

    private List<String> getReplyUserIconLt(List<MessageRepliesBean.ReplyBean> repliesBeanList) {
        Set<String> iconUrlSet = new LinkedHashSet<>();
        for (MessageRepliesBean.ReplyBean replyBean : repliesBeanList) {
            iconUrlSet.add(replyBean.getSenderFaceUrl());
            if (iconUrlSet.size() >= 3) {
                break;
            }
        }
        return new ArrayList<>(iconUrlSet);
    }

    private void loadAvatar(ImageView imageView, Object url) {
        if (getContext() instanceof Activity) {
            if (((Activity) getContext()).isDestroyed() || ((Activity) getContext()).isFinishing()) {
                return;
            }
        }

        RequestBuilder<Drawable> errorRequestBuilder = Glide.with(getContext())
            .load(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_default_user_icon_light)
            .transform(new ReplyRingCircleCrop());

        Glide.with(getContext())
            .load(url)
            .centerCrop()
            .transform(new ReplyRingCircleCrop())
            .error(errorRequestBuilder)
            .into(imageView);
    }

    static class ReplyRingCircleCrop extends CircleCrop {
        @Override
        protected Bitmap transform(@NonNull BitmapPool pool, @NonNull Bitmap toTransform, int outWidth, int outHeight) {
            Bitmap outBitmap = pool.get(outWidth, outHeight, Bitmap.Config.ARGB_8888);
            Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
            paint.setColor(Color.WHITE);
            Canvas canvas = new Canvas(outBitmap);
            int borderWidth = ScreenUtil.dip2px(1);
            int innerWidth = outWidth - 2 * borderWidth;
            canvas.drawCircle(outWidth / 2, outHeight / 2, innerWidth / 2, paint);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
            Rect rect = new Rect(borderWidth, borderWidth, outWidth - borderWidth, outHeight - borderWidth);
            int innerHeight = outHeight - 2 * borderWidth;
            Bitmap bitmap = super.transform(pool, toTransform, innerWidth, innerHeight);
            canvas.drawBitmap(bitmap, null, rect, paint);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.DST_OVER));
            canvas.drawCircle(outWidth / 2, outHeight / 2, outWidth / 2, paint);
            return outBitmap;
        }
    }
}
