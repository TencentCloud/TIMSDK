package com.tencent.qcloud.tuikit.tuicallkit.viewmodel.component.videolayout

import android.content.Context
import android.widget.RelativeLayout
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.TUICommonDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.LiveData
import com.tencent.qcloud.tuikit.tuicallengine.impl.base.Observer
import com.tencent.qcloud.tuikit.tuicallkit.data.User
import com.tencent.qcloud.tuikit.tuicallkit.state.TUICallState
import com.tencent.qcloud.tuikit.tuicallkit.utils.DeviceUtils
import java.util.concurrent.CopyOnWriteArrayList

class GroupCallVideoLayoutViewModel {

    public var userList = LiveData<CopyOnWriteArrayList<User>>()
    public var isCameraOpen = LiveData<Boolean>()
    public var isFrontCamera = LiveData<TUICommonDefine.Camera>()
    public var mediaType = LiveData<TUICallDefine.MediaType>()
    public var changedUser = LiveData<User>()

    private var remoteUserListObserver = Observer<LinkedHashSet<User>> {
        if (it != null && it.size > 0) {
            for (user in it) {
                if (!userList.get().contains(user)) {
                    userList.get().add(user)
                    changedUser.set(user)
                }
            }
            for ((index, user) in userList.get().withIndex()) {
                if (index == 0) {
                    continue
                }
                if (!it.contains(user)) {
                    user.callStatus.set(TUICallDefine.Status.None)
                    userList.get().remove(user)
                    changedUser.set(user)
                }
            }
        }
    }

    init {
        isCameraOpen = TUICallState.instance.isCameraOpen
        isFrontCamera = TUICallState.instance.isFrontCamera
        mediaType = TUICallState.instance.mediaType
        changedUser.set(null)
        userList.set(CopyOnWriteArrayList())
        userList.get().add(TUICallState.instance.selfUser.get())
        userList.get().addAll(TUICallState.instance.remoteUserList.get())

        addOnserver()
    }

    private fun addOnserver() {
        TUICallState.instance.remoteUserList.observe(remoteUserListObserver)
    }

    public fun removeObserver() {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }

    fun initLayoutParamsForTwoUser(context: Context): ArrayList<RelativeLayout.LayoutParams> {
        val width = DeviceUtils.getScreenWidth(context)
        val height = DeviceUtils.getScreenHeight(context)
        val size = width.coerceAtMost(height)
        val margin = ScreenUtil.dip2px(10f)
        val grid4W = (size - margin * 2) / 2
        val grid4H = (size - margin * 2) / 2
        val layoutParams0 = RelativeLayout.LayoutParams(grid4W, grid4H)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams0.addRule(RelativeLayout.CENTER_VERTICAL)
        layoutParams0.marginStart = margin
        val layoutParams1 = RelativeLayout.LayoutParams(grid4W, grid4H)
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams1.addRule(RelativeLayout.CENTER_VERTICAL)
        layoutParams1.marginEnd = margin
        val list = ArrayList<RelativeLayout.LayoutParams>()
        list.add(layoutParams0)
        list.add(layoutParams1)
        return list
    }

    fun initLayoutParamsForThreeUser(context: Context): ArrayList<RelativeLayout.LayoutParams> {
        val width = DeviceUtils.getScreenWidth(context)
        val height = DeviceUtils.getScreenHeight(context)
        val size = width.coerceAtMost(height)
        val margin = ScreenUtil.dip2px(10f)
        val grid3W = (size - margin * 2) / 2
        val grid3H = (size - margin * 2) / 2
        val layoutParams0 = RelativeLayout.LayoutParams(grid3W, grid3H)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams0.topMargin = margin
        layoutParams0.marginStart = margin
        val layoutParams1 = RelativeLayout.LayoutParams(grid3W, grid3H)
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams1.topMargin = margin
        layoutParams1.marginEnd = margin
        val layoutParams2 = RelativeLayout.LayoutParams(grid3W, grid3H)
        layoutParams2.addRule(RelativeLayout.CENTER_HORIZONTAL)
        layoutParams2.bottomMargin = margin
        layoutParams2.topMargin = margin + grid3H
        val list = ArrayList<RelativeLayout.LayoutParams>()
        list.add(layoutParams0)
        list.add(layoutParams1)
        list.add(layoutParams2)
        return list
    }

