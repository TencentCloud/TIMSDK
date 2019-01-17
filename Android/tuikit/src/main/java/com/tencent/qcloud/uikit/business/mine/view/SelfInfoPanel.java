package com.tencent.qcloud.uikit.business.mine.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.tencent.imsdk.TIMManager;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.api.infos.ISelfInfoPanel;
import com.tencent.qcloud.uikit.common.component.info.InfoItemAction;
import com.tencent.qcloud.uikit.business.chat.c2c.model.PersonalInfoBean;
import com.tencent.qcloud.uikit.business.mine.presenter.SelfInfoPresenter;
import com.tencent.qcloud.uikit.common.component.info.InfoItemAdapter;
import com.tencent.qcloud.uikit.common.component.info.InfoItemListView;
import com.tencent.qcloud.uikit.business.chat.c2c.view.widget.SelfInfoPanelEvent;
import com.tencent.qcloud.uikit.common.component.datepicker.builder.TimePickerBuilder;
import com.tencent.qcloud.uikit.common.component.datepicker.listener.OnTimeSelectChangeListener;
import com.tencent.qcloud.uikit.common.component.datepicker.listener.OnTimeSelectListener;
import com.tencent.qcloud.uikit.common.component.datepicker.view.TimePickerView;
import com.tencent.qcloud.uikit.common.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.PopWindowUtil;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class SelfInfoPanel extends LinearLayout implements ISelfInfoPanel, View.OnClickListener {
    public ImageView mUserIcon;
    public TextView mNickName, mAccount, mSignature;
    public ListView mFirstItemList, mSecondItemList;
    public PageTitleBar mTitleBar;
    public ViewGroup mItemsGroup;

    private SelfInfoPresenter mPresenter;
    private AlertDialog mDialog;
    private PersonalInfoBean mInfo;
    private Button mModifyNickNameBtn, mModifySignatureBtn, mCancelBtn;
    private SelfInfoPanelEvent mEvent;
    private TimePickerView mDatePicker;
    private InfoItemAdapter mFirstItemAdapter, mSecondItemAdapter;
    private List<InfoItemAction> mFirstActions, mSecondActions;
    private List<ListView> mListViews = new ArrayList<>();
    private List<InfoItemAdapter> mListAdapters = new ArrayList<>();
    private List<List> mListDatas = new ArrayList<>();
    private LinearLayout mBaseView;


    public SelfInfoPanel(Context context) {
        super(context);
        init();
    }

    public SelfInfoPanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public SelfInfoPanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.personal_self_info_panel, this);
        mBaseView = findViewById(R.id.self_info_base_layout);
        mUserIcon = findViewById(R.id.self_icon);
        mNickName = findViewById(R.id.self_nickName);
        mAccount = findViewById(R.id.self_account);
        mSignature = findViewById(R.id.self_signature);
        mTitleBar = findViewById(R.id.self_info_title_bar);
        mItemsGroup = findViewById(R.id.self_info_item_groups);
        mFirstItemList = findViewById(R.id.self_info_first_item_group);
        mSecondItemList = findViewById(R.id.self_info_second_item_group);
        mFirstItemAdapter = new InfoItemAdapter();
        mSecondItemAdapter = new InfoItemAdapter();
        mFirstItemList.setAdapter(mFirstItemAdapter);
        mSecondItemList.setAdapter(mSecondItemAdapter);
        mFirstItemList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                InfoItemAction action = mFirstActions.get(position);
                if (action.getItemClick() != null)
                    action.getItemClick().onItemClick(view, action.getAction());
            }
        });
        mSecondItemList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                InfoItemAction action = mSecondActions.get(position);
                if (action.getItemClick() != null)
                    action.getItemClick().onItemClick(view, action.getAction());
            }
        });
        mListViews.add(mFirstItemList);
        mListViews.add(mSecondItemList);
        mListAdapters.add(mFirstItemAdapter);
        mListAdapters.add(mSecondItemAdapter);

        mTitleBar.getLeftGroup().setVisibility(GONE);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.self), PageTitleBar.POSITION.CENTER);
        mPresenter = new SelfInfoPresenter(this);

        initData();
    }

    private void initData() {
        mFirstActions = new ArrayList<>();
        InfoItemAction action = new InfoItemAction();
        action.setLabel(getResources().getString(R.string.user_birthday));
        action.setItemClick(new InfoItemAction.InfoItemClick() {
            @Override
            public void onItemClick(View view, String action) {
                showDatePickerView();
            }
        });
        mFirstActions.add(action);
        action = new InfoItemAction();
        action.setLabel(getResources().getString(R.string.user_sex));
        mFirstActions.add(action);
        action = new InfoItemAction();
        action.setLabel(getResources().getString(R.string.user_location));
        mFirstActions.add(action);
        mFirstItemAdapter.setDataSource(mFirstActions);
        mListDatas.add(mFirstActions);

        mSecondActions = new ArrayList<>();
        action = new InfoItemAction();
        action.setLabel(getResources().getString(R.string.add_rule));
        action.setItemClick(new InfoItemAction.InfoItemClick() {
            @Override
            public void onItemClick(View view, String action) {
                InfoItemAction addAction = new InfoItemAction();
                addAction.setLabel(getResources().getString(R.string.add_rule));
                addAction(addAction, 0, 2);
            }
        });

        mSecondActions.add(action);
        action = new InfoItemAction();
        action.setLabel(getResources().getString(R.string.settings));
        action.setItemClick(new InfoItemAction.InfoItemClick() {
            @Override
            public void onItemClick(View view, String action) {
                InfoItemAction addAction = new InfoItemAction();
                addAction.setLabel(getResources().getString(R.string.add_rule));
                addAction(addAction, 3, 2);
            }
        });
        mSecondActions.add(action);
        mSecondItemAdapter.setDataSource(mSecondActions);
        mListDatas.add(mSecondActions);
        mAccount.setText(TIMManager.getInstance().getLoginUser());
    }


    public void initPersonalInfo(PersonalInfoBean info) {
        this.mInfo = info;
        GlideEngine.loadImage(mUserIcon, info.getIconUrl(), null);
        mNickName.setText(info.getNickName());
        mAccount.setText(info.getAccount());
        mSignature.setText(info.getSignature());
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.self_profile_group) {
            buildPopMenu();
        }
    }

    public void addAction(InfoItemAction action, int groupIndex, int itemIndex) {
        if (mListViews.size() < groupIndex + 1) {
            LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT, 1);
            params.setMargins(0, UIUtils.getPxByDp(20), 0, 0);
            View line = new View(getContext());
            line.setBackgroundColor(getResources().getColor(R.color.item_split_color));
            mBaseView.addView(line, params);

            InfoItemListView addListView = new InfoItemListView(getContext());
            params = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
            addListView.setDividerHeight(0);
            mBaseView.addView(addListView, params);

            line = new View(getContext());
            line.setBackgroundColor(getResources().getColor(R.color.item_split_color));
            params = new LayoutParams(LayoutParams.MATCH_PARENT, 1);
            mBaseView.addView(line, params);


            InfoItemAdapter adapter = new InfoItemAdapter();
            final List<InfoItemAction> actions = new ArrayList<>();
            actions.add(action);
            addListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    InfoItemAction action = actions.get(position);
                    if (action.getItemClick() != null)
                        action.getItemClick().onItemClick(view, action.getAction());
                }
            });
            adapter.setDataSource(actions);
            addListView.setAdapter(adapter);

            mListAdapters.add(adapter);
            mListDatas.add(actions);
            mListViews.add(addListView);

        } else {
            List<InfoItemAction> datas = mListDatas.get(groupIndex);
            if (datas.size() >= itemIndex) {
                datas.add(itemIndex, action);
            } else {
                datas.add(action);
            }

            mListAdapters.get(groupIndex).notifyDataSetChanged();
        }
    }


    private void buildPopMenu() {
        if (mDialog == null) {
            mDialog = PopWindowUtil.buildFullScreenDialog((Activity) getContext());
            View moreActionView = inflate(getContext(), R.layout.personal_more_action_panel, null);
            moreActionView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    mDialog.dismiss();
                }
            });
            mModifyNickNameBtn = moreActionView.findViewById(R.id.del_friend_button);
            mModifyNickNameBtn.setText(R.string.modify_nick_name);
            mModifyNickNameBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    PopWindowUtil.buildEditorDialog(getContext(), getResources().getString(R.string.modify_nick_name), getResources().getString(R.string.cancel), getResources().getString(R.string.sure), false, new PopWindowUtil.EnsureListener() {

                        @Override
                        public void sure(Object obj) {
                            mEvent.onModifyNickNameClick(obj.toString());
                        }

                        @Override
                        public void cancel() {

                        }
                    });
                }
            });

            mModifySignatureBtn = moreActionView.findViewById(R.id.add_to_blacklist);
            mModifySignatureBtn.setText(R.string.modify_signature);
            mModifyNickNameBtn.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    PopWindowUtil.buildEditorDialog(getContext(), getResources().getString(R.string.modify_signature), getResources().getString(R.string.cancel), getResources().getString(R.string.sure), false, new PopWindowUtil.EnsureListener() {

                        @Override
                        public void sure(Object obj) {
                            mEvent.onModifySignatureClick(obj.toString());
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


    private void showDatePickerView() {
        mDatePicker = new TimePickerBuilder(getContext(), new OnTimeSelectListener() {
            @Override
            public void onTimeSelect(Date date, View v) {


            }
        }).setType(new boolean[]{true, true, true, false, false, false})
                .isDialog(true)
                .setTimeSelectChangeListener(new OnTimeSelectChangeListener() {
                    @Override
                    public void onTimeSelectChanged(Date date) {
                        Log.i("pvTime", "onTimeSelectChanged");
                    }
                }).build();

        Dialog mDialog = mDatePicker.getDialog();
        if (mDialog != null) {

            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    Gravity.BOTTOM);

            params.leftMargin = 0;
            params.rightMargin = 0;
            mDatePicker.getDialogContainerLayout().setLayoutParams(params);

            Window dialogWindow = mDialog.getWindow();
            if (dialogWindow != null) {
                dialogWindow.setWindowAnimations(R.style.picker_view_slide_anim);//修改动画样式
                dialogWindow.setGravity(Gravity.BOTTOM);//改成Bottom,底部显示
            }
        }
        mDatePicker.show();
    }


}
