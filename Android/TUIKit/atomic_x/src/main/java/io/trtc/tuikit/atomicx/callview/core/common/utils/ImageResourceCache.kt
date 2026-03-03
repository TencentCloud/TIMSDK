package io.trtc.tuikit.atomicx.callview.core.common.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

class ImageResourceCache(private val context: Context) {

    private val drawablePathCache: MutableMap<Int, String> = mutableMapOf()
    private var defaultAvatarPath: String? = null
    
    companion object {
        private const val CACHE_DIR_ICONS = "icons"
        private const val CACHE_DIR_AVATARS = "avatars"
        private const val DEFAULT_AVATAR_FILE_NAME = "default_avatar.png"
        private const val GIF_HEADER_SIZE = 6
        private const val BUFFER_SIZE = 8192
        private const val GIF_HEADER_PREFIX = "GIF8"
    }

    fun getDrawablePath(drawableResId: Int): String {
        drawablePathCache[drawableResId]?.let {
            return it
        }
        
        return try {
            val cacheDir = getIconsCacheDir()
            val resourceName = context.resources.getResourceEntryName(drawableResId)
            val isGif = isGifFormat(drawableResId, resourceName)
            val fileExtension = if (isGif) "gif" else "png"
            val iconFile = File(cacheDir, "${resourceName}.${fileExtension}")

            if (iconFile.exists()) {
                val absolutePath = iconFile.absolutePath
                drawablePathCache[drawableResId] = absolutePath
                return absolutePath
            }

            val absolutePath = if (isGif) {
                copyGifResource(drawableResId, iconFile)
            } else {
                convertBitmapToFile(drawableResId, iconFile)
            }
            
            if (absolutePath.isNotEmpty()) {
                drawablePathCache[drawableResId] = absolutePath
            }
            absolutePath
        } catch (e: Exception) {
            Logger.e("getDrawablePath fail, e=${e.message}")
            ""
        }
    }

    fun getDefaultAvatarPath(defaultAvatarResId: Int): String? {
        if (defaultAvatarPath != null) {
            return defaultAvatarPath
        }
        
        return try {
            val cacheDir = getAvatarsCacheDir()
            val defaultAvatarFile = File(cacheDir, DEFAULT_AVATAR_FILE_NAME)
            
            if (defaultAvatarFile.exists()) {
                defaultAvatarPath = defaultAvatarFile.absolutePath
                return defaultAvatarPath
            }
            
            val bitmap = BitmapFactory.decodeResource(context.resources, defaultAvatarResId)
                ?: return null
            
            val absolutePath = saveBitmapToFile(bitmap, defaultAvatarFile)
            if (absolutePath != null) {
                defaultAvatarPath = absolutePath
            }
            absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun cacheNetworkImage(imageUrl: String?, callback: (String?) -> Unit) {
        if (imageUrl.isNullOrEmpty()) {
            callback(null)
            return
        }
        
        Glide.with(context)
            .downloadOnly()
            .load(imageUrl)
            .listener(object : RequestListener<File> {
                override fun onResourceReady(
                    resource: File?,
                    model: Any?,
                    target: Target<File>?,
                    dataSource: com.bumptech.glide.load.DataSource?,
                    isFirstResource: Boolean
                ): Boolean {
                    callback(resource?.absolutePath)
                    return false
                }
                
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any?,
                    target: Target<File>?,
                    isFirstResource: Boolean
                ): Boolean {
                    callback(null)
                    return false
                }
            })
            .preload()
    }
    

    private fun isGifFormat(drawableResId: Int, resourceName: String): Boolean {
        return try {
            context.resources.openRawResource(drawableResId).use { inputStream ->
                val header = ByteArray(GIF_HEADER_SIZE)
                val bytesRead = inputStream.read(header)
                if (bytesRead >= GIF_HEADER_SIZE) {
                    val headerString = String(header, Charsets.US_ASCII)
                    headerString.startsWith(GIF_HEADER_PREFIX)
                } else {
                    false
                }
            }
        } catch (e: Exception) {
            resourceName.contains("loading", ignoreCase = true) ||
            resourceName.contains("gif", ignoreCase = true)
        }
    }

    private fun copyGifResource(drawableResId: Int, targetFile: File): String {
        return try {
            context.resources.openRawResource(drawableResId).use { inputStream ->
                FileOutputStream(targetFile).use { outputStream ->
                    val buffer = ByteArray(BUFFER_SIZE)
                    var bytesRead: Int
                    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                    }
                    outputStream.flush()
                }
            }
            
            if (!verifyGifFile(targetFile)) {
                targetFile.delete()
                return ""
            }
            
            targetFile.absolutePath
        } catch (e: IOException) {
            Logger.e("copyGifResource fail, e=${e.message}")
            targetFile.delete()
            ""
        }
    }

    private fun verifyGifFile(file: File): Boolean {
        return try {
            FileInputStream(file).use { inputStream ->
                val header = ByteArray(GIF_HEADER_SIZE)
                val bytesRead = inputStream.read(header)
                if (bytesRead >= GIF_HEADER_SIZE) {
                    val headerString = String(header, Charsets.US_ASCII)
                    headerString.startsWith(GIF_HEADER_PREFIX)
                } else {
                    false
                }
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun convertBitmapToFile(drawableResId: Int, targetFile: File): String {
        val bitmap = BitmapFactory.decodeResource(context.resources, drawableResId)
            ?: return ""
        
        return saveBitmapToFile(bitmap, targetFile) ?: ""
    }

    private fun saveBitmapToFile(bitmap: Bitmap, targetFile: File): String? {
        return try {
            FileOutputStream(targetFile).use { outputStream ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                outputStream.flush()
            }
            targetFile.absolutePath
        } catch (e: IOException) {
            e.printStackTrace()
            null
        } finally {
            bitmap.recycle()
        }
    }

    private fun getIconsCacheDir(): File {
        val cacheDir = context.cacheDir
        val iconsCacheDir = File(cacheDir, CACHE_DIR_ICONS)
        if (!iconsCacheDir.exists()) {
            iconsCacheDir.mkdirs()
        }
        return iconsCacheDir
    }

    private fun getAvatarsCacheDir(): File {
        val cacheDir = context.cacheDir
        val avatarCacheDir = File(cacheDir, CACHE_DIR_AVATARS)
        if (!avatarCacheDir.exists()) {
            avatarCacheDir.mkdirs()
        }
        return avatarCacheDir
    }
    
    fun clearCache() {
        drawablePathCache.clear()
        defaultAvatarPath = null
    }
}

