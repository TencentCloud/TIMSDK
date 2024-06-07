package com.tencent.cloud.tuikit.roomkit.model.controller;

import android.content.res.Configuration;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceState;

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

    public void updateOnSeatPanelSelected(boolean isSelected) {
        mViewState.isSeatedTabSelected.set(isSelected);
    }

    public void updateSearchUserKeyWord(String newWord) {
        String oldWord = mViewState.searchUserKeyWord.get();
        if (TextUtils.equals(newWord, oldWord)) {
            return;
        }
        mViewState.searchUserKeyWord.set(newWord);
    }
}
