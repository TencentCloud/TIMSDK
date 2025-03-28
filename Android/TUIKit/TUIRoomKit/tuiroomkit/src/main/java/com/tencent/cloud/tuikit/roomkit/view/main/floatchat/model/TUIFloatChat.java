package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.model;


import java.util.HashMap;

public class TUIFloatChat {
    public final TUIFloatChatUser        user    = new TUIFloatChatUser();
    public       String                  content;
    public       HashMap<String, Object> extInfo = new HashMap<>();
}
