package com.tencent.qcloud.tuikit.tuicallkit.view.component.function

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ImageView
import android.widget.ListView
import android.widget.PopupWindow
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.qcloud.tuikit.tuicallkit.manager.feature.AudioRouteFeature
import com.tencent.trtc.TRTCCloudDef

class AudioPlayoutDevicePopupView(private val audioRouteFeature: AudioRouteFeature) {
    private var popupWindow: PopupWindow? = null

    fun show(anchorView: View, selectedRoute: Int) {
        popupWindow?.dismiss()
        val devices = CallManager.instance.mediaState.availableAudioDevices.get()

        val popupView =
            LayoutInflater.from(audioRouteFeature.context).inflate(R.layout.tuicallkit_popup_audio_devices, null)
        val listView: ListView = popupView.findViewById(R.id.lv_audio_devices)
        val adapter = AudioDeviceAdapter(audioRouteFeature.context, devices, selectedRoute)
        listView.adapter = adapter

        val popupWidth = anchorView.width * 3
        var totalHeight = 0
        for (i in 0 until adapter.count) {
            val listItem = adapter.getView(i, null, listView)
            listItem.measure(
                View.MeasureSpec.makeMeasureSpec(popupWidth, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            )
            totalHeight += listItem.measuredHeight
        }
        val popupHeight = totalHeight + (listView.dividerHeight * (adapter.count - 1))

        popupWindow = PopupWindow(popupView, popupWidth, popupHeight, true).apply {
            isFocusable = true
            setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        }

        val xOffset = -anchorView.width
        val yOffset = -anchorView.height - popupHeight
        val location = IntArray(2)
        anchorView.getLocationOnScreen(location)
        val adjustedYOffset = if (location[1] + yOffset - popupHeight < 0) {
            -location[1]
        } else {
            yOffset
        }
        popupWindow?.showAsDropDown(anchorView, xOffset, adjustedYOffset)
        val hasWiredHeadset = CallManager.instance.mediaState.availableAudioDevices.get()
            .contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET)

        listView.setOnItemClickListener { _, _, position, _ ->
            val deviceRoute = devices[position]
            if (!hasWiredHeadset || deviceRoute == TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET) {
                audioRouteFeature.setAudioRoute(deviceRoute)
                popupWindow?.dismiss()
            }
        }
    }

    fun dismiss() {
        popupWindow?.dismiss()
    }

    private class AudioDeviceAdapter(
        context: Context, private val devices: List<Int>, private val selectedRoute: Int
    ) : ArrayAdapter<Int>(context, 0, devices) {

        override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
            val view = convertView ?: LayoutInflater.from(context)
                .inflate(R.layout.tuicallkit_list_item_audio_device, parent, false)
            val deviceRoute = devices[position]
            val deviceName: TextView = view.findViewById(R.id.tv_audio_device_name)
            val deviceIcon: ImageView = view.findViewById(R.id.iv_audio_device_icon)
            val selectionMark: ImageView = view.findViewById(R.id.iv_audio_device_checked)

            deviceName.text = getAudioDeviceName(context, deviceRoute)

            val iconResId = when (deviceRoute) {
                TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER -> R.drawable.tuicallkit_ic_speaker
                TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE,
                TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET -> R.drawable.tuicallkit_ic_earpiece
                TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET -> R.drawable.tuicallkit_ic_bluetooth
                else -> R.drawable.tuicallkit_ic_speaker
            }
            deviceIcon.setImageResource(iconResId)

            if (deviceRoute == selectedRoute) {
                selectionMark.visibility = View.VISIBLE
            } else {
                selectionMark.visibility = View.GONE
            }

            val hasWiredHeadset = CallManager.instance.mediaState.availableAudioDevices.get()
                .contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET)
            val isEnabled = !hasWiredHeadset || deviceRoute == TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET

            val color = if (isEnabled) ContextCompat.getColor(context, R.color.tuicallkit_color_black) else Color.LTGRAY
            deviceName.setTextColor(color)
            deviceIcon.setColorFilter(color)
            selectionMark.setColorFilter(color)

            view.isEnabled = isEnabled
            return view
        }

        private fun getAudioDeviceName(context: Context, deviceRoute: Int): String {
            return when (deviceRoute) {
                TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER -> context.getString(R.string.tuicallkit_toast_speaker)
                TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE -> context.getString(R.string.tuicallkit_toast_use_earpiece)
                TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET -> context.getString(R.string.tuicallkit_audio_route_wired_headset)
                TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET -> context.getString(R.string.tuicallkit_audio_route_bluetooth_headset)
                else -> context.getString(R.string.tuicallkit_audio_route_unknown_device)
            }
        }
    }
}