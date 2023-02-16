import { SET_IS_LOGIN, USER_LOGOUT } from '../actions/login';

const initState = {
    isLogIn: false
}

const loginReducer = (state = initState, action: { type: any; payload: any }) => {
    switch (action.type) {
        case SET_IS_LOGIN:
          return {
              ...state,
              isLogIn: action.payload
          }
        default:
          return state;
        }
}

export default loginReducer;