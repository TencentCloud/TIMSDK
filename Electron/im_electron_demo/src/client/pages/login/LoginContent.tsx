import React, { useState, useEffect, Fragment } from 'react';
import { useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';
import Store from 'electron-store';

import { Tabs, TabPanel, Input, Button, Checkbox, message, Form } from "tea-component";
import { DEFAULT_USERID, DEFAULT_USER_SIG } from '../../constants';
import timRenderInstance from '../../utils/timRenderInstance';
import { setIsLogInAction } from '../../store/actions/login';
import { changeFunctionTab } from '../../store/actions/ui';
import { setUserInfo } from '../../store/actions/user';
import { updateSettingConfig } from '../../store/actions/config';
import { initHistoryMessage } from '../../store/actions/message';
// eslint-disable-next-line import/no-unresolved
import { loginParam } from 'im_electron_sdk/dist/interface';
import { useSettingConfig } from '../../utils/react-use/useSettingConfig';
import { getApassConfig, loginSms, reloginSms, userVerifyByPicture } from '../../api';
import { ipcRenderer } from 'electron';
const store = new Store();

const tabs = [
    { id: 'verifyCodeLogin', label: '验证码登录' },
    { id: 'passwordLogin', label: '密码登录' },
]

export const LoginContent = (): JSX.Element => {
    const autoLoginFromStore = store.get('autoLogin');
    const [smsLoginUserId, setsmsLoginUserId] = useState(store.get('sms_relogin_token') ? JSON.parse(store.get('sms_relogin_token') as any).userId : "")
    const [smsLoginToken, setsmsLoginToken] = useState(store.get('sms_relogin_token') ? JSON.parse(store.get('sms_relogin_token') as any).token : "")
    const [smsLoginTel, setsmsLoginTel] = useState(store.get('sms_relogin_token') ? JSON.parse(store.get('sms_relogin_token') as any).tel : "")
    const dispatch = useDispatch();
    const history = useHistory();
    const { userId, userSig, sdkappId } = useSettingConfig();
    const [activedTab, setActivedTab] = useState('verifyCodeLogin');
    const [isAutoLogin, setAutoLogin] = useState(!!autoLoginFromStore);
    const [userID, setUserID] = useState(userId);
    const [usersig, setUserSig] = useState(userSig);
    const [phone, setphone] = useState('')
    const [captceh, setcaptceh] = useState('')
    const isDisablelogin = (activedTab === 'passwordLogin' && userID && usersig) || (activedTab === 'verifyCodeLogin' && phone && captceh) || (activedTab === 'verifyCodeLogin' && smsLoginUserId && smsLoginToken);
    const [sessionId, setsessionId] = useState('')
    const [count, setcount] = useState(60)
    const [logining,setLogining] = useState(false);
    useEffect(() => {
        setUserID(userId);
        setUserSig(userSig);
    }, [userId, userSig])

    const customizeTabBarRender = (children: JSX.Element) => {
        return <a className="customize-tab-bar">{children}</a>
    }

    const handleTabChange = ({ id }) => {
        // if(id === 'verifyCodeLogin') return message.warning({content: '敬请期待'});
        setActivedTab(id);
    }
    const handleLogin = () => {
        if (activedTab === 'passwordLogin') {
            handleLoginClick()
        }
        if (activedTab === 'verifyCodeLogin') {
            handleSmsLogin()
        }
    }
    const handleSmsLogin = async () => {
        if (smsLoginToken && smsLoginUserId) {
            smsReLogin()
        } else if (phone && captceh) {
            smsFristLogin()
        }
    }
    const smsFristLogin = async () => {
        setLogining(true)
        const response: any = await loginSms({
            sessionId,
            phone: `+86${phone}`,
            code: captceh,
            apaasAppId: "1026227964"
        })
        console.log(response)

        const { errorCode, errorMessage, data } = response.data;

        if (errorCode === 0) {
            const { userId, sdkAppId, sdkUserSig, token, phone:tel } = data;

            await ipcRenderer.invoke("re-create-main-instance", sdkAppId)

            dispatch(updateSettingConfig(
                {
                    sdkappId: sdkAppId,
                    userId,
                    userSig: sdkUserSig
                }
            ))
            await sleep(1000)

            smsLoginIM(userId, sdkUserSig, sdkAppId, token,tel)

            
        } else {
            message.error({
                content: `发送错误:${errorMessage}`
            })
        }
        setLogining(false)
    }
    const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
    const smsReLogin = async () => {
        setLogining(true)
        const response: any = await reloginSms({
            userId: smsLoginUserId,
            token: smsLoginToken,
            apaasAppId: "1026227964"
        });
        const { errorCode, errorMessage, data } = response.data;
        if (errorCode === 0) {
            const { userId, sdkAppId, sdkUserSig, token, phone:tel } = data;
            
             ipcRenderer.invoke("re-create-main-instance", sdkAppId).then(async ()=>{
                dispatch(updateSettingConfig(
                    {
                        sdkappId: sdkAppId,
                        userId,
                        userSig: sdkUserSig
                    }
                ))
                await sleep(1000)
                smsLoginIM(userId, sdkUserSig, sdkAppId, token,tel)
             })
            
            
        } else {
            message.error({
                content: `发送错误:${errorMessage}`
            })
        }
        setLogining(false)
    }
    const smsLoginIM = async (userId, sdkUserSig, sdkAppId, token,tel) => {
        const params: loginParam = {
            userID: userId,
            userSig: sdkUserSig
        }
        const { data: { code, data, desc, json_param } } = await timRenderInstance.TIMLogin(params);
        console.log(code, data, desc, json_param);
        if (code === 0) {
            const storeKey = `${sdkAppId}-${userId}`;
            const catchedMessage = store.get(storeKey);
            if (catchedMessage) {
                const historyMessageMap = new Map(Object.entries(catchedMessage));
                dispatch(initHistoryMessage({
                    historyMessage: historyMessageMap
                }));
            }
            store.set('autoLogin', isAutoLogin);
            store.set('sms_relogin_token', JSON.stringify({
                token,
                userId,
                tel
            }));
            dispatch(setIsLogInAction(true));
            dispatch(setUserInfo({
                userId: userId,
                userSig: sdkUserSig
            }));
            dispatch(updateSettingConfig({
                userId: userId,
                sdkappId: sdkAppId,
                userSig: sdkUserSig
            }));
            dispatch(changeFunctionTab('message'));
            setsessionId("")
            history.replace('/home/message');
        }
        // @ts-ignore
        window.aegis.report("tim_login_sms")
    }
    const handleLoginClick = async () => {
        setLogining(true)
        const params: loginParam = {
            userID: userID,
            userSig: usersig
        }

        await ipcRenderer.invoke("re-create-main-instance", sdkappId);
         dispatch(updateSettingConfig(
            {
                sdkappId: sdkappId,
                userId,
                userSig: usersig
            }
        ))
        await sleep(1000)
        const { data: { code, data, desc, json_param } } = await timRenderInstance.TIMLogin(params);
        console.log(code, data, desc, json_param);
        if (code === 0) {
            const storeKey = `${sdkappId}-${userID}`;
            const catchedMessage = store.get(storeKey);
            if (catchedMessage) {
                const historyMessageMap = new Map(Object.entries(catchedMessage));
                dispatch(initHistoryMessage({
                    historyMessage: historyMessageMap
                }));
            }
            store.set('autoLogin', isAutoLogin);
            dispatch(setIsLogInAction(true));
            dispatch(setUserInfo({
                userId: userID,
                userSig: usersig
            }));
            dispatch(updateSettingConfig({
                userId: userID,
                sdkappId: sdkappId,
                userSig: usersig
            }));
            setsessionId("")
            dispatch(changeFunctionTab('message'));
            history.replace('/home/message');
        }
        setLogining(false)
        // @ts-ignore
        window.aegis.report("tim_login_secret")
        
    }

    const startCountDown = () => {
        const newCount = count - 1;
        const timmer = setTimeout(() => {
            
            setcount(newCount)
            clearTimeout(timmer)
        }, 1000)
    }
    useEffect(() => {
        if (sessionId && count < 60) {
            startCountDown()
        }
        if(count === 0){
            setcount(60)
            setsessionId("")
        }
    }, [count])
    const captchaCallback = async (data) => {
        console.log(data)
        const { randstr, ticket, ret, appid } = data;
        if (ret === 0) {
            const response: any = await userVerifyByPicture({
                appId: appid,
                ticket,
                randstr,
                phone: `+86${phone}`
            })
            // console.log(response)
            const { data, errorCode, errorMessage } = response.data;
            if (errorCode === 0) {
                // 防水墙验证成功
                const { sessionId } = data;
                setsessionId(sessionId)
                // 开始倒计时
                startCountDown()
            } else {
                message.error({
                    content: `出现错误:${errorMessage}`
                })
            }
        }
    }
    const getCaptch = () => {
        const phoneReg = /^[1][3,4,5,7,8][0-9]{9}$/;
        if (!phone || !phoneReg.test(phone)) {
            message.error({
                content: "请输入正确的手机号"
            })
            return
        }
        getConfig()
    }
    const getConfig = async () => {
        const config: any = await getApassConfig()
        // if(config.data){}
        const { errorCode, errorMessage, data } = config.data;
        if (errorCode === 0) {
            const { captcha_web_appid } = data
            // @ts-ignore
            const captcha = new TencentCaptcha(`${captcha_web_appid}`, captchaCallback, {});
            captcha.show()
        } else {
            message.error({
                content: `发生错误:${errorMessage}`
            })
        }
        // console.log(config.data.data)
    }
    const resetConfig = () => {
        store.delete("sms_relogin_token")
        setsmsLoginUserId("")
        setsmsLoginToken("")
        setsmsLoginTel("")
    }
    useEffect(() => {
        window.requestIdleCallback(() => {
            import(
                /* webpackPrefetch: true */
                /* webpackChunkName: "home" */
                '../home');
        })
    }, []);

    
    return (
        <div className="login--context">
            <h2 className="login--context__title">登录IM</h2>
            <Tabs tabs={tabs} placement="top" activeId={activedTab} onActive={handleTabChange} tabBarRender={customizeTabBarRender}>
                <TabPanel id="verifyCodeLogin">
                    {
                        smsLoginToken && smsLoginUserId ? (
                            <div className="captche-row">
                                <Input className="login--input" value={`${smsLoginTel?smsLoginTel:smsLoginUserId}`} disabled={true} key="relogin" />
                                <Button className="cap-btn" type="weak" onClick={resetConfig}>重置</Button>
                            </div>
                        ) : (
                            <Fragment>
                                <div className="captche-row">
                                    <Input placeholder="请输入手机号码" className="login--input" onChange={setphone} key="login" /> <Button className="cap-btn" type="primary" onClick={getCaptch} disabled={sessionId && count < 60}>{sessionId ? count : "获取验证码"}</Button>
                                </div>
                                <Input placeholder="请输入短信验证码" className="login--input" onChange={setcaptceh} />
                            </Fragment>
                        )
                    }

                </TabPanel>
                <TabPanel id="passwordLogin">
                    <Input placeholder="请在右上角进行配置userID" value={userID} className="login--input" disabled={true} onChange={(val) => { setUserID(val) }} />
                    <Input placeholder="请在右上角进行配置userSig" value={usersig} className="login--input" disabled={true} onChange={(val) => setUserSig(val)} />
                </TabPanel>
            </Tabs>
            {/* <Checkbox display="block" onChange={hanldeAutoLogin} value={isAutoLogin} className="login--auto">
                下次自动登录
            </Checkbox> */}
            <Button type="primary" loading={logining} className="login--button" onClick={handleLogin} disabled={!isDisablelogin}> 登 录</Button>
        </div>
    )
}