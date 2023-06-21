package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.viewmodel.CreateRoomViewModel;
import com.tencent.cloud.tuikit.roomkit.view.settingitem.SwitchSettingItem;
import com.tencent.cloud.tuikit.roomkit.utils.UserModel;
import com.tencent.cloud.tuikit.roomkit.utils.UserModelManager;

import java.util.ArrayList;

public class CreateRoomView extends RelativeLayout
        implements View.OnClickListener {
    private Context             mContext;
    private Toolbar             mToolbar;
    private TextView            mTextRoomId;
    private TextView            mTextCreateRoom;
    private TextView            mTextUserName;
    private TextView            mTextRoomType;
    private LinearLayout        mLayoutSettingContainer;
    private RoomTypeSelectView  mRoomTypeDialog;
    private CreateRoomViewModel mViewModel;

    public CreateRoomView(Context context) {
        super(context);
        View.inflate(context, R.layout.tuiroomkit_view_create_room, this);
        mContext = context;
        mViewModel = new CreateRoomViewModel(mContext, this);
        initView();
        initData();
    }

    public void setRoomTypeText(String type) {
        mTextRoomType.setText(type);
    }

    private void initData() {
        UserModelManager manager = UserModelManager.getInstance();
        UserModel userModel = manager.getUserModel();
        String userId = userModel.userId;
        String userName = userModel.userName;
        if (!TextUtils.isEmpty(userId)) {
            String roomId = mViewModel.getRoomId(userId);
            mTextRoomId.setText(roomId);
        }
        if (!TextUtils.isEmpty(userName)) {
            mTextUserName.setText(userName);
        }
    }

    private void initView() {
        mToolbar = findViewById(R.id.toolbar);
        mTextCreateRoom = findViewById(R.id.tv_create);
        mTextUserName = findViewById(R.id.tv_user_name);
        mTextRoomId = findViewById(R.id.tv_room_id);
        mTextRoomType = findViewById(R.id.tv_room_type);
        mLayoutSettingContainer = findViewById(R.id.ll_setting_container);
        mRoomTypeDialog = new RoomTypeSelectView(mContext);

        mTextRoomType.setOnClickListener(this);
        mTextCreateRoom.setOnClickListener(this);
        mToolbar.setNavigationOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.finishActivity();
            }
        });

        ArrayList<SwitchSettingItem> settingItemList = mViewModel.createSwitchSettingItemList();
        int size = settingItemList.size();
        for (int i = 0; i < size; i++) {
            SwitchSettingItem item = settingItemList.get(i);
            if (i == size - 1) {
                item.hideBottomLine();
            }
            mLayoutSettingContainer.addView(item.getView());
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        mViewModel.destroy();
        super.onDetachedFromWindow();
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.tv_room_type) {
            if (mRoomTypeDialog == null) {
                mRoomTypeDialog = new RoomTypeSelectView(mContext);
            }
            mRoomTypeDialog.show();
        } else if (view.getId() == R.id.tv_create) {
            mViewModel.createRoom(mTextRoomId.getText().toString());
        }
    }
}