    fun initLayoutParamsForFourUser(context: Context): ArrayList<RelativeLayout.LayoutParams> {
        val width = DeviceUtils.getScreenWidth(context)
        val height = DeviceUtils.getScreenHeight(context)
        val size = width.coerceAtMost(height)
        val margin = ScreenUtil.dip2px(10f)
        val grid4W = (size - margin * 2) / 2
        val grid4H = (size - margin * 2) / 2
        val layoutParams0 = RelativeLayout.LayoutParams(grid4W, grid4H)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams0.topMargin = margin
        layoutParams0.marginStart = margin
        val layoutParams1 = RelativeLayout.LayoutParams(grid4W, grid4H)
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams1.topMargin = margin
        layoutParams1.marginEnd = margin
        val layoutParams2 = RelativeLayout.LayoutParams(grid4W, grid4H)
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams2.bottomMargin = margin
        layoutParams2.topMargin = margin + grid4H
        layoutParams2.marginStart = margin
        val layoutParams3 = RelativeLayout.LayoutParams(grid4W, grid4H)
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams3.bottomMargin = margin
        layoutParams3.topMargin = margin + grid4H
        layoutParams3.marginEnd = margin
        val list = ArrayList<RelativeLayout.LayoutParams>()
        list.add(layoutParams0)
        list.add(layoutParams1)
        list.add(layoutParams2)
        list.add(layoutParams3)
        return list
    }

    fun initLayoutParamsMoreThanFourUser(context: Context): ArrayList<RelativeLayout.LayoutParams> {
        val width = DeviceUtils.getScreenWidth(context)
        val height = DeviceUtils.getScreenHeight(context)
        val size = width.coerceAtMost(height)
        val margin = ScreenUtil.dip2px(10f)
        val grid9W = (size - margin * 2) / 3
        val grid9H = (size - margin * 2) / 3
        val layoutParams0 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams0.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams0.topMargin = margin
        layoutParams0.marginStart = margin
        val layoutParams1 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams1.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams1.topMargin = margin
        layoutParams1.marginStart = margin + grid9W
        val layoutParams2 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams2.addRule(RelativeLayout.ALIGN_PARENT_TOP)
        layoutParams2.topMargin = margin
        layoutParams2.marginEnd = margin
        val layoutParams3 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams3.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams3.marginStart = margin
        layoutParams3.topMargin = margin + grid9H
        val layoutParams4 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams4.topMargin = margin + grid9H
        layoutParams4.marginStart = margin + grid9W
        val layoutParams5 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams5.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams5.topMargin = margin + grid9H
        layoutParams5.marginEnd = margin
        val layoutParams6 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams6.addRule(RelativeLayout.ALIGN_PARENT_START)
        layoutParams6.bottomMargin = margin
        layoutParams6.marginStart = margin
        layoutParams6.topMargin = margin + grid9H * 2
        val layoutParams7 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams7.bottomMargin = margin
        layoutParams7.topMargin = margin + grid9H * 2
        layoutParams7.marginStart = margin + grid9W
        val layoutParams8 = RelativeLayout.LayoutParams(grid9W, grid9H)
        layoutParams8.addRule(RelativeLayout.ALIGN_PARENT_END)
        layoutParams8.bottomMargin = margin
        layoutParams8.topMargin = margin + grid9H * 2
        layoutParams8.marginEnd = margin
        val list = ArrayList<RelativeLayout.LayoutParams>()
        list.add(layoutParams0)
        list.add(layoutParams1)
        list.add(layoutParams2)
        list.add(layoutParams3)
        list.add(layoutParams4)
        list.add(layoutParams5)
        list.add(layoutParams6)
        list.add(layoutParams7)
        list.add(layoutParams8)
        return list
    }
}