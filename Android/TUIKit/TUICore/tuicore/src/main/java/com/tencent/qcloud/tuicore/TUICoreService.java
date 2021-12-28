package com.tencent.qcloud.tuicore;
/* ----------------------------------------------
 *     company : Dilusese
 *      author : kuangch
 *        date : 2021.12.28
 * ---------------------------------------------- */

import android.content.Context;

public class TUICoreService extends ServiceInitializer{

    @Override
    public void init(Context context) {
        TUIRouter.init(context);
        TUIConfig.init(context);
    }
}
