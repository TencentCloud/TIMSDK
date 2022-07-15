import {createContext} from 'react';

const CallBackContext = createContext<{
  contextData:[{type:string,data:[]}],
  setCallbackData:(obj:{})=>void,
  clearCallbackData:()=> void
}>({} as any)

export default CallBackContext