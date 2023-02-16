import { SET_USER_INFO } from '../actions/user';

enum typeEnum {
    SET_USER_INFO ='SET_USER_INFO'
}

const initState = {
    userId: '',
    faceUrl: '',
    nickName: '',
    role: 0
}

const userReducer = (state = initState, action: { type: typeEnum; payload: any }) => {
    switch (action.type) {
        case SET_USER_INFO:
          return {
              ...state,
              ...action.payload
          }
        default:
          return state;
        }
}

export default userReducer;