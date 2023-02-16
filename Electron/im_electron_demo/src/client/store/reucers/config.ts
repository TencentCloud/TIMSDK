import { SETTING_CONFIG } from '../actions/config';

const initState = {
    sdkappId: '',
    userId: '',
    userSig: '',
}

const configReducer = (state = initState, action: { type: any; payload: any }) => {
    switch (action.type) {
        case SETTING_CONFIG:
          return {
              ...state,
              ...action.payload
          }
        default:
          return state;
        }
}

export default configReducer; 