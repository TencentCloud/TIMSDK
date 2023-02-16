import trtcInstance from './trtcInstance';

interface TRTCState {
    camera: boolean,
    mic: boolean,
    micVolume: number,
    speaker: boolean,
    speakerVolume: number,
    network: boolean,
    checkTaskId: any
}

class TRTCState {
  constructor() {
    this.camera = false;
    this.mic = false;
    this.micVolume = 0;
    this.speaker = false;
    this.speakerVolume = 0;
    this.network = false;
    this.checkTaskId = 0;
  }

  check(callBack) {
      this.isCameraReady();
      this.isMicReady();
      this.isSpeakerReady();
      this.getMicVolume();
      this.getSpeakerVolume();
      if (typeof callBack === 'function') {
        callBack({
          camera: this.camera,
          mic: this.mic,
          speaker: this.speaker,
          micVolume: this.micVolume,
          speakerVolume: this.speakerVolume,
        })
      }
  }

  startCheckTask(callBack) {
    this.check(callBack);
    this.checkTaskId = setInterval(()=>{
      this.check(callBack);
    }, 500);
  }

  stopCheckTask() {
    clearInterval(this.checkTaskId);
  }

  isCameraReady() {
      let deviceInfo = trtcInstance.getCurrentCameraDevice();
      if (deviceInfo && deviceInfo.deviceId!='') {
        this.camera = true;
        return true;
      }
      let deviceList = trtcInstance.getCameraDevicesList();
      if (deviceList.length >= 1 ) {
        if (deviceList.length > 1) {
          trtcInstance.setCurrentCameraDevice(deviceList[0].deviceId);
        }
        this.camera = true;
        return true;
      }
      return false;
  }

  isMicReady() {
      let deviceInfo = trtcInstance.getCurrentMicDevice();
      if (deviceInfo && deviceInfo.deviceId!='') {
        this.mic = true;
        return true;
      }
      let deviceList = trtcInstance.getMicDevicesList();
      if (deviceList.length >= 1 ) {
        if (deviceList.length > 1) {
          trtcInstance.setCurrentMicDevice(deviceList[0].deviceId);
        }
        this.mic = true;
        return true;
      }
      return false;
  }

  isSpeakerReady() {
      let deviceInfo = trtcInstance.getCurrentSpeakerDevice();
      if (deviceInfo && deviceInfo.deviceId!='') {
        this.speaker = true;
        return true;
      }
      let deviceList = trtcInstance.getSpeakerDevicesList();
      if (deviceList.length >= 1 ) {
        if (deviceList.length > 1) {
          trtcInstance.setCurrentSpeakerDevice(deviceList[0].deviceId);
        }
        this.speaker = true;
        return true;
      }
      return false;
  }

  getSpeakerVolume () {
    this.speakerVolume = trtcInstance.getCurrentSpeakerVolume();
    return this.speakerVolume;
  }

  getMicVolume() {
    this.micVolume = trtcInstance.getCurrentMicDeviceVolume();
    return this.micVolume;
  }

}
const trtcState = new TRTCState();
export default trtcState;
