import TRTCCloud from 'trtc-electron-sdk';

let trtcInstance:TRTCCloud = null;

const getInstance = ():TRTCCloud => {
    if(!trtcInstance) {
        trtcInstance = new TRTCCloud();
        // var config = {"proxy_env": {"sdk_appid": 1400188366, "domain": "https://common-proxy.rtc.tencent.com"}};
        // trtcInstance.setEnvironment(JSON.stringify(config));
    }
    return trtcInstance;
}

export default getInstance();
 