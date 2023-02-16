import React from 'react';

import { LoginAbout } from './LoginAbout';
import { LoginContent } from './LoginContent';
import { SettingConfig } from './SettingConfig';
import './login.scss';

const Login = (): JSX.Element => (
    <div className="login">
        <SettingConfig />
        <LoginAbout />
        <LoginContent />
    </div>
)

export default Login;