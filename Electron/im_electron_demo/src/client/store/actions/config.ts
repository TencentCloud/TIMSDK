export const SETTING_CONFIG = 'SETTING_CONFIG';

export const updateSettingConfig = (payload: State.SettingConfig):State.actcionType<State.SettingConfig> => ({
    type: SETTING_CONFIG,
    payload
}) 