package io.trtc.tuikit.atomicx.imageuploader.util

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileNotFoundException
import java.net.HttpURLConnection
import java.net.SocketException
import java.net.SocketTimeoutException
import java.net.URL
import java.net.UnknownHostException
import javax.net.ssl.SSLException

internal class ImageCosUploaderManager {

    companion object {
        private const val TAG = "CosUploadManager"
        private const val MAX_RETRY_COUNT = 3
        private const val RETRY_DELAY_MS = 500L
        private const val CONNECT_TIMEOUT_MS = 30_000
        private const val READ_TIMEOUT_MS = 60_000
    }

    suspend fun uploadFile(localPath: String, cosUploadURL: String): Int {
        val url = try {
            URL(cosUploadURL)
        } catch (e: Exception) {
            Log.e(TAG, "Invalid cosUploadURL: $cosUploadURL")
            return -1
        }

        val file = File(localPath)
        if (!file.exists()) {
            Log.e(TAG, "File does not exist at path: $localPath")
            return -1
        }

        return uploadFile(file, url, MAX_RETRY_COUNT)
    }

    private suspend fun uploadFile(file: File, url: URL, maxRetryCount: Int): Int = withContext(Dispatchers.IO) {
        var currentRetry = 0

        while (currentRetry <= maxRetryCount) {
            var connection: HttpURLConnection? = null
            try {
                connection = (url.openConnection() as HttpURLConnection).apply {
                    requestMethod = "PUT"
                    doOutput = true
                    setRequestProperty("Content-Type", "application/octet-stream")
                    setRequestProperty("Content-Length", file.length().toString())
                    connectTimeout = CONNECT_TIMEOUT_MS
                    readTimeout = READ_TIMEOUT_MS
                }

                file.inputStream().use { input ->
                    connection.outputStream.use { output ->
                        input.copyTo(output)
                    }
                }

                val statusCode = connection.responseCode
                if (statusCode in 200..299) {
                    Log.d(TAG, "Upload completed with status code: $statusCode")
                    return@withContext statusCode
                }

                if (statusCode >= 500 && currentRetry < maxRetryCount) {
                    currentRetry++
                    delay(RETRY_DELAY_MS)
                    continue
                }

                Log.e(TAG, "Upload failed with status code: $statusCode")
                return@withContext statusCode
            } catch (e: Exception) {
                val shouldRetry = isNetworkErrorAndRecoverable(e) && currentRetry < maxRetryCount

                if (shouldRetry) {
                    currentRetry++
                    delay(RETRY_DELAY_MS)
                    continue
                } else {
                    Log.e(TAG, "Upload failed with error: ${e.message}")
                    return@withContext -1
                }
            } finally {
                connection?.disconnect()
            }
        }

        return@withContext -1
    }

    private fun isNetworkErrorAndRecoverable(error: Exception): Boolean {
        return when (error) {
            is UnknownHostException,
            is FileNotFoundException,
            is SecurityException -> false

            is SocketTimeoutException,
            is SocketException,
            is SSLException -> true

            else -> true
        }
    }
}