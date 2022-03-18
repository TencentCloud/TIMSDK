//
//  LoginLocalized.swift
//  TRTCVoiceRoomApp
//
//  Created by abyyxwang on 2021/5/7.
//

import Foundation

//MARK: Base
func localizeFromTable(key: String, table: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: table)
}

//MARK: Replace String
func localizeReplaceOneCharacter(origin: String, xxx_replace: String) -> String {
    return origin.replacingOccurrences(of: "xxx", with: xxx_replace)
}

func localizeReplaceTwoCharacter(origin: String, xxx_replace: String, yyy_replace: String) -> String {
    return localizeReplaceOneCharacter(origin: origin, xxx_replace: xxx_replace).replacingOccurrences(of: "yyy", with: yyy_replace)
}

func localizeReplaceThreeCharacter(origin: String, xxx_replace: String, yyy_replace: String, zzz_replace: String) -> String {
    return localizeReplaceTwoCharacter(origin: origin, xxx_replace: xxx_replace, yyy_replace: yyy_replace).replacingOccurrences(of: "zzz", with: zzz_replace)
}

func localizeReplaceFourCharacter(origin: String, xxx_replace: String, yyy_replace: String, zzz_replace: String, mmm_replace: String) -> String {
    return localizeReplaceThreeCharacter(origin: origin, xxx_replace: xxx_replace, yyy_replace: yyy_replace, zzz_replace: zzz_replace).replacingOccurrences(of: "mmm", with: mmm_replace)
}

func localizeReplaceFiveCharacter(origin: String, xxx_replace: String, yyy_replace: String, zzz_replace: String, mmm_replace: String, nnn_replace: String) -> String {
    return localizeReplaceFourCharacter(origin: origin, xxx_replace: xxx_replace, yyy_replace: yyy_replace, zzz_replace: zzz_replace, mmm_replace: mmm_replace).replacingOccurrences(of: "nnn", with: nnn_replace)
}

//MARK: Login
let LoginLocalizeTableName = "LoginLocalized"
func LoginLocalize(key: String) -> String {
    return localizeFromTable(key: key, table: LoginLocalizeTableName)
}
