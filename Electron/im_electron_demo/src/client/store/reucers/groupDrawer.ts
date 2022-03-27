import { CHANGE_DRAWER_VISIBLE, CHNAGE_TOOLS_TAB } from "../actions/groupDrawer";

const initState = {
  toolsDrawerVisible: false,
  toolsTab: '',
};

const GroupDrawerReducer = (state = initState, action: { type: any; payload: any }) => {
  const { type, payload } = action;
  switch (type) {
    case CHANGE_DRAWER_VISIBLE:
      return {
        ...state,
        toolsDrawerVisible: payload,
      };
    case CHNAGE_TOOLS_TAB:
      return {
        ...state,
        toolsTab: payload,
      }
    default:
      return state;
  }
};

export default GroupDrawerReducer;
