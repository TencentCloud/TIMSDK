package com.tencent.qcloud.tuikit.tuiconversation.ui.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuikit.tuiconversation.R;
import com.tencent.qcloud.tuikit.tuiconversation.bean.ConversationInfo;
import com.tencent.qcloud.tuicore.component.gatherimage.SynthesizedImageView;
import com.tencent.qcloud.tuikit.tuiconversation.presenter.ConversationIconPresenter;
import com.tencent.qcloud.tuikit.tuiconversation.util.ConversationUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * 会话列表头像View
 */
public class ConversationIconView extends RelativeLayout {

    private static final int icon_size = ScreenUtil.getPxByDp(50);
    private ImageView mIconView;

    private ConversationIconPresenter presenter;

    public ConversationIconView(Context context) {
        super(context);
        init();
    }

    public ConversationIconView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ConversationIconView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.profile_icon_view, this);
        mIconView = findViewById(R.id.profile_icon);
        ((SynthesizedImageView) mIconView).defaultImage(0);
        presenter = new ConversationIconPresenter();
    }

    /**
     * 设置会话头像的url
     *
     * @param iconUrls 头像url,最多只取前9个
     */
    public void setIconUrls(final List<Object> iconUrls, final String conversationId) {
        // 需要在主线程中执行，以免写缓存出现问题
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mIconView instanceof SynthesizedImageView) {
                    ((SynthesizedImageView) (mIconView)).displayImage(iconUrls).load(conversationId);
                }
            }
        });
    }

    public void setConversation(ConversationInfo conversationInfo) {
        if (mIconView instanceof SynthesizedImageView) {
            ((SynthesizedImageView) (mIconView)).setImageId(conversationInfo.getConversationId());
            if (conversationInfo.isGroup()) {
                fillConversationUrlForGroup(conversationInfo);
            } else {
                setIconUrls(conversationInfo.getIconUrlList(), conversationInfo.getConversationId());
            }
        }
    }

    private void fillConversationUrlForGroup(final ConversationInfo info) {
        if (info.getIconUrlList() == null || info.getIconUrlList().size() == 0) {
            // 读取文件，在线程池中进行，避免主线程卡顿
            ThreadHelper.INST.execute(new Runnable() {
                @Override
                public void run() {
                    final String savedIcon = ImageUtil.getGroupConversationAvatar(info.getConversationId());
                    if (TextUtils.isEmpty(savedIcon)) {
                        fillFaceUrlList(info.getId(), info);
                    } else {
                        List<Object> list = new ArrayList<>();
                        list.add(savedIcon);
                        info.setIconUrlList(list);
                        setIconUrls(list, info.getConversationId());
                    }
                }
            });
        } else {
            setIconUrls(info.getIconUrlList(), info.getConversationId());
        }
    }

    private void fillFaceUrlList(final String groupID, final ConversationInfo info) {
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                clearImage();
                presenter.getGroupMemberIconList(groupID, new IUIKitCallback<List<Object>>() {
                    @Override
                    public void onSuccess(List<Object> data) {
                        info.setIconUrlList(data);
                        setIconUrls(data, info.getConversationId());
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {

                    }
                });
            }
        });
    }

    public void setRadius(int radius) {
        if (mIconView instanceof SynthesizedImageView) {
            ((SynthesizedImageView) (mIconView)).setRadius(radius);
        }
    }

    public void setDefaultImageResId(int resId) {
        BitmapDrawable bd = (BitmapDrawable) getContext().getResources().getDrawable(resId);
        mIconView.setImageBitmap(bd.getBitmap());
    }

    public void setBitmapResId(int resId) {
        BitmapDrawable bd = (BitmapDrawable) getContext().getResources().getDrawable(resId);
        Bitmap bitmap = ImageUtil.toRoundBitmap(bd.getBitmap());
        mIconView.setImageBitmap(bitmap);
    }

    public void clearImage() {
        if (mIconView instanceof SynthesizedImageView) {
            ((SynthesizedImageView) mIconView).clear();
        }
    }
}

