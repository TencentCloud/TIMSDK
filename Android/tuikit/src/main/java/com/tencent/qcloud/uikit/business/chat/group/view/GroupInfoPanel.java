package com.tencent.qcloud.uikit.business.chat.group.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.infos.IGroupInfoPanel;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatInfo;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupInfoUtils;
import com.tencent.qcloud.uikit.business.chat.group.presenter.GroupInfoPresenter;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMemberControlAdapter;
import com.tencent.qcloud.uikit.business.chat.group.view.widget.GroupMemberControler;
import com.tencent.qcloud.uikit.common.component.datepicker.builder.OptionsPickerBuilder;
import com.tencent.qcloud.uikit.common.component.datepicker.listener.OnOptionsSelectListener;
import com.tencent.qcloud.uikit.common.component.datepicker.view.OptionsPickerView;
import com.tencent.qcloud.uikit.common.component.info.InfoItemAction;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.common.widget.InfoItemView;
import com.tencent.qcloud.uikit.api.infos.GroupInfoPanelEvent;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.common.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;
import com.tencent.qcloud.uikit.common.widget.UIKitSwitch;

import java.util.ArrayList;
import java.util.List;


public class GroupInfoPanel extends LinearLayout implements IGroupInfoPanel {

    private ImageView mGroupIcon;
    private TextView mGroupName;
    private TextView mGroupAccount;
    private TextView mGroupNotice;
    private UIKitSwitch mTopSwitch;
    private Button mDissolveBtn;
    private Button mModifyGroupName;
    private Button mModifyGroupNotice;
    private Button mCancelBtn;
    private PageTitleBar mTitleBar;
    private GroupInfoPanelEvent mEvent;
    private AlertDialog mDialog;
    private InfoItemView mMemberBar;
    private InfoItemView mGroupTypeBar;
    private InfoItemView mJoinTypeBar;
    private InfoItemView mSelfNickBar;

    private GridView mMembersGrid;
    private GroupChatInfo mGroupInfo;
    private GroupMemberControlAdapter mMemberAdapter;
    private AlertDialog mModifyDialog;
    private GroupMemberControler mContorler;
    private GroupInfoPresenter mPresenter;
    private List<String> joinTypes = new ArrayList<>();

    public GroupInfoPanel(Context context) {
        super(context);
        init();
    }

