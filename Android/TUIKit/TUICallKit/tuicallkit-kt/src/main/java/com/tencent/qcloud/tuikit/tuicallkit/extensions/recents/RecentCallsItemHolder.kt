package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents

import android.content.Context
import android.text.TextUtils
import android.view.View
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.RecyclerView
import com.tencent.imsdk.v2.V2TIMManager
import com.tencent.imsdk.v2.V2TIMUserFullInfo
import com.tencent.imsdk.v2.V2TIMValueCallback
import com.tencent.qcloud.tuicore.TUILogin
import com.tencent.qcloud.tuicore.util.DateTimeUtil
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallRecords
import com.tencent.qcloud.tuikit.tuicallkit.R
import java.util.Date

class RecentCallsItemHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    public lateinit var callIconView: RecordsIconView
    public lateinit var textUserTitle: TextView
    public lateinit var imageMediaType: ImageView
    public lateinit var textCallStatus: TextView
    public lateinit var textCallTime: TextView
    public lateinit var imageDetails: ImageView
    public lateinit var layoutDelete: RelativeLayout
    public lateinit var checkBoxSelectCall: CheckBox
    public lateinit var layoutView: ConstraintLayout

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

    fun layoutViews(context: Context, records: CallRecords?, position: Int) {
        if (records == null) {
            return
        }
        val colorId = if (CallRecords.Result.Missed == records.result) {
            R.color.tuicallkit_record_text_red
        } else {
            R.color.tuicalling_color_black
        }
        textUserTitle.setTextColor(context.resources.getColor(colorId))
        val imageId = if (TUICallDefine.MediaType.Video == records.mediaType) {
            R.drawable.tuicallkit_record_ic_video_call
        } else {
            R.drawable.tuicallkit_record_ic_audio_call
        }
        imageMediaType.setImageDrawable(context.resources.getDrawable(imageId))
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
        val list: MutableList<String> = ArrayList()
        if (records.inviteList != null) {
            list.addAll(records.inviteList)
        }
        list.add(records.inviter.trim { it <= ' ' })
        list.remove(TUILogin.getLoginUser())
        callIconView.tag = list
        V2TIMManager.getInstance().getUsersInfo(list, object : V2TIMValueCallback<List<V2TIMUserFullInfo>?> {
            override fun onSuccess(userFullInfoList: List<V2TIMUserFullInfo>?) {
                if (userFullInfoList.isNullOrEmpty()) {
                    return
                }
                val avatarList: MutableList<Any?> = ArrayList()
                val newUserList: MutableList<String> = ArrayList()
                val nameList: MutableList<String> = ArrayList()
                for (i in userFullInfoList.indices) {
                    avatarList.add(userFullInfoList[i].faceUrl)
                    newUserList.add(userFullInfoList[i].userID)
                    val name =
                        if (TextUtils.isEmpty(userFullInfoList[i].nickName)) userFullInfoList[i].userID else userFullInfoList[i].nickName
                    nameList.add(name)
                }
                if (!TextUtils.isEmpty(records.groupId)) {
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

            override fun onError(errorCode: Int, errorMsg: String) {
                val list: MutableList<Any?> = ArrayList()
                list.add(TUILogin.getFaceUrl())
                callIconView.displayImage(list).load(records.callId)
                textUserTitle.text = TUILogin.getNickName()
            }
        })
    }
}