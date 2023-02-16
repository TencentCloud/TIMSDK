export const CHANGE_DRAWER_VISIBLE = "CHANGE_DRAWER_VISIBLE";
export const CHNAGE_TOOLS_TAB = "CHNAGE_TOOLS_TAB";

export const changeToolsTab = (payload: string) : State.actcionType<string> => ({
  type: CHNAGE_TOOLS_TAB,
  payload
})

export const changeDrawersVisible = (payload: boolean) : State.actcionType<string> => ({
  type: CHANGE_DRAWER_VISIBLE,
  payload
})