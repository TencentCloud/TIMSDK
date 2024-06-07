package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.DialogFragment;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IAddMoreActivity;
import com.tencent.qcloud.tuikit.tuicontact.presenter.AddMorePresenter;

public class AddMoreMinimalistDialogFragment extends DialogFragment implements IAddMoreActivity {
    private BottomSheetDialog dialog;

    private EditText searchEdit;
    private TextView idLabel;
    private View notFoundTip;
    private TextView searchBtn;
    private TextView titleTv;
    private View detailArea;

    private ShadeImageView faceImgView;
    private TextView idTextView;
    private TextView groupTypeView;
    private TextView groupTypeTagView;
    private TextView nickNameView;
    private TextView cancelButton;

    private boolean isGroup;

    private AddMorePresenter presenter;

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
        View view = inflater.inflate(R.layout.contact_minimalist_add_friend_group_layout, container);
        presenter = new AddMorePresenter();
        presenter.setAddMoreActivity(this);

        faceImgView = view.findViewById(R.id.friend_icon);
        titleTv = view.findViewById(R.id.title_tv);
        idTextView = view.findViewById(R.id.friend_account);
        groupTypeView = view.findViewById(R.id.group_type);
        nickNameView = view.findViewById(R.id.friend_nick_name);
        groupTypeTagView = view.findViewById(R.id.group_type_tag);

        searchEdit = view.findViewById(R.id.search_edit);
        if (isGroup) {
            searchEdit.setHint(R.string.hint_search_group_id);
            titleTv.setText(getString(R.string.add_group));
        }

        cancelButton = view.findViewById(R.id.cancel_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        idLabel = view.findViewById(R.id.id_label);
        notFoundTip = view.findViewById(R.id.not_found_tip);
        searchBtn = view.findViewById(R.id.search_button);
        detailArea = view.findViewById(R.id.friend_detail_area);
        searchBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                notFoundTip.setVisibility(View.GONE);
                String id = searchEdit.getText().toString();

                if (isGroup) {
                    presenter.getGroupInfo(id, new IUIKitCallback<GroupInfo>() {
                        @Override
                        public void onSuccess(GroupInfo data) {
                            setGroupDetail(data);
                            detailArea.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    AddMoreDetailMinimalistDialogFragment detailDialog = new AddMoreDetailMinimalistDialogFragment();
                                    detailDialog.setData(data);
                                    detailDialog.show(((AppCompatActivity) getContext()).getSupportFragmentManager(), "AddMoreDetail");
                                }
                            });
                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            setNotFound();
                        }
                    });
                    return;
                }

                presenter.getUserInfo(id, new TUIValueCallback<ContactItemBean>() {
                    @Override
                    public void onSuccess(ContactItemBean data) {
                        setFriendDetail(data.getAvatarUrl(), data.getId(), data.getNickName());
                        detailArea.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (data.isFriend()) {
                                    Intent intent = new Intent(TUIContactService.getAppContext(), FriendProfileMinimalistActivity.class);
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                    intent.putExtra(TUIConstants.TUIContact.USER_ID, data.getId());
                                    startActivity(intent);
                                } else {
                                    AddMoreDetailMinimalistDialogFragment detailDialog = new AddMoreDetailMinimalistDialogFragment();
                                    detailDialog.setData(data);
                                    detailDialog.show(((AppCompatActivity) getContext()).getSupportFragmentManager(), "AddMoreDetail");
                                }
                            }
                        });
                    }

                    @Override
                    public void onError(int errCode, String errMsg) {
                        setNotFound();
                    }
                });
            }
        });

        if (!isGroup) {
            idLabel.setText(getString(R.string.contact_my_user_id, TUILogin.getLoginUser()));
        }

        searchEdit.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    idLabel.setVisibility(View.GONE);
                }
            }
        });

        searchEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if (TextUtils.isEmpty(searchEdit.getText())) {
                    detailArea.setVisibility(View.GONE);
                    notFoundTip.setVisibility(View.GONE);
                }
            }
        });
        return view;
    }

    public void setIsGroup(boolean isGroup) {
        this.isGroup = isGroup;
    }

    private void setGroupDetail(GroupInfo groupInfo) {
        int radius = ScreenUtil.dip2px(28);
        faceImgView.setRadius(radius);
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
        int radius = ScreenUtil.dip2px(28);
        faceImgView.setRadius(radius);
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

    private void setNotFound() {
        detailArea.setVisibility(View.GONE);
        notFoundTip.setVisibility(View.VISIBLE);
    }

    @Override
    public void finish() {
        dismiss();
    }
}