    public GroupInfoPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupInfoPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_info_panel, this);
        mMemberBar = findViewById(R.id.group_member_bar);
        mMemberBar.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mContorler != null)
                    mContorler.detailMemberControl();
            }
        });
        mMembersGrid = findViewById(R.id.group_members);
        mMemberAdapter = new GroupMemberControlAdapter();
        mMembersGrid.setAdapter(mMemberAdapter);
        mGroupTypeBar = findViewById(R.id.group_type_bar);
        mJoinTypeBar = findViewById(R.id.join_type_bar);
        mSelfNickBar = findViewById(R.id.self_nickname_bar);
        mSelfNickBar.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mModifyDialog = PopWindowUtil.buildEditorDialog((Activity) getContext(), "修改昵称", "取消", "确定", false, new PopWindowUtil.EnsureListener() {
                    @Override
                    public void sure(Object obj) {
                        mPresenter.modifyGroupNickname(obj.toString());
                    }

                    @Override
                    public void cancel() {

                    }
                });
            }
        });


        mGroupIcon = findViewById(R.id.group_icon);
        mGroupName = findViewById(R.id.group_name);
        mGroupAccount = findViewById(R.id.group_account);
        mGroupNotice = findViewById(R.id.group_signature);
        mTopSwitch = findViewById(R.id.chat_to_top_switch);
        mTopSwitch.setOnCheckedChangeListener(new UIKitSwitch.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(View buttonView, boolean isChecked) {
                mPresenter.setTopSession(isChecked);
            }
        });

        mDissolveBtn = findViewById(R.id.group_dissolve_button);
        mDissolveBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mGroupInfo == null)
                    return;
                if (mGroupInfo.isOwner() && !mGroupInfo.getGroupType().equals("Private")) {
                    PopWindowUtil.buildEnsureDialog(getContext(), "确认解散该群?", "", "取消", "确认", new PopWindowUtil.EnsureListener() {
                        @Override
                        public void sure(Object obj) {
                            mPresenter.deleteGroup();
                        }

                        @Override
                        public void cancel() {

                        }
                    });
                } else {
                    PopWindowUtil.buildEnsureDialog(getContext(), "确认退出该群?", "", "取消", "确认", new PopWindowUtil.EnsureListener() {
                        @Override
                        public void sure(Object obj) {
                            mPresenter.quiteGroup();
                        }

                        @Override
                        public void cancel() {

                        }
                    });
                }


            }
        });
        mTitleBar = findViewById(R.id.group_info_title_bar);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.group_detail), PageTitleBar.POSITION.CENTER);
        mPresenter = new GroupInfoPresenter(this);
        String array[] = getResources().getStringArray(R.array.group_join_type);
        for (int i = 0; i < array.length; i++) {
            joinTypes.add(array[i]);
        }

    }

    @Override
    public void setGroupInfo(GroupChatInfo info) {
        if (info == null)
            return;
        this.mGroupInfo = info;
        if (!TextUtils.isEmpty(info.getIconUrl()))
            GlideEngine.loadImage(mGroupIcon, info.getIconUrl(), null);
        mGroupName.setText(info.getGroupName());
        mGroupAccount.setText(info.getPeer());
        mGroupNotice.setText(info.getNotice());
        mMemberBar.setValue(info.getMemberCount() + "人");
        mMemberAdapter.setDataSource(info.getMemberDetails());
        mGroupTypeBar.setValue(info.getGroupType());
        mJoinTypeBar.setValue(getResources().getStringArray(R.array.group_join_type)[info.getJoinType()]);
        mSelfNickBar.setValue(mPresenter.getNickName());
        mTopSwitch.setChecked(mGroupInfo.isTopChat());


        if (mGroupInfo.isOwner() && !mGroupInfo.getGroupType().equals("Private")) {
            findViewById(R.id.group_modifiable_content).setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mGroupInfo.isOwner()) {
                        if (mDialog != null && mDialog.isShowing()) {
                            mDialog.dismiss();
                        } else {
                            buildPopMenu();
                        }
                    }

                }
            });
            mJoinTypeBar.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    showJoinTypePickerView();
                }
            });

        } else {
            findViewById(R.id.group_top_info_icon).setVisibility(View.GONE);
            mJoinTypeBar.setIconVisible(View.GONE);
            mDissolveBtn.setText(R.string.exit_group);
        }


    }

    private void showJoinTypePickerView() {
        OptionsPickerBuilder typeBuilder = new OptionsPickerBuilder(getContext(), new OnOptionsSelectListener() {
            @Override
            public void onOptionsSelect(final int options1, int options2, int options3, View v) {
                GroupChatManager.getInstance().modifyGroupInfo(options1, GroupInfoUtils.MODIFY_GROUP_JOIN_TYPE, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        mJoinTypeBar.setValue(joinTypes.get(options1));
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        UIUtils.toastLongMessage("modifyGroupJoinType fail :" + errCode + "=" + errMsg);
                    }
                });
            }
        }).isDialog(false).setCancelText(getResources().getString(R.string.cancel)).setSubmitText(getResources().getString(R.string.sure));
        OptionsPickerView mTypePicker = typeBuilder.build();

        mTypePicker.setPicker(joinTypes);
        Dialog mDialog = mTypePicker.getDialog();
        if (mDialog != null) {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    Gravity.BOTTOM);

            params.leftMargin = 0;
            params.rightMargin = 0;
            mTypePicker.getDialogContainerLayout().setLayoutParams(params);

            Window dialogWindow = mDialog.getWindow();
            if (dialogWindow != null) {
                dialogWindow.setWindowAnimations(R.style.picker_view_slide_anim);//修改动画样式
                dialogWindow.setGravity(Gravity.BOTTOM);//改成Bottom,底部显示
            }
        }
        mTypePicker.show();
    }

    private void buildPopMenu() {
        if (mDialog == null) {
            mDialog = PopWindowUtil.buildFullScreenDialog((Activity) getContext());
            View moreActionView = inflate(getContext(), R.layout.group_info_pop_panel, null);
            mModifyGroupName = moreActionView.findViewById(R.id.modify_group_name);
            mModifyGroupName.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                    mModifyDialog = PopWindowUtil.buildEditorDialog((Activity) getContext(), "修改群名称", "取消", "确定", false, new PopWindowUtil.EnsureListener() {
                        @Override
                        public void sure(Object obj) {
                            mPresenter.modifyGroupName(obj.toString());
                        }

                        @Override
                        public void cancel() {

                        }
                    });
                }
            });
            mModifyGroupNotice = moreActionView.findViewById(R.id.modify_group_notice);
            mModifyGroupNotice.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                    mModifyDialog = PopWindowUtil.buildEditorDialog((Activity) getContext(), "修改群公告", "取消", "确定", false, new PopWindowUtil.EnsureListener() {
                        @Override
                        public void sure(Object obj) {
                            mPresenter.modifyGroupNotice(obj.toString());
                        }

                        @Override
                        public void cancel() {

                        }
                    });
                }
            });
            mCancelBtn = moreActionView.findViewById(R.id.cancel);
            mCancelBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mDialog.setContentView(moreActionView);
        } else {
            mDialog.show();
        }

    }


    @Override
    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }

    @Override
    public void addInfoItem(List<InfoItemAction> items, int group, int index) {

    }

    @Override
    public void addPopActions(List<PopMenuAction> actions) {

    }


    @Override
    public void setGroupInfoPanelEvent(GroupInfoPanelEvent event) {
        mEvent = event;
    }

    public void onGroupInfoModified(String value, int type) {
        switch (type) {
            case GroupInfoUtils.MODIFY_GROUP_NAME:
                UIUtils.toastLongMessage(getResources().getString(R.string.modify_group_name_success));
                mGroupName.setText(value);
                if (mModifyDialog != null)
                    mModifyDialog.dismiss();
                break;
            case GroupInfoUtils.MODIFY_GROUP_NOTICE:
                mGroupNotice.setText(value);
                UIUtils.toastLongMessage(getResources().getString(R.string.modify_group_notice_success));
                if (mModifyDialog != null)
                    mModifyDialog.dismiss();
                break;
        }
    }

    public void onMemberInfoModified(String value, int type) {
        switch (type) {
            case GroupInfoUtils.MODIFY_MEMBER_NAME:
                UIUtils.toastLongMessage(getResources().getString(R.string.modify_nickname_success));
                mSelfNickBar.setValue(value);
                if (mModifyDialog != null)
                    mModifyDialog.dismiss();
                break;

        }
    }


    @Override
    public void setMemberControler(GroupMemberControler controler) {
        mContorler = controler;
        mMemberAdapter.setControler(controler);
    }


    @Override
    public void initDefault() {
        setGroupInfoPanelEvent(new GroupInfoPanelEvent() {
            @Override
            public void onBackClick() {
                if (getContext() instanceof Activity) {
                    ((Activity) getContext()).finish();
                }
            }

            @Override
            public void onDissolve(GroupChatInfo info) {

            }

            @Override
            public void onModifyGroupName(GroupChatInfo info) {

            }

            @Override
            public void onModifyGroupNotice(GroupChatInfo info) {

            }


        });
    }


}
