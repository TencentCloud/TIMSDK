
const duration = 5 * 60;

const isInFiveTime = (curTime, baseTime) => curTime - baseTime <= duration;

export const addTimeDivider = (messageList: State.message[], baseTime = 0) => {
    return messageList.reduce((acc, cur) => {
        const curTime =  cur.message_client_time;
        if(isInFiveTime(curTime, baseTime)) {
            return [...acc, cur]
        } else {
            baseTime = curTime;
            return [...acc, {isTimeDivider: true, time: curTime}, cur]
        }
    }, []);
}