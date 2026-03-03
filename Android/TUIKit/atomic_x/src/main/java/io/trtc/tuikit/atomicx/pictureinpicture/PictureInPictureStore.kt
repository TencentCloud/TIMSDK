package io.trtc.tuikit.atomicx.pictureinpicture

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

data class PictureInPictureState(
    val isPictureInPictureMode: StateFlow<Boolean>,
)

class PictureInPictureStore private constructor() {

    companion object {
        val shared: PictureInPictureStore by lazy { PictureInPictureStore() }
    }

    private val _isPictureInPictureMode = MutableStateFlow(false)

    val state = PictureInPictureState(isPictureInPictureMode = _isPictureInPictureMode)

    fun updateIsPictureInPictureMode(isPictureInPictureMode: Boolean) {
        _isPictureInPictureMode.update { isPictureInPictureMode }
    }
}