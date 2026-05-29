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
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ValueCallback
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.UserManager
import io.trtc.tuikit.atomicxcore.api.call.CallDirection
import io.trtc.tuikit.atomicxcore.api.call.CallInfo
import io.trtc.tuikit.atomicxcore.api.call.CallMediaType
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantInfo
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

    fun layoutViews(context: Context, callInfo: CallInfo?) {
        if (callInfo == null) {
            return
        }
        val colorId = when (CallDirection.Missed) {
            callInfo.result -> R.color.callkit_record_text_red
            else -> R.color.callkit_color_black
        }
        textUserTitle.setTextColor(ContextCompat.getColor(context, colorId))
        val imageId = when (CallMediaType.Video) {
            callInfo.mediaType -> R.drawable.tuicallkit_record_ic_video_call
            else -> R.drawable.tuicallkit_record_ic_audio_call
        }
        imageMediaType.setImageDrawable(ContextCompat.getDrawable(context, imageId))
        var resultMsg = context.getString(R.string.callkit_record_result_unknown)
        if (CallDirection.Missed == callInfo.result) {
            resultMsg = context.getString(R.string.callkit_record_result_missed)
        } else if (CallDirection.Incoming == callInfo.result) {
            resultMsg = context.getString(R.string.callkit_record_result_incoming)
        } else if (CallDirection.Outgoing == callInfo.result) {
            resultMsg = context.getString(R.string.callkit_record_result_outgoing)
        }
        textCallStatus.text = resultMsg
        textCallTime.text = DateTimeUtil.getTimeFormatText(Date(callInfo.startTime))
        val list: MutableList<String?> = ArrayList()
        if (callInfo.inviteeIds != null) {
            list.addAll(callInfo.inviteeIds)
        }
        list.add(callInfo.inviterId.trim { it <= ' ' })
        list.remove(TUILogin.getLoginUser())
        callIconView.tag = list
        UserManager.instance.updateUserListInfo(list, object : ValueCallback<List<CallParticipantInfo>?> {
            override fun onSuccess(userFullInfoList: List<CallParticipantInfo>?) {
                if (userFullInfoList.isNullOrEmpty()) {
                    return
                }
                val avatarList: MutableList<Any?> = ArrayList()
                val newUserList: MutableList<String> = ArrayList()
                val nameList: MutableList<String> = ArrayList()
                for (i in userFullInfoList.indices) {
                    avatarList.add(userFullInfoList[i].avatarURL)
                    newUserList.add(userFullInfoList[i].id)
                    nameList.add(userFullInfoList[i].name)
                }

                if (!callInfo.chatGroupId.isNullOrEmpty() || (callInfo.inviteeIds.size > 1)) {
                    avatarList.add(TUILogin.getFaceUrl())
                }
                val oldUserList: List<String> = ArrayList(
                    callIconView.tag as List<String>
                )
                if (oldUserList.size == newUserList.size && oldUserList.containsAll(newUserList)) {
                    callIconView.setImageId(callInfo.callId)
                    callIconView.displayImage(avatarList).load(callInfo.callId)
                    textUserTitle.text = nameList.toString().replace("[\\[\\]]".toRegex(), "")
                }
            }

            override fun onError(code: Int, desc: String?) {
                val list: MutableList<Any?> = ArrayList()
                list.add(TUILogin.getFaceUrl())
                callIconView.displayImage(list).load(callInfo.callId)
                textUserTitle.text = TUILogin.getNickName()
            }
        })
    }
}