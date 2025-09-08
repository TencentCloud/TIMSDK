package com.tencent.qcloud.tuikit.tuicallkit.common.data

object Constants {
    const val CALL_WAITING_MAX_TIME = 30 //unit:s
    const val MAX_USER = 9
    const val MIN_AUDIO_VOLUME = 10

    const val REJECT_CALL_ACTION = "reject_call_action"
    const val ACCEPT_CALL_ACTION = "accept_call_action"

    const val KEY_TUI_CALLKIT = "keyTUICallKit"
    const val SUB_KEY_SHOW_FLOAT_WINDOW = "subKeyShowFloatWindow"
    const val AI_TRANSLATION_ROBOT = "TAI_Robot"

    /**
     * framework: native(1),uni-app(11),flutter(7),RN(22)
     * component: CallKit(14),Chat_CallKit(15)
     * language: Java(1),Kotlin(2),Swift(3),OC(4),Vue2(5),Vue3(6),React(7),C++(8),Dart(9),uts(10)
     */
    const val CALL_FRAMEWORK_NATIVE: Int = 1
    const val CALL_COMPONENT: Int = 14
    const val CALL_COMPONENT_CHAT: Int = 15
    const val CALL_LANGUAGE_KOTLIN: Int = 2
    var framework: Int = CALL_FRAMEWORK_NATIVE
    var component: Int = CALL_COMPONENT
    var language: Int = CALL_LANGUAGE_KOTLIN

    enum class NetworkQualityHint {
        None,
        Local,
        Remote
    }

    enum class Orientation {
        Portrait,
        LandScape,
        Auto
    }

    enum class ControlButton {
        Microphone,
        AudioPlaybackDevice,
        Camera,
        SwitchCamera,
        InviteUser
    }
}