package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Pair;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IAddMoreActivity;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.ContactToast;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;

public class AddMoreDetailMinimalistDialogFragment extends DialogFragment implements IAddMoreActivity {
    private BottomSheetDialog dialog;

    private View detailArea;

    private ShadeImageView faceImgView;
    private TextView idTextView;
    private TextView groupTypeView;
    private TextView groupTypeTagView;
    private TextView nickNameView;
    private TextView cancelButton;

    private EditText validationEdit;
    private View validationArea;
    private View remarksArea;
    private MinimalistLineControllerView remarkController;
    private MinimalistLineControllerView groupController;
    private TextView sendButton;

    private TUICallback addMoreCallback;
    private Object data;
    private FriendProfilePresenter presenter;

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        dialog = new BottomSheetDialog(getContext(), R.style.ContactPopActivityStyle);
        dialog.setCanceledOnTouchOutside(true);
        BottomSheetBehavior<FrameLayout> bottomSheetBehavior = dialog.getBehavior();
        bottomSheetBehavior.setFitToContents(false);
        bottomSheetBehavior.setSkipCollapsed(true);
        bottomSheetBehavior.setExpandedOffset(ScreenUtil.dip2px(24));
        bottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        return dialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.contact_minimalist_add_friend_group_detail_layout, container);
        presenter = new FriendProfilePresenter();

        faceImgView = view.findViewById(R.id.friend_icon);
        idTextView = view.findViewById(R.id.friend_account);
        groupTypeView = view.findViewById(R.id.group_type);
        nickNameView = view.findViewById(R.id.friend_nick_name);
        groupTypeTagView = view.findViewById(R.id.group_type_tag);
        validationEdit = view.findViewById(R.id.validation_message_input);
        validationArea = view.findViewById(R.id.validation_message_area);
        sendButton = view.findViewById(R.id.send_button);
        cancelButton = view.findViewById(R.id.cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        detailArea = view.findViewById(R.id.friend_detail_area);

        remarksArea = view.findViewById(R.id.remark_area);
        remarkController = view.findViewById(R.id.remarks_controller);
        groupController = view.findViewById(R.id.group_controller);

        remarkController.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
                popupInputCard.setContent(remarkController.getContent());
                popupInputCard.setTitle(getResources().getString(R.string.profile_remark_edit));
                String description = getResources().getString(R.string.contact_modify_remark_rule);
                popupInputCard.setDescription(description);
                popupInputCard.setOnPositive((result -> {
                    remarkController.setContent(result);
                }));
                popupInputCard.show(remarkController, Gravity.BOTTOM);
            }
        });

        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String addWording = validationEdit.getText().toString();
                if (data instanceof GroupInfo) {
                    presenter.joinGroup(((GroupInfo) data).getId(), addWording, new IUIKitCallback<Void>() {
                        @Override
                        public void onSuccess(Void data) {
                            ToastUtil.toastShortMessage(getContext().getString(R.string.success));
                            dismiss();
                            TUICallback.onSuccess(addMoreCallback);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ToastUtil.toastShortMessage(getContext().getString(R.string.contact_add_failed) + " " + errMsg);
                            TUICallback.onError(addMoreCallback, errCode, errMsg);
                        }
                    });
                } else if (data instanceof ContactItemBean) {
                    String remark = remarkController.getContent();
                    String friendGroup = groupController.getContent();
                    presenter.addFriend(((ContactItemBean) data).getId(), addWording, friendGroup, remark, new IUIKitCallback<Pair<Integer, String>>() {
                        @Override
                        public void onSuccess(Pair<Integer, String> data) {
                            int toastIconType = ContactToast.TOAST_ICON_NEGATIVE;
                            if (data.first == FriendApplicationBean.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM
                                || data.first == FriendApplicationBean.ERR_SUCC) {
                                toastIconType = ContactToast.TOAST_ICON_POSITIVE;
                            }
                            ContactToast.showToast(getContext(), data.second, toastIconType);
                            dismiss();
                            TUICallback.onSuccess(addMoreCallback);
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            ContactToast.showToast(getContext(), getContext().getString(R.string.contact_add_failed), ContactToast.TOAST_ICON_NEGATIVE);
                            TUICallback.onError(addMoreCallback, errCode, errMsg);
                        }
                    });
                }
            }
        });
        if (data instanceof GroupInfo) {
            setGroupDetail((GroupInfo) data);
            remarksArea.setVisibility(View.GONE);
        } else if (data instanceof ContactItemBean) {
            setFriendDetail(((ContactItemBean) data).getAvatarUrl(), ((ContactItemBean) data).getId(), ((ContactItemBean) data).getNickName());
        }
        String nickName = TUIConfig.getSelfNickName();
        if (TextUtils.isEmpty(nickName)) {
            nickName = TUILogin.getLoginUser();
        }
        validationEdit.setText(getString(R.string.contact_add_friend_default_validation, nickName));
        return view;
    }

    private void setGroupDetail(GroupInfo groupInfo) {
        int radius = ScreenUtil.dip2px(35);
        GlideEngine.loadUserIcon(
            faceImgView, groupInfo.getFaceUrl(), TUIUtil.getDefaultGroupIconResIDByGroupType(getContext(), groupInfo.getGroupType()), radius);
        idTextView.setText(groupInfo.getId());
        nickNameView.setText(groupInfo.getGroupName());
        groupTypeTagView.setVisibility(View.VISIBLE);
        groupTypeView.setVisibility(View.VISIBLE);
        groupTypeView.setText(groupInfo.getGroupType());
        detailArea.setVisibility(View.VISIBLE);
    }

    private void setFriendDetail(String faceUrl, String id, String nickName) {
        int radius = ScreenUtil.dip2px(35);
        GlideEngine.loadUserIcon(faceImgView, faceUrl, radius);
        idTextView.setText(id);
        if (TextUtils.isEmpty(nickName)) {
            nickNameView.setText(id);
        } else {
            nickNameView.setText(nickName);
        }
        groupTypeTagView.setVisibility(View.GONE);
        groupTypeView.setVisibility(View.GONE);
        detailArea.setVisibility(View.VISIBLE);
    }

    public void setData(Object data) {
        this.data = data;
    }

    public void setAddMoreCallback(TUICallback addMoreCallback) {
        this.addMoreCallback = addMoreCallback;
    }

    @Override
    public void finish() {
        dismiss();
    }
}
