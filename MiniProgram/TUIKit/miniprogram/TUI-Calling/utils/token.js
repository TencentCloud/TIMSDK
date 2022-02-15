import logger from './logger'
const STORAGE_KEY = 'token'
const VALID_SPAN = 30 * 24 * 3600 * 1000 // 有效期，默认30天

let app = getApp()

/**
 * 判断本地存储的 token 是否有效
 */
export function isTokenValided(expiresIn) {
  return Date.now() <= expiresIn
}

/**
 * 保存 Token 到本地，默认保存有效期 30 天
 * @param {String} options.token
 * @param {String} options.phone
 * @returns {Promise}
 */
export function setTokenStorage(options) {
  logger.log(`| TUIKit | TUI-utils | setTokenStorage | options:${options}`)
  return new Promise((resolve, reject) => {
    const data = {
      expiresIn: Date.now() + VALID_SPAN,
      userInfo: {
        token: options.userInfo.token,
        phone: options.userInfo.phone,
        userID: options.userInfo.userID,
        userSig: options.userInfo.userSig,
      },
    }
    if (!app) {
      app = getApp()
    }
    app.globalData.expiresIn = data.expiresIn
    wx.setStorage({
      key: STORAGE_KEY,
      data,
      success: resolve,
      fail: reject,
    })
  })
}

export function getTokenStorage() {
  return new Promise((resolve, reject) => {
    wx.getStorage({
      key: STORAGE_KEY,
      success: ({ data }) => {
        resolve(data)
      },
      fail: reject,
    })
  })
}

export function removeTokenStorage() {
  return new Promise((resolve, reject) => {
    wx.removeStorage({
      key: STORAGE_KEY,
      success: resolve,
      fail: reject,
    })
  })
}
