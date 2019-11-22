import MTA from 'mta-h5-analysis'

MTA.init({
  'sid': '500702399', //必填，统计用的appid
  'cid': '500702403', //如果开启自定义事件，此项目为必填，否则不填
  'autoReport': 1,//是否开启自动上报(1:init完成则上报一次,0:使用pgv方法才上报)
  'senseHash': 0, //hash锚点是否进入url统计
  'senseQuery': 0, //url参数是否进入url统计
  'performanceMonitor': 0,//是否开启性能监控
  'ignoreParams': [] //开启url参数上报时，可忽略部分参数拼接上报
})

export default MTA