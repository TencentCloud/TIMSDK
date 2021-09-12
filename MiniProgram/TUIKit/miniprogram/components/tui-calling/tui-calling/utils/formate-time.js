export default function formatTime(secondTime) {
  const time = secondTime
  let newTime; let hour; let minite; let seconds
  if (time >= 3600) {
    hour = parseInt(time / 3600) < 10 ? `0${parseInt(time / 3600)}` : parseInt(time / 3600)
    minite = parseInt(time % 60 / 60) < 10 ? `0${parseInt(time % 60 / 60)}` : parseInt(time % 60 / 60)
    seconds = time % 3600 < 10 ? `0${time % 3600}` : time % 3600
    if (seconds > 60) {
      minite = parseInt(seconds / 60) < 10 ? `0${parseInt(seconds / 60)}` : parseInt(seconds / 60)
      seconds = seconds % 60 < 10 ? `0${seconds % 60}` : seconds % 60
    }
    newTime = `${hour}:${minite}:${seconds}`
  } else if (time >= 60 && time < 3600) {
    minite = parseInt(time / 60) < 10 ? `0${parseInt(time / 60)}` : parseInt(time / 60)
    seconds = time % 60 < 10 ? `0${time % 60}` : time % 60
    newTime = `00:${minite}:${seconds}`
  } else if (time < 60) {
    seconds = time < 10 ? `0${time}` : time
    newTime = `00:00:${seconds}`
  }
  return newTime
}
