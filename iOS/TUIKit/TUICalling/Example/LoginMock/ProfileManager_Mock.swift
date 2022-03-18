//
//  profileManager.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/23/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import Alamofire
import ImSDK_Plus
import TUICore

@objc class LoginResultModel: NSObject, Codable {
    @objc var token: String
    @objc var phone: String
    @objc var name: String
    @objc var avatar: String
    @objc var userId: String
    @objc var userSig: String = ""
    
    public init(userID: String) {
        userId = userID
        token = userID
        phone = userID
        name = userID
        
        userSig = GenerateTestUserSig.genTestUserSig(identifier: userID)
        avatar = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"
        super.init()
    }
}

@objc public class ProfileManager: NSObject {
    @objc public static let shared = ProfileManager()
    private override init() {}
    
    var sessionId: String = ""
    @objc var curUserModel: LoginResultModel? = nil
    
    /// 自动登录
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error: 错误信息
    /// - Returns:是否可以自动登录
    @objc public func autoLogin(success: @escaping ()->Void,
                                failed: @escaping (_ error: String)->Void) -> Bool {
        let tokenKey = "com.tencent.trtcScences.demo"
        if let cacheData = UserDefaults.standard.object(forKey: tokenKey) as? Data {
            if let cacheUser = try? JSONDecoder().decode(LoginResultModel.self, from: cacheData) {
                curUserModel = cacheUser
                let fail: (_ error: String)->Void = { err in
                    failed(err)
                    UserDefaults.standard.set(nil, forKey: tokenKey)
                }
                login(phone: curUserModel?.userId ?? "", code: "", success: success, failed: fail, auto: true)
                return true
            }
        }
        return false
    }
    
    /// 登录
    /// - Parameters:
    ///   - success: 登录成功
    ///   - failed: 登录失败
    ///   - error: 错误信息
    @objc public func login(phone: String, code: String, success: @escaping ()->Void,
                            failed: ((_ error: String) -> Void)? = nil , auto: Bool = false) {
        let phoneValue = phone
        if !auto {
            assert(phoneValue.count > 0)
            curUserModel = LoginResultModel(userID: phoneValue)
        }
        // cache data
        let tokenKey = "com.tencent.trtcScences.demo"
        do {
            let cacheData = try JSONEncoder().encode(curUserModel)
            UserDefaults.standard.set(cacheData, forKey: tokenKey)
        } catch {
            print("Save Failed")
        }
        success()
    }
    
    /// 设置昵称
    /// - Parameters:
    ///   - name: 昵称
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error: 错误信息
    @objc public func setNickName(name: String, success: @escaping ()->Void,
                                  failed: @escaping (_ error: String)->Void) {
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = name
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            success()
            debugPrint("set profile success")
        }, fail: { (code, desc) in
            failed(desc ?? "")
            debugPrint("set profile failed.")
        })
    }
    
    /// IM 登录当前用户
    /// - Parameters:
    ///   - success: 成功
    ///   - failed: 失败
    @objc func IMLogin(userSig: String, success: @escaping ()->Void, failed: @escaping (_ error: String)->Void) {
        TUILogin.initWithSdkAppID(Int32(SDKAPPID))
        
        guard let userID = curUserModel?.userId else {
            failed("userID wrong")
            return
        }
        let user = String(userID)
        
        TUILogin.login(user, userSig: userSig) {
            debugPrint("login success")
            // IM登录成功后，处理离线推送相关
            let config = V2TIMAPNSConfig()
            // 苹果后台请求的 deviceToken
            config.token = AppUtils.shared.deviceToken
            V2TIMManager.sharedInstance()?.setAPNS(config, succ: {
                debugPrint("setAPNS success")
            }, fail: { code, msg in
                debugPrint("setAPNS error code:\(code), error: \(msg ?? "nil")")
            })
            
            V2TIMManager.sharedInstance()?.getUsersInfo([userID], succ: { [weak self] (infos) in
                guard let `self` = self else { return }
                if let info = infos?.first {
                    self.curUserModel?.avatar = info.faceURL ?? ""
                    self.curUserModel?.name = info.nickName ?? ""
                    success()
                }
                else {
                    failed("")
                }
            }, fail: { (code, err) in
                failed(err ?? "")
                debugPrint("get user info failed, code:\(code), error: \(err ?? "nil")")
            })
        } fail: { code, errorDes in
            failed(errorDes ?? "")
            debugPrint("login failed, code:\(code), error: \(errorDes ?? "nil")")
        }
    }
    
    @objc func curUserID() -> String? {
        guard let userID = curUserModel?.userId else {
            return nil
        }
        return userID
    }
    
    @objc public func removeLoginCache() {
        let tokenKey = "com.tencent.trtcScences.demo"
        UserDefaults.standard.set(nil, forKey: tokenKey)
    }
    
    @objc public func curUserSig() -> String {
        return curUserModel?.userSig ?? ""
    }
    
    @objc func synchronizUserInfo() {
        guard let userModel = curUserModel else {
            return
        }
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = userModel.name
        userInfo.faceURL = userModel.avatar
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            debugPrint("set profile success")
        }, fail: { (code, desc) in
            debugPrint("set profile failed.")
        })
    }
}

