import React from 'react';
import ReactDOM from "react-dom";

import { eventListiner } from './pages/call/callIpc';
import { Call } from './pages/call';

eventListiner.init(); //注册监听事件 与主进程通信

ReactDOM.render(<Call />, document.getElementById("root"));