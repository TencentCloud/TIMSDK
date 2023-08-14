package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.utils.UserModelManager;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SwitchSettingItem;
import com.tencent.cloud.tuikit.roomkit.viewmodel.EnterRoomViewModel;

import java.util.ArrayList;

public class EnterRoomView extends RelativeLayout {

    private Context            mContext;
    private Toolbar            mToolbar;
    private TextView           mTextEnterRoom;
    private TextView           mTextUserName;
    private EditText           mTextRoomId;
    private LinearLayout       mSettingContainer;
    private EnterRoomViewModel mViewModel;

    public EnterRoomView(Context context) {
        super(context);
        View.inflate(context, R.layout.tuiroomkit_view_enter_room, this);
        mContext = context;
        mViewModel = new EnterRoomViewModel(mContext);
        initView();
        initData();
    }

    private void initView() {
        mToolbar = findViewById(R.id.toolbar);
        mTextRoomId = findViewById(R.id.et_room_id);
        mTextEnterRoom = findViewById(R.id.tv_enter);
        mSettingContainer = findViewById(R.id.ll_setting_container);
        mTextUserName = findViewById(R.id.tv_user_name);

        mTextEnterRoom.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.enterRoom(mTextRoomId.getText().toString());
            }
        });
        mToolbar.setNavigationOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_ENTER_ROOM, null);
            }
        });
        mTextRoomId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                mTextEnterRoom.setEnabled(!TextUtils.isEmpty(mTextRoomId.getText().toString()));
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        ArrayList<SwitchSettingItem> settingItemList = mViewModel.createSwitchSettingItemList();
        int size = settingItemList.size();
        for (int i = 0; i < size; i++) {
            SwitchSettingItem item = settingItemList.get(i);
            if (i == size - 1) {
                item.hideBottomLine();
            }
            mSettingContainer.addView(item.getView());
        }
    }

    private void initData() {
        String userName = UserModelManager.getInstance().getUserModel().userName;
        if (!TextUtils.isEmpty(userName)) {
            mTextUserName.setText(userName);
        }
    }
}
