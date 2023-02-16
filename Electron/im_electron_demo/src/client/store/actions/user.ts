export const SET_USER_INFO = 'SET_USER_INFO';

export const setUserInfo = (payload: State.userInfo) : State.actcionType<State.userInfo> => ({
    type: SET_USER_INFO,
    payload
});