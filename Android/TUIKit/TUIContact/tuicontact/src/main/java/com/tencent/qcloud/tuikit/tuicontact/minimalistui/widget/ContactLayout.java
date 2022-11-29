package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.action.PopActionClickListener;
import com.tencent.qcloud.tuicore.component.action.PopMenuAction;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.interfaces.IContactLayout;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages.AddMoreMinimalistActivity;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;

import java.util.ArrayList;
import java.util.List;


public class ContactLayout extends LinearLayout implements IContactLayout {

    private static final String TAG = ContactLayout.class.getSimpleName();

    private ContactListView mContactListView;
    private View createNewButton;
    private Menu menu;

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

    private void initContactMenu() {
        menu = new Menu((Activity) getContext(), createNewButton);
        List<PopMenuAction> menuActionList = new ArrayList<>(2);
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
                Intent intent = new Intent(getContext(), AddMoreMinimalistActivity.class);
                intent.putExtra(TUIContactConstants.GroupType.GROUP, isGroup);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getContext().startActivity(intent);
                menu.hide();
            }
        };
        PopMenuAction action = new PopMenuAction();
        action.setActionName(getResources().getString(R.string.add_friend));
        action.setIconResId(R.drawable.contact_add_friend);
        action.setActionClickListener(popActionClickListener);
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
    public void setParentLayout(Object parent) {

    }
}
