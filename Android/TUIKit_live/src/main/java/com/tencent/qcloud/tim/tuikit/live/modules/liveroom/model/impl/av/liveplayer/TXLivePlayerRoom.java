package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.av.liveplayer;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TRTCLogger;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.impl.base.TXCallback;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayConfig;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.HashMap;
import java.util.Map;

public class TXLivePlayerRoom implements ITXLivePlayerRoom {
    private static final String                    TAG = "TXLivePlayerRoom";
    private static       TXLivePlayerRoom          sInstance;
    private              Map<String, TXLivePlayer> mLivePlayerMap;
    private              Context                   mContext;

    public static synchronized TXLivePlayerRoom getInstance() {
        if (sInstance == null) {
            sInstance = new TXLivePlayerRoom();
        }
        return sInstance;
    }

    private TXLivePlayerRoom() {
        mLivePlayerMap = new HashMap<>();
    }

    @Override
    public void init(Context context) {
        mContext = context.getApplicationContext();
    }

    @Override
    public void startPlay(String playURL, TXCloudVideoView view, final TXCallback callback) {
        if (!isURLValid(playURL)) {
            TRTCLogger.e(TAG, "invalid play url:" + playURL);
            if (callback != null) {
                callback.onCallback(-1, "无效的链接:" + playURL);
            }
            return;
        }
        TRTCLogger.i(TAG, "start play, url:" + playURL + " view:" + view);
        TXLivePlayer player = mLivePlayerMap.get(playURL);
        if (player != null) {
            TRTCLogger.w(TAG, "already have player with url, stop and restart.");
            player.stopPlay(true);
            player.setPlayerView(null);
            player.setPlayListener(null);
        }
        player = new TXLivePlayer(mContext);
        player.setPlayListener(new ITXLivePlayListener() {
            @Override
            public void onPlayEvent(int event, Bundle bundle) {
                if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
                    // 收到收个视频帧认为是播放成功了
                    if (callback != null) {
                        callback.onCallback(0, "播放成功");
                    }
                } else if (event < 0) {
                    if (callback != null) {
                        callback.onCallback(event, "播放失败");
                    }
                }
            }

            @Override
            public void onNetStatus(Bundle bundle) {

            }
        });
        TXLivePlayConfig config = new TXLivePlayConfig();
        config.setAutoAdjustCacheTime(true);
        player.setConfig(config);
        mLivePlayerMap.put(playURL, player);

        player.setPlayerView(view);
        int result = player.startPlay(playURL, TXLivePlayer.PLAY_TYPE_LIVE_FLV);
        if (result != 0) {
            if (callback != null) {
                callback.onCallback(result, "play fail, errCode:" + result);
            }
        }
    }

    @Override
    public void stopPlay(String playURL, TXCallback callback) {
        if (!isURLValid(playURL)) {
            TRTCLogger.e(TAG, "invalid play url:" + playURL);
            if (callback != null) {
                callback.onCallback(-1, "invalid play url:" + playURL);
            }
            return;
        }
        TXLivePlayer player = mLivePlayerMap.get(playURL);
        TRTCLogger.i(TAG, "stop play, url:" + playURL);
        if (player == null) {
            TRTCLogger.i(TAG, "stop play fail, can't find player.");
            if (callback != null) {
                callback.onCallback(-1, "can't find player with url.");
            }
            return;
        } else {
            player.stopPlay(true);
            if (callback != null) {
                callback.onCallback(0, "stop play success.");
            }
        }
    }

    @Override
    public void stopAllPlay() {
        for (TXLivePlayer livePlayer: mLivePlayerMap.values()) {
            livePlayer.stopPlay(true);
        }
        mLivePlayerMap.clear();
    }

    @Override
    public void muteRemoteAudio(String playURL, boolean mute) {
        if (!isURLValid(playURL)) {
            TRTCLogger.e(TAG, "invalid play url:" + playURL);
        }
        TXLivePlayer player = mLivePlayerMap.get(playURL);
        if (player == null) {
            TRTCLogger.e(TAG, "mute player audio fail, can't find player with url.");
            return;
        } else {
            player.setMute(mute);
            TRTCLogger.i(TAG, "mute player audio success.");
        }
    }

    @Override
    public void muteAllRemoteAudio(boolean mute) {
        TRTCLogger.i(TAG, "mute all player audio, mute:" + mute);
        for (TXLivePlayer player : mLivePlayerMap.values()) {
            if (player != null) {
                player.setMute(mute);
            }
        }
    }

    @Override
    public void showVideoDebugLog(boolean isShow) {
        for (TXLivePlayer player : mLivePlayerMap.values()) {
            if (player != null) {
            }
        }
    }

    private boolean isURLValid(String url) {
        return !TextUtils.isEmpty(url) && (url.startsWith("http") || url.startsWith("https")) && url.endsWith("flv");
    }
}
