package com.tencent.qcloud.tim.demo;


import com.tencent.qcloud.tim.demo.component.interfaces.IBaseLiveListener;

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
