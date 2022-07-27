import {createContext} from 'react';

export const CallBackContext = createContext<{
  contextData:[{type:string,data:[]}],
  setCallbackData:(obj:{})=>void,
  clearCallbackData:()=> void
}>({} as any)
