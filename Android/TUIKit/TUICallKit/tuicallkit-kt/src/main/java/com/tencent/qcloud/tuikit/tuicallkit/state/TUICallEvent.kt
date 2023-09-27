package com.tencent.qcloud.tuikit.tuicallkit.state

public class TUICallEvent {
    public var eventType: EventType? = null
    public var event: Event? = null
    public var param: HashMap<String, Any?>? = null

    constructor(eventType: EventType, event: Event, param: HashMap<String, Any?>?) {
        this.eventType = eventType
        this.event = event
        this.param = param
    }

    enum class EventType { ERROR, TIP }

    enum class Event {
        USER_REJECT,
        USER_NO_RESPONSE,
        USER_LINE_BUSY,
        USER_LEAVE,
        USER_EXCEED_LIMIT,

        ERROR_COMMON,
    }

    companion object {
        const val EVENT_KEY_USER_ID = "userId"
        const val EVENT_KEY_CODE = "code"
        const val EVENT_KEY_MESSAGE = "message"
    }
}