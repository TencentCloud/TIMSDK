package io.trtc.tuikit.atomicx.callview.public.multi

import android.content.Context
import android.view.Gravity
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.constraintlayout.utils.widget.ImageFilterView
import androidx.core.content.ContextCompat
import com.trtc.tuikit.common.imageloader.ImageLoader
import com.trtc.tuikit.common.util.ScreenUtil
import io.trtc.tuikit.atomicx.R
import io.trtc.tuikit.atomicx.callview.core.common.utils.CallUtils
import io.trtc.tuikit.atomicxcore.api.call.CallStore
import io.trtc.tuikit.atomicxcore.api.call.CallParticipantInfo
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class MultiCallWaitingView(context: Context) : LinearLayout(context) {
    private val mainScope = MainScope()
    private var caller: CallParticipantInfo = CallParticipantInfo()
    private val squareWidth = context.resources.getDimensionPixelOffset(R.dimen.callview_small_image_size)
    private val defaultMargin = context.resources.getDimensionPixelOffset(R.dimen.callview_small_image_left_margin)

    private lateinit var textWaitingUserName: TextView
    private lateinit var imageCallerAvatar: ImageFilterView
    private lateinit var layoutAvatarList: LinearLayout

    init {
        this.orientation = VERTICAL
        this.gravity = Gravity.CENTER
        val self = CallStore.shared.observerState.selfInfo.value.copy()
        if (CallUtils.isCaller(self.id)) {
            caller = self
        } else {
            val callerId = CallStore.shared.observerState.activeCall.value.inviterId
            caller.id = callerId
        }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initView()
        registerParticipantsObserver()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mainScope.cancel()
    }

    private fun registerParticipantsObserver() {
        mainScope.launch {
            CallStore.shared.observerState.allParticipants.collect { participants ->
                for (participant in participants) {
                    if (CallUtils.isCaller(participant.id)) {
                        ImageLoader.load(context, imageCallerAvatar, participant.avatarUrl, R.drawable.callview_ic_avatar)
                        textWaitingUserName.text = participant.name
                    }
                }
                updateAvatarListView()
            }
        }
    }

    private fun initView() {
        imageCallerAvatar = createImageView(caller, ScreenUtil.dip2px(100f), 0, 20)
        textWaitingUserName = createTextView(caller.name, 48)
        textWaitingUserName.textSize = 18f
        layoutAvatarList = LinearLayout(context)
        layoutAvatarList.layoutParams =
            LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)

        addView(imageCallerAvatar)
        addView(textWaitingUserName)
        addView(createTextView(context.getString(R.string.callview_invitee_user_list), 24))
        addView(layoutAvatarList)
    }

    private fun updateAvatarListView() {
        layoutAvatarList.removeAllViews()
        val list = HashSet<CallParticipantInfo>()
        val allParticipants = CallStore.shared.observerState.allParticipants.value.toSet()
        val inviterId = CallStore.shared.observerState.activeCall.value.inviterId
        val selfId = CallStore.shared.observerState.selfInfo.value.id
        val inviteeList = allParticipants.filter { it.id != inviterId && it.id != selfId}
        list.addAll(inviteeList)

        for (user in list) {
            layoutAvatarList.addView(createImageView(user, squareWidth, defaultMargin, 0))
        }
    }

    private fun createImageView(user: CallParticipantInfo, width: Int, start: Int, bottom: Int): ImageFilterView {
        val imageView = ImageFilterView(context)
        val layoutParams = LayoutParams(width, width)
        layoutParams.marginStart = start
        layoutParams.bottomMargin = bottom
        imageView.round = 12f
        imageView.scaleType = ImageView.ScaleType.CENTER_CROP
        imageView.layoutParams = layoutParams
        ImageLoader.load(context, imageView, user.avatarUrl, R.drawable.callview_ic_avatar)
        return imageView
    }

    private fun createTextView(text: String, margin: Int): TextView {
        val textView = TextView(context)
        textView.text = text
        textView.textSize = 12f
        textView.setTextColor(ContextCompat.getColor(context, R.color.callview_color_white))
        val param = LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        param.bottomMargin = margin
        param.gravity = Gravity.CENTER
        textView.layoutParams = param
        return textView
    }
}