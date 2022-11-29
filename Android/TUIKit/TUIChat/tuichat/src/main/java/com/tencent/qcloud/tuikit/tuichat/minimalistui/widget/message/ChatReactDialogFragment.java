package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.app.Dialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Pair;
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
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.tuichat.bean.ReactUserBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.presenter.ReactPresenter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ChatReactDialogFragment extends DialogFragment {

    private BottomSheetDialog dialog;

    private TUIMessageBean messageBean;

    private RecyclerView reactCategoryList;

    private ViewPager2 reactViewPager;

    private ReactPresenter reactPresenter;

    private OnReactClickListener onReactClickListener;

    private ChatInfo chatInfo;

    private int selectedIndex = 0;

    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
    }

    public void setOnReactClickListener(OnReactClickListener onReactClickListener) {
        this.onReactClickListener = onReactClickListener;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        dialog = new BottomSheetDialog(getContext(), R.style.ChatPopActivityStyle);
        dialog.setCanceledOnTouchOutside(true);
        BottomSheetBehavior<FrameLayout> bottomSheetBehavior = dialog.getBehavior();
        bottomSheetBehavior.setFitToContents(false);
        bottomSheetBehavior.setHalfExpandedRatio(0.45f);
        bottomSheetBehavior.setSkipCollapsed(true);
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
        reactViewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                selectedIndex = position;
                reactCategoryList.getAdapter().notifyDataSetChanged();
                reactCategoryList.smoothScrollToPosition(position);
            }
        });
    }

    private void initData() {
        reactPresenter = new ReactPresenter();
        reactPresenter.setChatInfo(chatInfo);
        reactPresenter.setMessageId(messageBean.getId());
        reactPresenter.setChatEventListener();
        reactPresenter.setMessageListener(new ReactPresenter.OnMessageChangedListener() {
            @Override
            public void onMessageChanged(TUIMessageBean messageBean) {
                if (!isAdded()) {
                    return;
                }
                ChatReactDialogFragment.this.messageBean = messageBean;
                reactCategoryList.getAdapter().notifyDataSetChanged();
                reactViewPager.getAdapter().notifyDataSetChanged();
            }
        });
        reactCategoryList.setLayoutManager(new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
        reactCategoryList.setAdapter(new ReactCategoryAdapter());
        reactViewPager.setAdapter(new ReactDetailAdapter());
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
            List<Pair<String, String>> data = new ArrayList<>();
                MessageReactBean reactBean = messageBean.getMessageReactBean();
                Map<String, Set<String>> reacts = reactBean.getReacts();
            if (position == 0) {
                for (String emojiKey : reacts.keySet()) {
                    Set<String> userSet = reacts.get(emojiKey);
                    if (userSet != null) {
                        for (String userID : userSet) {
                            data.add(new Pair<>(userID, emojiKey));
                        }
                    }
                }
            } else {
                List<String> emojiKeys = new ArrayList<>(reacts.keySet());
                String emojiKey = emojiKeys.get(position - 1);
                Set<String> userSet = reacts.get(emojiKey);
                if (userSet != null) {
                    for (String userID : userSet) {
                        data.add(new Pair<>(userID, emojiKey));
                    }
                }
            }
            adapter.setData(data);
            adapter.notifyDataSetChanged();
        }

        @Override
        public int getItemCount() {
            if (messageBean == null) {
                return 0;
            } else {
                MessageReactBean reactBean = messageBean.getMessageReactBean();
                if (reactBean == null) {
                    return 0;
                } else {
                    return reactBean.getReactSize() + 1;
                }
            }
        }

        class ReactDetailHolder extends RecyclerView.ViewHolder {
            private RecyclerView recyclerView;

            public ReactDetailHolder(@NonNull View itemView) {
                super(itemView);
                recyclerView = itemView.findViewById(R.id.react_user_list);
            }
        }
    }

    class ReactUserAdapter extends RecyclerView.Adapter<ReactUserAdapter.ReactUserViewHolder> {

        private List<Pair<String, String>> data;

        public void setData(List<Pair<String, String>> data) {
            this.data = data;
        }

        @NonNull
        @Override
        public ReactUserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.minimalist_react_details_layout, parent, false);
            return new ReactUserViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ReactUserViewHolder holder, int position) {
            Pair<String, String> pair = data.get(position);
            Map<String, ReactUserBean> userBeanMap = messageBean.getMessageReactBean().getReactUserBeanMap();
            ReactUserBean reactUserBean = userBeanMap.get(pair.first);
            GlideEngine.loadImage(holder.userFace, reactUserBean.getFaceUrl());
            if (pair.second != null) {
                GlideEngine.loadImage(holder.emojiIcon, FaceManager.getEmoji(pair.second));
            }
            holder.userName.setText(reactUserBean.getDisplayString());
            if (TextUtils.equals(pair.first, TUILogin.getLoginUser())) {
                holder.tips.setText(getResources().getString(R.string.chat_tap_to_remove));
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (onReactClickListener != null) {
                            onReactClickListener.onClick(reactUserBean.getUserId(), pair.second);
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
            if (data != null) {
                return data.size();
            }
            return 0;
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
            if (selectedIndex == position) {
                holder.itemView.setBackgroundResource(R.drawable.chat_gray_round_rect_bg);
            } else {
                holder.itemView.setBackground(null);
            }
            if (position == 0) {
                holder.categoryName.setText("All");
                Map<String, Set<String>> reactsMap = messageBean.getMessageReactBean().getReacts();
                int num = 0;
                for (Set<String> strings : reactsMap.values()) {
                    num += strings.size();
                }
                holder.reactNum.setText(num + "");
                holder.reactImg.setVisibility(View.GONE);
            } else {
                Map<String, Set<String>> reactsMap = messageBean.getMessageReactBean().getReacts();
                List<String> reactKeys = new ArrayList<>(reactsMap.keySet());
                holder.reactImg.setImageBitmap(FaceManager.getEmoji(reactKeys.get(position - 1)));
                Set<String> users = reactsMap.get(reactKeys.get(position - 1));
                holder.reactNum.setText(users.size() + "");
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    reactViewPager.setCurrentItem(position);
                }
            });
        }

        @Override
        public int getItemCount() {
            if (messageBean == null) {
                return 0;
            } else {
                MessageReactBean reactBean = messageBean.getMessageReactBean();
                if (reactBean == null) {
                    return 0;
                } else {
                    return reactBean.getReactSize() + 1;
                }
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
        void onClick(String userID, String emojiKey);
    }

}
