package com.tencent.cloud.tuikit.roomkit.manager;

import android.content.res.Configuration;
import android.os.SystemClock;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;

public class ViewController extends Controller {
    public ViewController(ConferenceState roomStore, TUIRoomEngine engine) {
        super(roomStore, engine);
    }

    @Override
    public void destroy() {
    }

    public void clearPendingTakeSeatRequests() {
        mViewState.clearPendingTakeSeatRequests();
    }

    public void updateScreenOrientation(Configuration newConfig) {
        boolean isPortrait = newConfig.orientation == Configuration.ORIENTATION_PORTRAIT;
        if (isPortrait == mViewState.isScreenPortrait.get()) {
            return;
        }
        mViewState.isScreenPortrait.set(isPortrait);
    }

    public void updateUserTypeSelected(ViewState.UserListType type) {
        mViewState.userListType.set(type);
    }

    public void updateSearchUserKeyWord(String newWord) {
        String oldWord = mViewState.searchUserKeyWord.get();
        if (TextUtils.equals(newWord, oldWord)) {
            return;
        }
        mViewState.searchUserKeyWord.set(newWord);
    }

    public void updateRoomProcess(ViewState.RoomProcess roomProcess) {
        mViewState.roomProcess.set(roomProcess);
    }

    public boolean isProcessRoom() {
        return mViewState.roomProcess.get() != ViewState.RoomProcess.NONE;
    }

    public void anchorEnterRoomTimeFromBoot() {
        mViewState.enterRoomTimeFromBoot.set(SystemClock.elapsedRealtime());
    }
}
