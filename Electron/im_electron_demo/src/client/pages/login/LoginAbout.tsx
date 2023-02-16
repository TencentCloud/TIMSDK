import React from 'react';
import { shell } from 'electron';
import { Button } from 'tea-component';

import './login-about.scss';
import loginBg from '../../assets/icon/login-bg.png';
import { PURCHASE_LINK, CONTACT_LINK } from '../../constants';

export const LoginAbout = (): JSX.Element => {
    const handlePurchaseClick = () => {
        shell.openExternal(PURCHASE_LINK);
    };

    const handleContactClick = () => {
        shell.openExternal(CONTACT_LINK);
    }
    return (
        <div className="login-about">
            <section className="login-about__header">
                <span className="login-about__header--logo" />
                <span className="login-about__header--tc-text">腾讯云</span>
                <span className='login-about__header--split' />
                <span className='login-about__header--im-text'> 即时通信</span>
            </section>
            <section className="login-about__text">
                <p>
                    企业数字化转型的通信助手
                </p>
                <p>
                    简单接入、稳定必达、覆盖全球的即时通信云服务
                </p>
            </section>
            <section className="login-about__logo" >
                <img src={loginBg}></img>
            </section>
            <section className="login-about__button">
                <Button type="weak" className="login-about__button--purchase" onClick={handlePurchaseClick}>立即选购</Button>
                <Button type="text" className="login-about__button--contact" onClick={handleContactClick}>联系我们</Button>
            </section>
        </div>
    )
};