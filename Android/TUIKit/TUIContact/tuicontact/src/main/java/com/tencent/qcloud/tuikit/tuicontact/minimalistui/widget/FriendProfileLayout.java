package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistTitleBar;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IFriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FriendProfileLayout extends LinearLayout implements View.OnClickListener, IFriendProfileLayout {
    private static final String TAG = FriendProfileLayout.class.getSimpleName();

    private MinimalistTitleBar mTitleBar;
    private ShadeImageView mHeadImageView;
    private TextView mNickNameView;
    private MinimalistLineControllerView mRemarkView;
    private MinimalistLineControllerView mAddBlackView;
    private MinimalistLineControllerView mChatTopView;
    private MinimalistLineControllerView mMessageOptionView;
    private MinimalistLineControllerView mChatBackground;
    private MinimalistLineControllerView deleteFriendBtn;
    private MinimalistLineControllerView clearMessageBtn;
    private TextView friendIDTv;

    private RecyclerView profileItemListView;
    private ProfileItemAdapter profileItemAdapter;
    private ContactItemBean mContactInfo;
    private FriendApplicationBean friendApplicationBean;
    private OnButtonClickListener mListener;
    private String mId;
    private String mNickname;
    private boolean isFriend;
    private boolean isGroup = false;

    private FriendProfilePresenter presenter;

    public FriendProfileLayout(Context context) {
        super(context);
        init();
    }

    public FriendProfileLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public FriendProfileLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(FriendProfilePresenter presenter) {
        this.presenter = presenter;
    }

    private void init() {
        inflate(getContext(), R.layout.minimalist_contact_friend_profile_layout, this);

        mHeadImageView = findViewById(R.id.friend_icon);
        mNickNameView = findViewById(R.id.friend_nick_name);
        friendIDTv = findViewById(R.id.friend_account);
        mRemarkView = findViewById(R.id.remark);
        mRemarkView.setOnClickListener(this);
        mMessageOptionView = findViewById(R.id.msg_rev_opt);
        mMessageOptionView.setOnClickListener(this);
        mChatTopView = findViewById(R.id.chat_to_top);
        mAddBlackView = findViewById(R.id.blackList);
        deleteFriendBtn = findViewById(R.id.btn_delete);
        deleteFriendBtn.setOnClickListener(this);
        deleteFriendBtn.setNameColor(0xFFFF584C);
        clearMessageBtn = findViewById(R.id.clear_chat_history);
        clearMessageBtn.setOnClickListener(this);
        clearMessageBtn.setNameColor(0xFFFF584C);
        mChatBackground = findViewById(R.id.chat_background);
        mChatBackground.setOnClickListener(this);

        profileItemListView = findViewById(R.id.profile_item_container);

        mTitleBar = findViewById(R.id.friend_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);

        mRemarkView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mAddBlackView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mChatTopView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mMessageOptionView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mChatBackground.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        deleteFriendBtn.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        clearMessageBtn.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));

        profileItemAdapter = new ProfileItemAdapter();
        profileItemListView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        int leftRightSpace = ScreenUtil.dip2px(24);
        profileItemListView.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                int position = parent.getChildAdapterPosition(view);
                int column = position % 3;
                outRect.left = column * leftRightSpace / 3;
                outRect.right = leftRightSpace * (2 - column) / 3;
            }
        });
        profileItemListView.setAdapter(profileItemAdapter);
    }

    private void setupExtension() {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIContact.Extension.FriendProfileItem.USER_ID, mId);
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIContact.Extension.FriendProfileItem.MINIMALIST_EXTENSION_ID, param);
        Collections.sort(extensionInfoList);
        profileItemAdapter.setExtensionInfoList(extensionInfoList);
        profileItemAdapter.notifyDataSetChanged();
    }

    private void initEvent() {
        mChatTopView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                if (presenter != null) {
                    presenter.setConversationTop(mId, isChecked);
                }
            }
        });

        mAddBlackView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    addBlack();
                } else {
                    deleteBlack();
                }
            }
        });
    }

    public void initData(Object data) {
        initEvent();

        if (data instanceof String) {
            mId = (String) data;
            friendIDTv.setText(mId);
            loadUserProfile(mId);
        } else if (data instanceof ContactItemBean) {
            setViewContentFromItemBean((ContactItemBean) data);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }

        setupExtension();
    }

    private void setViewContentFromItemBean(ContactItemBean data) {
        mContactInfo = data;
        isFriend = mContactInfo.isFriend();
        mId = mContactInfo.getId();
        mNickname = mContactInfo.getNickName();
        int radius = getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(mHeadImageView, mContactInfo.getAvatarUrl(), radius);
        mChatTopView.setChecked(presenter.isTopConversation(mId));
        mAddBlackView.setChecked(mContactInfo.isBlackList());
        mRemarkView.setContent(mContactInfo.getRemark());
        if (isFriend) {
            deleteFriendBtn.setVisibility(VISIBLE);
        }
        if (TextUtils.equals(mContactInfo.getId(), TUILogin.getLoginUser())) {
            if (isFriend) {
                mRemarkView.setVisibility(VISIBLE);
                profileItemListView.setVisibility(VISIBLE);
                mAddBlackView.setVisibility(VISIBLE);
                mChatTopView.setVisibility(View.VISIBLE);
                mChatBackground.setVisibility(VISIBLE);
                updateMessageOptionView();
            }
        } else {
            if (mContactInfo.isBlackList()) {
                profileItemListView.setVisibility(VISIBLE);
                mRemarkView.setVisibility(VISIBLE);
                mAddBlackView.setVisibility(VISIBLE);
                mMessageOptionView.setVisibility(VISIBLE);
                mChatTopView.setVisibility(VISIBLE);
                mChatBackground.setVisibility(VISIBLE);
            } else {
                mRemarkView.setVisibility(VISIBLE);
                profileItemListView.setVisibility(VISIBLE);
                mAddBlackView.setVisibility(VISIBLE);
                mChatTopView.setVisibility(View.VISIBLE);
                mChatBackground.setVisibility(VISIBLE);
                updateMessageOptionView();
            }
        }
    }

    private void updateMessageOptionView() {
        mMessageOptionView.setVisibility(VISIBLE);
        // get
        final ArrayList<String> userIdList = new ArrayList<>();
        userIdList.add(mId);

        presenter.getC2CReceiveMessageOpt(userIdList, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                mMessageOptionView.setChecked(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mMessageOptionView.setChecked(false);
            }
        });

        // set
        mMessageOptionView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                presenter.setC2CReceiveMessageOpt(userIdList, isChecked);
            }
        });
    }

    @Override
    public void onDataSourceChanged(ContactItemBean bean) {
        setViewContentFromItemBean(bean);
        setupExtension();
        if (bean.isFriend()) {
            updateMessageOptionView();
            clearMessageBtn.setVisibility(VISIBLE);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }

        if (!TextUtils.isEmpty(bean.getAvatarUrl())) {
            int radius = getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
            GlideEngine.loadUserIcon(mHeadImageView, bean.getAvatarUrl(), radius);
        }
    }

    private void loadUserProfile(String id) {
        final ContactItemBean bean = new ContactItemBean();
        presenter.getUsersInfo(id, bean);
    }

    private void delete() {
        List<String> identifiers = new ArrayList<>();
        identifiers.add(mId);

        presenter.deleteFriend(identifiers, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                if (mListener != null) {
                    mListener.onDeleteFriendClick(mId);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("deleteFriend Error code = " + errCode + ", desc = " + errMsg);
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v == deleteFriendBtn) {
            new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.contact_delete_friend_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            delete();
                        }
                    })
                .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {}
                    })
                .show();
        } else if (v == clearMessageBtn) {
            new TUIKitDialog(getContext())
                .builder()
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(getContext().getString(R.string.clear_msg_tip))
                .setDialogWidth(0.75f)
                .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Map<String, Object> hashMap = new HashMap<>();
                            hashMap.put(TUIConstants.TUIContact.FRIEND_ID, mId);
                            TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_USER, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE, hashMap);
                        }
                    })
                .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel),
                    new OnClickListener() {
                        @Override
                        public void onClick(View v) {}
                    })
                .show();
        } else if (v == mRemarkView) {
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mRemarkView.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.profile_remark_edit));
            String description = getResources().getString(R.string.contact_modify_remark_rule);
            popupInputCard.setRule("^[a-zA-Z0-9_一-龥]*$");
            popupInputCard.setDescription(description);
            popupInputCard.setOnPositive((result -> {
                mRemarkView.setContent(result);
                if (TextUtils.isEmpty(result)) {
                    result = "";
                }
                modifyRemark(result);
            }));
            popupInputCard.show(mRemarkView, Gravity.BOTTOM);

        } else if (v == mChatBackground) {
            if (mListener != null) {
                mListener.onSetChatBackground();
            }
        }
    }

    private void modifyRemark(final String txt) {
        presenter.modifyRemark(mId, txt, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                mContactInfo.setRemark(txt);
                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.FRIEND_ID, mId);
                param.put(TUIConstants.TUIContact.FRIEND_REMARK, txt);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    private void addBlack() {
        String[] idStringList = mId.split(",");
        List<String> idList = new ArrayList<>(Arrays.asList(idStringList));
        presenter.addToBlackList(idList);
    }

    private void deleteBlack() {
        String[] idStringList = mId.split(",");
        List<String> idList = new ArrayList<>(Arrays.asList(idStringList));
        presenter.deleteFromBlackList(idList);
    }

    class ProfileItemAdapter extends RecyclerView.Adapter<ProfileItemAdapter.ItemViewHolder> {
        List<TUIExtensionInfo> extensionInfoList;

        public void setExtensionInfoList(List<TUIExtensionInfo> extensionInfoList) {
            this.extensionInfoList = extensionInfoList;
        }

        @NonNull
        @Override
        public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View itemView = LayoutInflater.from(getContext()).inflate(R.layout.contact_minimalist_friend_profile_item_layout, null);
            return new ItemViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull ItemViewHolder holder, int position) {
            TUIExtensionInfo extensionInfo = extensionInfoList.get(position);
            holder.imageView.setBackgroundResource((Integer) extensionInfo.getIcon());
            holder.textView.setText(extensionInfo.getText());
            TUIExtensionEventListener eventListener = extensionInfo.getExtensionListener();
            holder.itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (eventListener != null) {
                        eventListener.onClicked(null);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (extensionInfoList == null) {
                return 0;
            }
            return extensionInfoList.size();
        }

        class ItemViewHolder extends RecyclerView.ViewHolder {
            public ImageView imageView;
            public TextView textView;

            public ItemViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.item_image);
                textView = itemView.findViewById(R.id.item_text);
            }
        }
    }

    public void setOnButtonClickListener(OnButtonClickListener l) {
        mListener = l;
    }

    public interface OnButtonClickListener {
        void onStartConversationClick(ContactItemBean info);

        void onDeleteFriendClick(String id);

        default void onSetChatBackground(){}
    }
}
