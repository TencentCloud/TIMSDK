package com.tencent.qcloud.tuikit.tuicallkit.view.component.recents

import android.content.Context
import android.view.View
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.tencent.cloud.tuikit.engine.call.TUICallDefine
import com.tencent.cloud.tuikit.engine.call.TUICallDefine.CallRecords
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ValueCallback
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import com.tencent.qcloud.tuikit.tuicallkit.state.UserState
import java.util.Date

class RecentCallsItemHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    private lateinit var textUserTitle: TextView
    private lateinit var imageMediaType: ImageView
    private lateinit var textCallStatus: TextView
    private lateinit var textCallTime: TextView
    lateinit var imageDetails: ImageView
    lateinit var layoutDelete: RelativeLayout
    lateinit var checkBoxSelectCall: CheckBox
    lateinit var layoutView: ConstraintLayout
    lateinit var callIconView: RecordsIconView

    init {
        initView()
    }

    private fun initView() {
        layoutDelete = itemView.findViewById(R.id.ll_call_delete)
        checkBoxSelectCall = itemView.findViewById(R.id.cb_call_select)
        callIconView = itemView.findViewById(R.id.call_icon)
        textUserTitle = itemView.findViewById(R.id.tv_call_user_id)
        imageMediaType = itemView.findViewById(R.id.call_media_type)
        textCallStatus = itemView.findViewById(R.id.tv_call_status)
        textCallTime = itemView.findViewById(R.id.tv_call_time)
        imageDetails = itemView.findViewById(R.id.img_call_details)
        layoutView = itemView.findViewById(R.id.cl_info_layout)
    }

    fun layoutViews(context: Context, records: CallRecords?) {
        if (records == null) {
            return
        }
        val colorId = when (CallRecords.Result.Missed) {
            records.result -> R.color.tuicallkit_record_text_red
            else -> R.color.tuicallkit_color_black
        }
        textUserTitle.setTextColor(ContextCompat.getColor(context, colorId))
        val imageId = when (TUICallDefine.MediaType.Video) {
            records.mediaType -> R.drawable.tuicallkit_record_ic_video_call
            else -> R.drawable.tuicallkit_record_ic_audio_call
        }
        imageMediaType.setImageDrawable(ContextCompat.getDrawable(context, imageId))
        var resultMsg = context.getString(R.string.tuicallkit_record_result_unknown)
        if (CallRecords.Result.Missed == records.result) {
            resultMsg = context.getString(R.string.tuicallkit_record_result_missed)
        } else if (CallRecords.Result.Incoming == records.result) {
            resultMsg = context.getString(R.string.tuicallkit_record_result_incoming)
        } else if (CallRecords.Result.Outgoing == records.result) {
            resultMsg = context.getString(R.string.tuicallkit_record_result_outgoing)
        }
        textCallStatus.text = resultMsg
        textCallTime.text = DateTimeUtil.getTimeFormatText(Date(records.beginTime))
        val list: MutableList<String?> = ArrayList()
        if (records.inviteList != null) {
            list.addAll(records.inviteList)
        }
        list.add(records.inviter.trim { it <= ' ' })
        list.remove(TUILogin.getLoginUser())
        callIconView.tag = list
        UserManager.instance.updateUserListInfo(list, object : ValueCallback<List<UserState.User>?> {
            override fun onSuccess(userFullInfoList: List<UserState.User>?) {
                if (userFullInfoList.isNullOrEmpty()) {
                    return
                }
                val avatarList: MutableList<Any?> = ArrayList()
                val newUserList: MutableList<String> = ArrayList()
                val nameList: MutableList<String> = ArrayList()
                for (i in userFullInfoList.indices) {
                    avatarList.add(userFullInfoList[i].avatar.get())
                    newUserList.add(userFullInfoList[i].id)
                    nameList.add(userFullInfoList[i].nickname.get())
                }

                if (!records.groupId.isNullOrEmpty()
                    || (records.scene == TUICallDefine.Scene.MULTI_CALL && records.inviteList.size > 1)) {
                    avatarList.add(TUILogin.getFaceUrl())
                }
                val oldUserList: List<String> = ArrayList(
                    callIconView.tag as List<String>
                )
                if (oldUserList.size == newUserList.size && oldUserList.containsAll(newUserList)) {
                    callIconView.setImageId(records.callId)
                    callIconView.displayImage(avatarList).load(records.callId)
                    textUserTitle.text = nameList.toString().replace("[\\[\\]]".toRegex(), "")
                }
            }

            override fun onError(code: Int, desc: String?) {
                val list: MutableList<Any?> = ArrayList()
                list.add(TUILogin.getFaceUrl())
                callIconView.displayImage(list).load(records.callId)
                textUserTitle.text = TUILogin.getNickName()
            }
        })
    }
}