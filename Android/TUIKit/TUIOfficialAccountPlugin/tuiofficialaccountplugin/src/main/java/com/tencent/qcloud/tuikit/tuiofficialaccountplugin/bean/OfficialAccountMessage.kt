package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean

import java.io.Serializable

data class ImageInfo(
    val url: String = "",
    val width: Int = 0,
    val height: Int = 0
) : Serializable

data class OfficialAccountMessage(
    val businessID: String = "",
    val title: String = "",
    val content: String = "",
    val link: String = "",
    val imageInfo: ImageInfo? = null,
    val version: Int = 1
) : Serializable
