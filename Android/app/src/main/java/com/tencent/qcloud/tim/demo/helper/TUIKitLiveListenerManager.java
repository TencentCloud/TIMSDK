package com.tencent.qcloud.tim.demo.helper;

public class TUIKitLiveListenerManager {
    private static final TUIKitLiveListenerManager INSTANCE = new TUIKitLiveListenerManager();

    private IBaseLiveListener iBaseLiveListener;

    public static TUIKitLiveListenerManager getInstance() {
        return INSTANCE;
    }

    public void registerCallListener(IBaseLiveListener callListener) {
        this.iBaseLiveListener = callListener;
    }

    public IBaseLiveListener getBaseCallListener() {
        return this.iBaseLiveListener;
    }
}
