package io.trtc.tuikit.atomicx.common.util

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList

abstract class TUIObserver {
    abstract fun onNotify(event: String, key: String?, params: NotifyParams?)
}

class PublishParams(
    val isSticky: Boolean = false,
    val data: Map<String, Any?>? = null,
    val callback: ((Map<String, Any?>) -> Unit)? = null
)

class NotifyParams(
    val data: Map<String, Any?>? = null,
    val callback: ((Map<String, Any?>) -> Unit)? = null
)

class TUIEventBus private constructor() {

    private data class EventEnvelope(
        val event: String,
        val key: String?,
        val params: NotifyParams?
    )

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val sharedFlow = MutableSharedFlow<EventEnvelope>(extraBufferCapacity = 64)
    private val observerMap = ConcurrentHashMap<String, CopyOnWriteArrayList<TUIObserver>>()
    private val stickyDataMap = ConcurrentHashMap<String, Map<String, Any?>>()

    companion object {
        private const val TAG = "TUIEventBus"

        @JvmStatic
        val shared: TUIEventBus by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
            TUIEventBus()
        }
    }

    init {
        scope.launch {
            sharedFlow.collect { envelope ->
                val eventKey = buildEventKey(envelope.event, envelope.key)
                val observers = observerMap[eventKey] ?: return@collect
                for (observer in observers) {
                    observer.onNotify(envelope.event, envelope.key, envelope.params)
                }
            }
        }
    }

    fun subscribe(event: String, key: String?, observer: TUIObserver) {
        val eventKey = buildEventKey(event, key)
        val observers = observerMap.getOrPut(eventKey) { CopyOnWriteArrayList() }
        observers.add(observer)

        stickyDataMap[eventKey]?.let { data ->
            observer.onNotify(event, key, NotifyParams(data = data))
        }
    }

    fun unsubscribe(event: String, key: String?, observer: TUIObserver) {
        val eventKey = buildEventKey(event, key)
        val observers = observerMap[eventKey] ?: return
        observers.remove(observer)
        if (observers.isEmpty()) {
            observerMap.remove(eventKey)
        }
    }

    fun publish(event: String, key: String?, params: PublishParams? = null) {
        val eventKey = buildEventKey(event, key)

        if (params?.isSticky == true && params.data != null) {
            stickyDataMap[eventKey] = params.data
        }

        val notifyParams = if (params?.data != null || params?.callback != null) {
            NotifyParams(data = params.data, callback = params.callback)
        } else {
            null
        }

        sharedFlow.tryEmit(EventEnvelope(event, key, notifyParams))
    }

    private fun buildEventKey(event: String, key: String?): String {
        return if (key == null) event else "$event:$key"
    }
}
