package com.tencent.qcloud.tuikit.tuiemojiplugin.common.widget;

import android.app.Dialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiemojiplugin.R;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionUserBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.TUIEmojiPresenter;
import com.tencent.qcloud.tuikit.tuiemojiplugin.util.TUIEmojiLog;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class ChatReactDialogFragment extends DialogFragment {
    private static final String TAG = "ChatReactDialogFragment";
    private BottomSheetDialog dialog;

    private TUIMessageBean messageBean;
    private MessageReactionBean messageReactionBean;
    private String currentReactionID;

    private RecyclerView reactCategoryList;

    private ViewPager2 reactViewPager;

    private TUIEmojiPresenter reactPresenter;

    private OnReactClickListener onReactClickListener;

    private ChatInfo chatInfo;

    private ReactCategoryAdapter categoryAdapter;
    private ReactDetailAdapter detailAdapter;

    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }

    public void setOnReactClickListener(OnReactClickListener onReactClickListener) {
        this.onReactClickListener = onReactClickListener;
    }

    public void setCurrentReactionID(String currentReactionID) {
        this.currentReactionID = currentReactionID;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        dialog = new BottomSheetDialog(getContext(), R.style.TUIEmojiTranslucentBgStyle);
        dialog.setCanceledOnTouchOutside(true);
        BottomSheetBehavior<FrameLayout> bottomSheetBehavior = dialog.getBehavior();
        bottomSheetBehavior.setFitToContents(false);
        bottomSheetBehavior.setHalfExpandedRatio(0.45f);
        bottomSheetBehavior.setSkipCollapsed(false);
        bottomSheetBehavior.setExpandedOffset(ScreenUtil.dip2px(36));
        bottomSheetBehavior.setState(BottomSheetBehavior.STATE_HALF_EXPANDED);
        return dialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.chat_react_dialog_layout, container);
        reactViewPager = view.findViewById(R.id.react_view_pager);
        reactCategoryList = view.findViewById(R.id.react_category_list);
        initView();
        initData();
        return view;
    }

    private void initView() {
        reactViewPager.setUserInputEnabled(false);
        reactViewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                categoryAdapter.notifyDataSetChanged();
                reactCategoryList.smoothScrollToPosition(position);
            }
        });
    }

    private void initData() {
        reactPresenter = new TUIEmojiPresenter();
        reactCategoryList.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        categoryAdapter = new ReactCategoryAdapter();
        reactCategoryList.setAdapter(categoryAdapter);
        detailAdapter = new ReactDetailAdapter();
        reactViewPager.setAdapter(detailAdapter);

        setOnReactClickListener(new OnReactClickListener() {
            @Override
            public void onClick(String reactionID) {
                reactPresenter.removeMessageReaction(messageBean, reactionID, new TUICallback() {
                    @Override
                    public void onSuccess() {
                        TUIEmojiLog.i(TAG, "remove success");
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        TUIEmojiLog.i(TAG, "remove reaction failed, code=" + errorCode + ", msg=" + errorMessage);
                    }
                });
                dismiss();
            }
        });

        reactPresenter.getMessageReactions(Collections.singletonList(messageBean), 1, new TUIValueCallback<List<MessageReactionBean>>() {
            @Override
            public void onSuccess(List<MessageReactionBean> object) {
                if (!object.isEmpty()) {
                    messageReactionBean = object.get(0);
                    if (TextUtils.isEmpty(currentReactionID)) {
                        currentReactionID = getReactionID(0);
                    }
                    categoryAdapter.notifyDataSetChanged();
                    detailAdapter.notifyDataSetChanged();
                    onReactionSelected(currentReactionID);
                } else {
                    TUIEmojiLog.e(TAG, "getMessageReactions failed, message reaction list is empty");
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIEmojiLog.e(TAG, "getMessageReactions failed, code=" + errorCode + ",msg=" + errorMessage);
            }
        });
    }

    private void onReactionSelected(String reactionID) {
        currentReactionID = reactionID;
        int index = getReactionIDIndex();
        reactViewPager.setCurrentItem(index);
    }

    private int getReactionIDIndex() {
        if (messageReactionBean == null || messageReactionBean.getReactionCount() <= 0) {
            return 0;
        }
        return new ArrayList<>(messageReactionBean.getMessageReactionBeanMap().keySet()).indexOf(currentReactionID);
    }

    private String getReactionID(int index) {
        if (messageReactionBean == null || messageReactionBean.getReactionCount() <= 0) {
            return "";
        }
        return new ArrayList<>(messageReactionBean.getMessageReactionBeanMap().keySet()).get(index);
    }

    class ReactDetailAdapter extends RecyclerView.Adapter<ReactDetailAdapter.ReactDetailHolder> {
        @NonNull
        @Override
        public ReactDetailHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.minimalist_react_view_pager_layout, parent, false);
            ReactDetailHolder holder = new ReactDetailHolder(view);
            holder.recyclerView.setLayoutManager(new LinearLayoutManager(parent.getContext()));
            holder.recyclerView.setAdapter(new ReactUserAdapter());
            return holder;
        }

        @Override
        public void onBindViewHolder(@NonNull ReactDetailHolder holder, int position) {
            ReactUserAdapter adapter = (ReactUserAdapter) holder.recyclerView.getAdapter();
            String reactionID = getReactionID(position);
            adapter.reactionID = reactionID;
            reactPresenter.getAllUserListOfMessageReaction(messageBean, reactionID, 0, 100, new TUIValueCallback<MessageReactionUserBean>() {
                @Override
                public void onSuccess(MessageReactionUserBean object) {
                    if (TextUtils.equals(reactionID, adapter.reactionID)) {
                        adapter.messageReactionUserBean = object;
                        adapter.notifyDataSetChanged();
                    }
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    TUIEmojiLog.e(TAG, "getAllUserListOfMessageReaction failed, code=" + errorCode + ", msg=" + errorMessage);
                }
            });
        }

        @Override
        public int getItemCount() {
            if (messageReactionBean == null) {
                return 0;
            } else {
                return messageReactionBean.getReactionCount();
            }
        }

        class ReactDetailHolder extends RecyclerView.ViewHolder {
            private RecyclerView recyclerView;
            private String reactionID;

            public ReactDetailHolder(@NonNull View itemView) {
                super(itemView);
                recyclerView = itemView.findViewById(R.id.react_user_list);
            }
        }
    }

    class ReactUserAdapter extends RecyclerView.Adapter<ReactUserAdapter.ReactUserViewHolder> {
        private MessageReactionUserBean messageReactionUserBean;
        private String reactionID;


        @NonNull
        @Override
        public ReactUserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.minimalist_react_details_layout, parent, false);
            return new ReactUserViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ReactUserViewHolder holder, int position) {
            UserBean reactUserBean = messageReactionUserBean.getUserBeanList().get(position);
            GlideEngine.loadImage(holder.userFace, reactUserBean.getFaceUrl());
            holder.userName.setText(reactUserBean.getDisplayString());
            if (TextUtils.equals(reactUserBean.getUserId(), TUILogin.getLoginUser())) {
                holder.tips.setText(getResources().getString(R.string.chat_tap_to_remove));
                holder.tips.setVisibility(View.VISIBLE);
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onReactClickListener != null) {
                            onReactClickListener.onClick(reactionID);
                        }
                    }
                });
            } else {
                holder.tips.setVisibility(View.GONE);
                holder.itemView.setOnClickListener(null);
            }
        }

        @Override
        public int getItemCount() {
            if (messageReactionUserBean == null || messageReactionUserBean.getUserBeanList() == null) {
                return 0;
            } else {
                return messageReactionUserBean.getUserBeanList().size();
            }
        }

        class ReactUserViewHolder extends RecyclerView.ViewHolder {
            private ImageView userFace;
            private ImageView emojiIcon;
            private TextView userName;
            private TextView tips;

            public ReactUserViewHolder(@NonNull View itemView) {
                super(itemView);
                userFace = itemView.findViewById(R.id.user_face);
                emojiIcon = itemView.findViewById(R.id.emoji_icon);
                userName = itemView.findViewById(R.id.user_name);
                tips = itemView.findViewById(R.id.tips);
            }
        }
    }

    class ReactCategoryAdapter extends RecyclerView.Adapter<ReactCategoryAdapter.ReactCategoryHolder> {

        @NonNull
        @Override
        public ReactCategoryHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.minimalist_react_category_layout, parent, false);
            return new ReactCategoryHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ReactCategoryHolder holder, int position) {
            Map<String, ReactionBean> reactionBeanMap = messageReactionBean.getMessageReactionBeanMap();
            String reactionID = new ArrayList<>(reactionBeanMap.keySet()).get(position);
            if (TextUtils.equals(currentReactionID, reactionID)) {
                holder.itemView.setBackgroundResource(R.drawable.tuiemoji_gray_round_rect_bg);
            } else {
                holder.itemView.setBackground(null);
            }
            holder.reactImg.setImageBitmap(FaceManager.getEmoji(reactionID));
            ReactionBean reactionBean = reactionBeanMap.get(reactionID);
            holder.reactNum.setText(reactionBean.getTotalUserCount() + "");

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onReactionSelected(reactionID);
                }
            });
        }

        @Override
        public int getItemCount() {
            if (messageReactionBean == null) {
                return 0;
            } else {
                return messageReactionBean.getReactionCount();
            }
        }

        class ReactCategoryHolder extends RecyclerView.ViewHolder {
            private TextView categoryName;
            private ImageView reactImg;
            private TextView reactNum;

            public ReactCategoryHolder(@NonNull View itemView) {
                super(itemView);
                categoryName = itemView.findViewById(R.id.category_name);
                reactNum = itemView.findViewById(R.id.react_num);
                reactImg = itemView.findViewById(R.id.react_img);
            }
        }
    }

    interface OnReactClickListener {
        void onClick(String reactionID);
    }
}
