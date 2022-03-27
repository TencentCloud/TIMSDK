const generateThreeId = () => {
    let num = '';
    for (let i = 0; i < 3; i++) {
        if(i == 0){
            num += Math.floor(Math.random() * 9 + 1);
        }else{
            num += Math.floor(Math.random() * 10);
        }
    }
    return num;
}

const generateMeetingId = () => `${generateThreeId()} ${generateThreeId()} ${generateThreeId()}`;

const generateGroupId = meetingId => `${meetingId}_meeting-group`;

const generateStoreKey = (userId, sdkAppId) => `${userId}_${sdkAppId}_meeting-history`

export {
    generateMeetingId,
    generateGroupId,
    generateStoreKey
}