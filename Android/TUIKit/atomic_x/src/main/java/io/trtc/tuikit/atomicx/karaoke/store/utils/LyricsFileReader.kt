package io.trtc.tuikit.atomicx.karaoke.store.utils

import android.util.Log
import com.tencent.trtc.TXChorusMusicPlayer
import java.io.BufferedReader
import java.io.File
import java.io.FileInputStream
import java.io.InputStreamReader

class LyricsFileReader {
    companion object {
        private const val TAG = "LyricsFileReader"
        private val TIME_PATTERN = """(\d{2}):(\d{2}):(\d{2}).(\d{3})""".toRegex()
        private val WORD_PATTERN = """\<(\d+),(\d+),(\d+)\>""".toRegex()
    }

    fun parseLyricInfo(path: String): List<TXChorusMusicPlayer.TXLyricLine>? {
        val lyricFile = File(path).takeIf { it.exists() && it.length() > 0 } ?: run {
            Log.w(TAG, "Lyric file not found or empty: $path")
            return null
        }

        return runCatching {
            FileInputStream(lyricFile).use { input ->
                BufferedReader(InputStreamReader(input)).use { reader ->
                    buildList {
                        var line: String?
                        while (reader.readLine().also { line = it } != null) {
                            line?.takeIf { TIME_PATTERN.containsMatchIn(it) }?.let { timeLine ->
                                val lyricsLineInfo = parseLyricTimeLine(timeLine)
                                val lyricString = reader.readLine()
                                val updatedLineInfo = parseLyricWords(lyricString, lyricsLineInfo)
                                add(updatedLineInfo)
                            }
                        }
                    }
                }
            }
        }.onFailure { e ->
            Log.e(TAG, "Failed to parse lyric file: ${e.message}", e)
        }.getOrNull()
    }

    private fun parseLyricTimeLine(lineString: String): TXChorusMusicPlayer.TXLyricLine {
        val (startTime, endTime) = lineString.split(" --> ").map { dateToMilliseconds(it) }
        val lyricLine = TXChorusMusicPlayer.TXLyricLine()
        lyricLine.startTimeMs = startTime
        lyricLine.durationMs = endTime - startTime
        lyricLine.characterArray = null
        return lyricLine
    }

    private fun parseLyricWords(
        lineString: String?,
        lineInfo: TXChorusMusicPlayer.TXLyricLine,
    ): TXChorusMusicPlayer.TXLyricLine {
        lineString ?: return lineInfo

        val wordMatches = WORD_PATTERN.findAll(lineString).toList()
        val words = lineString.split(WORD_PATTERN)

        val wordInfoList = wordMatches.mapIndexed { index, matchResult ->
            TXChorusMusicPlayer.TXChorusLyricCharacter().apply {
                startTimeMs = matchResult.groupValues[1].toLong()
                durationMs = matchResult.groupValues[2].toLong()
                utf8Character = words.getOrNull(index + 1) ?: ""
            }
        }
        val result = TXChorusMusicPlayer.TXLyricLine()
        result.startTimeMs = lineInfo.startTimeMs
        result.durationMs = lineInfo.durationMs
        result.characterArray = wordInfoList
        return result
    }

    private fun dateToMilliseconds(inputString: String): Long {
        return TIME_PATTERN.matchEntire(inputString)?.let { match ->
            match.groupValues.let { groups ->
                groups[1].toLong() * 3600000L +
                        groups[2].toLong() * 60000 +
                        groups[3].toLong() * 1000 +
                        groups[4].toLong()
            }
        } ?: run {
            Log.e(TAG, "Invalid time format: $inputString")
            -1
        }
    }
}