package com.tencent.cloud.tuikit.roomkit.view.create;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceSession;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.FetchRoomId;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.view.basic.SwitchSettingItem;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;

import java.util.ArrayList;

public class CreateConferenceView extends RelativeLayout
        implements View.OnClickListener {
    private Context                   mContext;
    private Toolbar                   mToolbar;
    private TextView                  mTextCreateRoom;
    private TextView                  mTextUserName;
    private TextView                  mTextRoomType;
    private LinearLayout              mLayoutSettingContainer;
    private RoomTypeSelectView        mRoomTypeDialog;
    private CreateConferenceViewModel mViewModel;

    private TUICallback mFinishCallback;

    private String mRoomId;

    private final ConferenceDefine.ConferenceObserver mConferenceObserver = new ConferenceDefine.ConferenceObserver() {
        @Override
        public void onConferenceStarted(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {
            if (error == TUICommonDefine.Error.SUCCESS) {
                return;
            }
            RoomToast.toastLongMessage("error=" + error + " message=" + message);
            mTextCreateRoom.setClickable(true);
            mRoomId = null;
            initData();
        }
    };

    public CreateConferenceView(Context context) {
        super(context);
        View.inflate(context, R.layout.tuiroomkit_view_create_room, this);
        mContext = context;
        mViewModel = new CreateConferenceViewModel(mContext);
        initView();
        initData();
    }

    public void setFinishCallback(TUICallback finishCallback) {
        mFinishCallback = finishCallback;
    }

    private void initData() {
        String userName = TUILogin.getNickName();
        mTextUserName.setText(userName);
        FetchRoomId.fetch(new FetchRoomId.GetRoomIdCallback() {
            @Override
            public void onGetRoomId(String roomId) {
                mRoomId = roomId;
            }
        });
    }

    private void initView() {
        mToolbar = findViewById(R.id.toolbar);
        mTextCreateRoom = findViewById(R.id.tv_create);
        mTextUserName = findViewById(R.id.tv_user_name);
        mTextRoomType = findViewById(R.id.tv_room_type);
        mLayoutSettingContainer = findViewById(R.id.ll_setting_container);
        mRoomTypeDialog = new RoomTypeSelectView(mContext);
        mRoomTypeDialog.setSeatEnableCallback(new RoomTypeSelectView.SeatEnableCallback() {
            @Override
            public void onSeatEnableChanged(boolean enable) {
                mViewModel.setSeatEnable(enable);
                int resId = enable ? R.string.tuiroomkit_room_raise_hand : R.string.tuiroomkit_room_free_speech;
                mTextRoomType.setText(resId);
            }
        });

        mTextRoomType.setOnClickListener(this);
        mTextCreateRoom.setOnClickListener(this);
        mToolbar.setNavigationOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mFinishCallback != null) {
                    mFinishCallback.onSuccess();
                }
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
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceSession.sharedInstance().addObserver(mConferenceObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceSession.sharedInstance().removeObserver(mConferenceObserver);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.tv_room_type) {
            if (mRoomTypeDialog == null) {
                mRoomTypeDialog = new RoomTypeSelectView(mContext);
            }
            mRoomTypeDialog.show();
        } else if (view.getId() == R.id.tv_create) {
            if (TextUtils.isEmpty(mRoomId)) {
                RoomToast.toastShortMessage(mContext.getString(R.string.tuiroomkit_tip_creating_room_id));
                return;
            }
            mViewModel.createRoom(mRoomId);
            mFinishCallback.onSuccess();
        }
    }
}
