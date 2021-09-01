/**
 * 格式化video通话时间
 * @export
 * @param {number} int
 * @returns
 */
function formatInt(int) {
    return int < 10 ? `0${int}` : int
}
export function formatDuration(duration) {
    if (duration < 60) {
        return `00:00:${formatInt(duration)}`
    }
    if (duration < 60 * 60) {
        const min = parseInt(duration / 60)
        const sec = duration - min * 60
        return `00:${formatInt(min)}:${formatInt(sec)}`
    }
    const hour = parseInt(duration / (60 * 60))
    const remainder = duration - hour * (60 * 60)
    const min = parseInt(remainder / 60)
    const sec = remainder - min * 60
    return `${formatInt(hour)}:${formatInt(min)}:${formatInt(sec)}`
}
