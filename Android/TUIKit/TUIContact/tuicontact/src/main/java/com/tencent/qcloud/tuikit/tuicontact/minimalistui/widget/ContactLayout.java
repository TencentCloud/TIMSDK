package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopActionClickListener;
import com.tencent.qcloud.tuikit.timcommon.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.interfaces.IContactLayout;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.AddMoreMinimalistDialogFragment;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.TUIContactMinimalistFragment;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import java.util.ArrayList;
import java.util.List;

public class ContactLayout extends LinearLayout implements IContactLayout {
    private static final String TAG = ContactLayout.class.getSimpleName();

    private ContactListView mContactListView;
    private View createNewButton;
    private Menu menu;
    private ImageView homeView;
    private TextView titleView;
    private TextView rtCubeTitleView;

    private TUIContactMinimalistFragment.OnClickListener mClickListener = null;

    private ContactPresenter presenter;

    public ContactLayout(Context context) {
        super(context);
        init();
    }

    public ContactLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ContactLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setPresenter(ContactPresenter presenter) {
        this.presenter = presenter;
    }

    private void init() {
        inflate(getContext(), R.layout.minimalist_contact_layout, this);
        mContactListView = findViewById(R.id.contact_listview);
        createNewButton = findViewById(R.id.create_new_button);
        homeView = findViewById(R.id.home_rtcube);
        titleView = findViewById(R.id.title);
        rtCubeTitleView = findViewById(R.id.title_rtcube);
        initContactMenu();
        createNewButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (menu != null && !menu.isShowing()) {
                    menu.show();
                }
            }
        });
    }

    public void setOnClickListener(TUIContactMinimalistFragment.OnClickListener listener) {
        mClickListener = listener;
    }

    public void initUI() {
        if (TUIConfig.getTUIHostType() != TUIConfig.TUI_HOST_TYPE_RTCUBE) {
            homeView.setVisibility(GONE);
            titleView.setVisibility(VISIBLE);
            rtCubeTitleView.setVisibility(GONE);
        } else {
            homeView.setVisibility(VISIBLE);
            titleView.setVisibility(GONE);
            rtCubeTitleView.setVisibility(VISIBLE);
            homeView.setBackgroundResource(R.drawable.title_bar_left_icon);
            homeView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TIMAppKit.BACK_TO_RTCUBE_DEMO_TYPE_KEY, TUIConstants.TIMAppKit.BACK_TO_RTCUBE_DEMO_TYPE_IM);
                    TUICore.startActivity("TRTCMainActivity", bundle);
                    if (mClickListener != null) {
                        mClickListener.finishActivity();
                    }
                }
            });
        }
    }

    private void initContactMenu() {
        menu = new Menu((Activity) getContext(), createNewButton);
        PopActionClickListener popActionClickListener = new PopActionClickListener() {
            @Override
            public void onActionClick(int index, Object data) {
                PopMenuAction action = (PopMenuAction) data;
                boolean isGroup = false;
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.add_friend))) {
                    isGroup = false;
                }
                if (TextUtils.equals(action.getActionName(), getResources().getString(R.string.add_group))) {
                    isGroup = true;
                }
                AddMoreMinimalistDialogFragment addFragment = new AddMoreMinimalistDialogFragment();
                addFragment.setIsGroup(isGroup);
                addFragment.show(((AppCompatActivity) getContext()).getSupportFragmentManager(), "AddMoreDialog");
                menu.hide();
            }
        };
        PopMenuAction action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.add_friend));
        action.setIconResId(R.drawable.contact_add_friend);
        action.setActionClickListener(popActionClickListener);
        List<PopMenuAction> menuActionList = new ArrayList<>(2);
        menuActionList.add(action);

        action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.add_group));
        action.setIconResId(R.drawable.contact_add_group);
        action.setActionClickListener(popActionClickListener);
        menuActionList.add(action);
        menu.setMenuAction(menuActionList);
    }

    public void initDefault() {
        mContactListView.setPresenter(presenter);
        presenter.setContactListView(mContactListView);
        mContactListView.loadDataSource(ContactListView.DataSource.CONTACT_LIST);
    }

    @Override
    public ContactListView getContactListView() {
        return mContactListView;
    }

    @Override
    public TitleBarLayout getTitleBar() {
        return null;
    }

    @Override
    public void setParentLayout(Object parent) {}
}
