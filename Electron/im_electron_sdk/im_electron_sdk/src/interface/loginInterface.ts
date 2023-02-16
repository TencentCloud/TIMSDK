/**
 *@param userID userID用户的UserID
 * @param userSig userSig用户的UserSig
 * @param userData userData用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理(可选参数)
 */
interface loginParam {
    userID: string;
    userSig: string;
    userData?: string;
}
/**
 * @param userData userData用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理(可选参数)
 */
interface logoutParam {
    userData?: string;
}
/**
 * @param userData userData用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理(可选参数)
 */
interface getLoginUserIDParam {
    userData?: string;
}

export { loginParam, logoutParam, getLoginUserIDParam };
