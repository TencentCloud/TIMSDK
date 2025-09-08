package com.tencent.qcloud.tuikit.tuicallkit.manager.feature

import android.content.Context
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import androidx.annotation.RequiresApi
import com.tencent.qcloud.tuikit.tuicallkit.R
import com.tencent.qcloud.tuikit.tuicallkit.common.data.Logger
import com.tencent.qcloud.tuikit.tuicallkit.manager.CallManager
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener
import org.json.JSONException
import org.json.JSONObject

class AudioRouteFeature(val context: Context) {
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var currentRoute: Int = TRTCCloudDef.TRTC_AUDIO_ROUTE_UNKNOWN

    init {
        currentRoute = CallManager.instance.mediaState.selectedAudioDevice.get()
    }

    private val trtcCloudListener: TRTCCloudListener = object : TRTCCloudListener() {
        override fun onAudioRouteChanged(route: Int, previousRoute: Int) {
            currentRoute = route
            updateCurrentAudioDevice()
        }
    }

    private val audioDeviceCallback = @RequiresApi(Build.VERSION_CODES.M)
    object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(devices: Array<AudioDeviceInfo>?) {
            updateAvailableDeviceList()

            val currentDevices = CallManager.instance.mediaState.availableAudioDevices.get()
            val hasBluetoothDevice = currentDevices.contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET)
            if (hasBluetoothDevice && currentRoute != TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET) {
                setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET)
            }
        }

        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo?>?) {
            var isBluetoothRemoved = false
            removedDevices?.forEach { device ->
                if (device?.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
                    device?.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP) {
                    isBluetoothRemoved = true
                }
            }
            updateAvailableDeviceList()

            if (isBluetoothRemoved && currentRoute == TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET) {
                val currentDevices = CallManager.instance.mediaState.availableAudioDevices.get()
                val targetRoute = when {
                    currentDevices.contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET) -> {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET
                    }
                    currentDevices.contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER) -> {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
                    }
                    currentDevices.contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE) -> {
                        TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE
                    }
                    else -> {
                        currentRoute
                    }
                }
                if (targetRoute != currentRoute) {
                    setAudioRoute(targetRoute)
                }
            }
        }
    }

    fun register() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            updateAvailableDeviceList()
            val devices = CallManager.instance.mediaState.availableAudioDevices.get()

            if (devices.contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET)) {
                setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET)
            } else if (devices.contains(TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET)) {
                setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET)
            }
            audioManager.registerAudioDeviceCallback(audioDeviceCallback, null)
        }
        TRTCCloud.sharedInstance(context).addListener(trtcCloudListener)
    }

    fun unregister() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioManager.unregisterAudioDeviceCallback(audioDeviceCallback)
        }
        TRTCCloud.sharedInstance(context).removeListener(trtcCloudListener)
    }

    private fun updateAvailableDeviceList() {
        val availableDevices = getAvailableOutputDevices()
        CallManager.instance.mediaState.availableAudioDevices.set(availableDevices)
        updateCurrentAudioDevice()
    }

    private fun getAvailableOutputDevices(): List<Int> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return emptyList()
        }

        val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
        val filteredOutputDevices = mutableListOf<Int>()
        val addedBluetoothDeviceTypes = mutableSetOf<Int>()

        devices.forEach { device ->
            when (device.type) {
                AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> {
                    filteredOutputDevices.add(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE)
                }
                AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> {
                    filteredOutputDevices.add(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER)
                }
                AudioDeviceInfo.TYPE_WIRED_HEADSET,
                AudioDeviceInfo.TYPE_USB_DEVICE,
                AudioDeviceInfo.TYPE_WIRED_HEADPHONES -> {
                    filteredOutputDevices.add(TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET)
                }
                AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> {
                    if (!addedBluetoothDeviceTypes.contains(AudioDeviceInfo.TYPE_BLUETOOTH_SCO)) {
                        filteredOutputDevices.add(TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET)
                        addedBluetoothDeviceTypes.add(AudioDeviceInfo.TYPE_BLUETOOTH_SCO)
                    }
                }
            }
        }
        return filteredOutputDevices
    }

    fun updateCurrentAudioDevice() {
        val availableDevices = CallManager.instance.mediaState.availableAudioDevices.get() ?: emptyList()
        val deviceExists = availableDevices.contains(currentRoute)
        if (deviceExists) {
            CallManager.instance.mediaState.selectedAudioDevice.set(currentRoute)
        }
    }

    fun setAudioRoute(route: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return
        }

        val jsonObject = JSONObject()
        try {
            jsonObject.put("api", "setPlayRouteEx")
            val params = JSONObject()
            params.put("route", route)
            jsonObject.put("params", params)
            TRTCCloud.sharedInstance(context).callExperimentalAPI(jsonObject.toString())
            currentRoute = route
        } catch (e: JSONException) {
            Logger.e("AudioRouteFeature", "setPlayRouteEx API invocation exception: ${e.message}")
            e.printStackTrace()
        }
        updateCurrentAudioDevice()
    }

    fun getAudioDeviceName(selectedRoute: Int): String {
        val availableAudioDevices = CallManager.instance.mediaState.availableAudioDevices.get()
        val hasOnlyBuiltInDevices = availableAudioDevices.isNotEmpty() && availableAudioDevices.all {
            it == TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE || it == TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
        }

        if (hasOnlyBuiltInDevices) {
            return when (selectedRoute) {
                TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER -> context.getString(R.string.tuicallkit_speaker_on)
                else -> context.getString(R.string.tuicallkit_speaker_off)
            }
        }

        return when (selectedRoute) {
            TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER -> context.getString(R.string.tuicallkit_toast_speaker)
            TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE -> context.getString(R.string.tuicallkit_toast_use_earpiece)
            TRTCCloudDef.TRTC_AUDIO_ROUTE_WIRED_HEADSET -> context.getString(R.string.tuicallkit_audio_route_wired_headset)
            TRTCCloudDef.TRTC_AUDIO_ROUTE_BLUETOOTH_HEADSET -> context.getString(R.string.tuicallkit_audio_route_bluetooth_headset)
            else -> context.getString(R.string.tuicallkit_audio_route_unknown_device)
        }
    }
}