export const SET_IS_LOGIN = 'SET_IS_LOGIN';
export const USER_LOGOUT = 'USER_LOGOUT';

export const setIsLogInAction = (payload: boolean) : State.actcionType<boolean> => ({
    type: SET_IS_LOGIN,
    payload
})

export const userLogout = () => ({
    type: USER_LOGOUT
})