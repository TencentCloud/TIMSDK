package com.tencent.qcloud.tim.uikit.modules.conversation.base;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.gatherimage.SynthesizedImageView;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;
import com.tencent.qcloud.tim.uikit.utils.ImageUtil;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ThreadHelper;

import java.util.ArrayList;
import java.util.List;

/**
 * 会话列表头像View
 */
public class ConversationIconView extends RelativeLayout {

    private static final int icon_size = ScreenUtil.getPxByDp(50);
    private ImageView mIconView;


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


    public void invokeInformation(ConversationInfo conversationInfo, DynamicConversationIconView infoView) {
        infoView.setLayout(this);
        infoView.setMainViewId(R.id.profile_icon_group);
        infoView.parseInformation(conversationInfo);
    }

    private void init() {
        inflate(getContext(), R.layout.profile_icon_view, this);
        mIconView = findViewById(R.id.profile_icon);
        ((SynthesizedImageView) mIconView).defaultImage(0);
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
                    final String savedIcon = ConversationManagerKit.getInstance().getGroupConversationAvatar(info.getConversationId());
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
        clearImage();
        V2TIMManager.getGroupManager().getGroupMemberList(groupID, V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL, 0, new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e("ConversationIconView", "getGroupMemberList failed! groupID:" + groupID + "|code:" + code + "|desc: " + desc);
            }

            @Override
            public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                List<V2TIMGroupMemberFullInfo> v2TIMGroupMemberFullInfoList = v2TIMGroupMemberInfoResult.getMemberInfoList();
                int faceSize = v2TIMGroupMemberFullInfoList.size() > 9 ? 9 : v2TIMGroupMemberFullInfoList.size();
                final List<Object> urlList = new ArrayList<>();
                for (int i = 0; i < faceSize; i++) {
                    V2TIMGroupMemberFullInfo v2TIMGroupMemberFullInfo = v2TIMGroupMemberFullInfoList.get(i);
                    if (TextUtils.isEmpty(v2TIMGroupMemberFullInfo.getFaceUrl())) {
                        urlList.add(R.drawable.default_user_icon);
                    } else {
                        urlList.add(v2TIMGroupMemberFullInfo.getFaceUrl());
                    }
                }
                info.setIconUrlList(urlList);
                setIconUrls(urlList, info.getConversationId());
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

