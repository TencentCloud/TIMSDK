package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TreeNode;
import com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard.BottomPopupCard;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.ITopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.TopicPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityDetailView;
import com.tencent.qcloud.tuikit.tuicommunity.ui.view.popupview.CommunityMorePopupView;

import java.util.ArrayList;
import java.util.List;

public class CommunityDetailView extends FrameLayout implements ICommunityDetailView {
    private CommunityBean communityBean;
    private CommunityTopicList communityTopicList;
    private ImageView coverImage;
    private TextView communityNameTv;
    private ImageView shareIcon;
    private ImageView moreIcon;

    private TopicPresenter topicPresenter;
    private CommunityPresenter communityPresenter;
    private CommunityMorePopupView communityMorePopupView;

    public CommunityDetailView(@NonNull Context context) {
        super(context);
        init();
    }

    public CommunityDetailView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CommunityDetailView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public CommunityDetailView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        topicPresenter = new TopicPresenter();
        communityPresenter = new CommunityPresenter();

        View view = LayoutInflater.from(getContext()).inflate(R.layout.community_detail_layout, this);
        coverImage = view.findViewById(R.id.cover_image);
        communityNameTv = view.findViewById(R.id.community_name);
        communityTopicList = view.findViewById(R.id.community_topic_list);
        communityTopicList.setPresenter(topicPresenter);
        shareIcon = view.findViewById(R.id.share_icon);
        moreIcon = view.findViewById(R.id.more_icon);

        topicPresenter.setCommunityTopicList(communityTopicList);
        communityPresenter.setCommunityDetailView(this);
        communityPresenter.setCommunityEventListener();
        topicPresenter.setCommunityEventListener();
    }

    private void initEvent() {
        communityTopicList.setOnTopicClickListener(new OnTopicClickListener() {
            @Override
            public void onClick(TopicBean topicBean) {
                Bundle bundle = new Bundle();
                bundle.putString(TUIConstants.TUIChat.CHAT_ID, topicBean.getID());
                bundle.putString(TUIConstants.TUIChat.CHAT_NAME, topicBean.getTopicName());
                bundle.putInt(TUIConstants.TUIChat.CHAT_TYPE, TopicBean.CHAT_TYPE_GROUP);
                TUICore.startActivity(TUIConstants.TUIChat.GROUP_CHAT_ACTIVITY_NAME, bundle);
            }

            @Override
            public void onCategoryLongClick(View view, TreeNode<ITopicBean> node) {
                if (communityBean.isOwner()) {
                    showCategoryConfigPopup(view, node);
                }
            }
        });

        GlideEngine.loadImageSetDefault(coverImage, communityBean.getCoverUrl(), R.drawable.community_cover_default);
        communityNameTv.setText(communityBean.getCommunityName());

        shareIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showSharePopup();
            }
        });

        moreIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showMorePopup();
            }
        });

        coverImage.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                showMorePopup();
            }
        });

        topicPresenter.getTopicList(communityBean.getGroupId());
    }

    private void showCategoryConfigPopup(View view, TreeNode<ITopicBean> node) {
        Drawable drawable = view.getBackground();
        if (drawable != null) {
            drawable.setColorFilter(0xd9d9d9, PorterDuff.Mode.SRC_IN);
        }
        View itemPop = LayoutInflater.from(getContext()).inflate(R.layout.community_member_list_delete_popup_layout, null);
        PopupWindow popupWindow = new PopupWindow(itemPop, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setOutsideTouchable(true);
        popupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                if (drawable != null) {
                    drawable.clearColorFilter();
                }
            }
        });

        TextView popText = itemPop.findViewById(R.id.pop_text);
        popText.setText(R.string.community_delete_topic_category);
        popText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                new TUIKitDialog(getContext()).builder()
                        .setTitle(getResources().getString(R.string.community_delete_topic_category))
                        .setPositiveButton(new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                communityPresenter.deleteCategory(communityBean.getGroupId(), node.getNodeName());
                                topicPresenter.deleteCategory(node);
                            }
                        })
                        .setNegativeButton(new OnClickListener() {
                            @Override
                            public void onClick(View v) {}
                        })
                        .show();
                popupWindow.dismiss();
            }
        });
        int x = view.getWidth() / 2;
        int y = -view.getHeight() / 3;
        int popHeight = ScreenUtil.dip2px(45) * 3;
        if (y + popHeight + view.getY() + view.getHeight() > communityTopicList.getBottom()) {
            y = y - popHeight;
        }
        popupWindow.showAsDropDown(view, x, y);
    }

    public void hideTopicList() {
        communityTopicList.setVisibility(GONE);
    }

    public void setCommunityBean(CommunityBean communityBean) {
        if (this.communityBean == communityBean) {
            communityTopicList.setVisibility(VISIBLE);
            return;
        }
        this.communityBean = communityBean;
        topicPresenter.setCommunityBean(communityBean);
        communityPresenter.setCurrentCommunityBean(communityBean);

        initEvent();
    }

    private void showMorePopup() {
        if (communityMorePopupView != null && communityMorePopupView.isShown()) {
            return;
        }
        communityMorePopupView = new CommunityMorePopupView(getContext());
        communityMorePopupView.setCommunityBean(communityBean);
        BottomPopupCard bottomPopupCard = new BottomPopupCard((Activity) getContext(), communityMorePopupView);
        bottomPopupCard.show(this);

    }

    private void showSharePopup() {
        ToastUtil.toastShortMessage(getResources().getString(R.string.community_coming_soon));
    }

    @Override
    public void onCommunityChanged(CommunityBean communityBean) {
        this.communityBean = communityBean;
        topicPresenter.setCommunityBean(communityBean);
        communityPresenter.setCurrentCommunityBean(communityBean);
        communityNameTv.setText(communityBean.getCommunityName());
        GlideEngine.loadImageSetDefault(coverImage, communityBean.getCoverUrl(), R.drawable.community_cover_default);
    }

    public interface OnTopicClickListener {
        void onClick(TopicBean topicBean);
        void onCategoryLongClick(View view, TreeNode<ITopicBean> node);
    }
}
