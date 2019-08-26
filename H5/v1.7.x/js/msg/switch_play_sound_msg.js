//切换播放audio对象
function onChangePlayAudio(playAudio) {
    if (curPlayAudio) {
        if (curPlayAudio != playAudio) {
            curPlayAudio.currentTime = 0;
            curPlayAudio.pause();
            curPlayAudio = playAudio;
        }
    } else {
        curPlayAudio = playAudio;
    }
}



