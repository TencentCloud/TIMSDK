package com.tencent.qcloud.tuikit.tuicallkit.view

import android.view.ViewGroup

abstract class CallAdapter {
    /**
     * Customized View on the Call Stream View, and function view need to be added by yourself
     * @param view Call Stream View
     * @return new customized view, if return null, the original view will be used
     */
    open fun onCreateStreamView(view: ViewGroup): ViewGroup? {
        return null
    }

    /**
     * Customized View on the Call Main View
     *
     * @param view Call Main View
     * @return new customized view, if return null, the original view will be used
     */
    open fun onCreateMainView(view: ViewGroup): ViewGroup? {
        return null
    }
}