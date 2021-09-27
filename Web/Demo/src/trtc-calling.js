import  tim from './tim'
import TRTCCalling from 'trtc-calling-js'

let options = {
  SDKAppID: window.genTestUserSig('').SDKAppID,  // 接入时需要将0替换为您的云通信应用的 SDKAppID
  tim: tim,
}

const trtcCalling = new TRTCCalling(options)

// 4 无日志级别
trtcCalling.setLogLevel(0)

export default trtcCalling
