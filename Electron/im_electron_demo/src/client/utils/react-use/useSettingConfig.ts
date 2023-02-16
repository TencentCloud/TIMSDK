import { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import Store from 'electron-store';

import { DEFAULT_SETTING_CONFIG } from '../../constants';

const store = new Store();

export const useSettingConfig = () => {
    const settingConfigFromStore = useSelector((state: State.RootState) => state.settingConfig);
    const config = store.get('setting-config') as State.SettingConfig;
    const [settingConfig, setSettingConfig] = useState<State.SettingConfig>(config || DEFAULT_SETTING_CONFIG);

    useEffect(() => {
        const { userSig, userId, sdkappId } = settingConfigFromStore;
        if(userId || userSig || sdkappId) {
            setSettingConfig(settingConfigFromStore);
        } else {
            const config = store.get('setting-config') as State.SettingConfig;
            setSettingConfig(config || settingConfigFromStore);
        }
    }, [settingConfigFromStore]);

    return settingConfig;
} 