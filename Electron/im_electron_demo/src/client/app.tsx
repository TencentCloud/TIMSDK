import React, { useEffect, lazy, Suspense } from "react";
import { useSelector } from "react-redux";
import ReactDOM from "react-dom";
import "tea-component/dist/tea.css";
import {
    HashRouter as Router,
    Switch,
    Route,
    useHistory
} from "react-router-dom";
import { Provider } from "react-redux";

import store from "./store";
import { ToolsBar } from "./components/toolsBar/toolsBar";
import { initSdk, callWindowLisitiner } from "./utils/im-sdk";
import { updateHistoryMessageToStore } from "./utils/LocalStoreInstance";

import "./assets/_basic.scss";
import "./app.scss";
import { ipcRenderer } from "electron";
import { LoadingContainer } from "./components/loadingContainer";
import { useMessageDirect } from "./utils/react-use/useDirectMsgPage";

const Home = lazy(() => import(/* webpackChunkName: "home" */'./pages/home'));
const Login = lazy(() => import(/* webpackChunkName: "login" */'./pages/login'));

export const App = () => {
    const history = useHistory();
    const directToMsgPage = useMessageDirect();
    const { sdkappId, addressIp, port, publicKey } = useSelector(
        (state: State.RootState) => state.settingConfig
    );

    const shouldCallExperimentalAPI = !!addressIp && !!port && !!publicKey;

    useEffect(() => {
        callWindowLisitiner();
        ipcRenderer.on('updateHistoryMessage', updateHistoryMessageToStore)
        // @ts-ignore
        window.aegis.report("init")
    }, []);
    
    useEffect(() => {
        if(sdkappId !== '' || shouldCallExperimentalAPI) {
            initSdk(directToMsgPage, history, true);
        }
    }, [sdkappId, shouldCallExperimentalAPI]);

    return (
        <div id="app-container">
            <ToolsBar></ToolsBar>
            <Suspense fallback={<LoadingContainer loading={true} style={{height:'100%'}}>{}</LoadingContainer>}>
                <Switch>
                    <Route path="/home" component={Home}></Route>
                    <Route path="/" component={Login} />
                </Switch>
            </Suspense>
        </div>
    );
};

ReactDOM.render(
    <Provider store={store}>
        <Router>
            <App />
        </Router>
    </Provider>,
    document.getElementById("root")
);
