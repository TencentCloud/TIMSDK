//
//  TUICallKitObjectFactory.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/8/15.
//

import Foundation
import TUICore

class TUICallKitObjectFactory: NSObject, TUIObjectProtocol {
    
    static let instance = TUICallKitObjectFactory()
    
    func createRecordCallsVC(uiStyle: String) -> UIViewController {
        
        var recordCallsUIStyle: TUICallKitRecordCallsUIStyle = .minimalist
        
        if uiStyle == TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Classic {
            recordCallsUIStyle = .classic
        }
        
        let vc = TUICallRecordCallsViewController(recordCallsUIStyle: recordCallsUIStyle)
        return vc
    }
    
    // MARK: TUIObjectProtocol
    func onCreateObject(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        if method == TUICore_TUICallingObjectFactory_RecordCallsVC {
            guard let uiStyle =  param?[TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle] as? String else { return nil }
            return createRecordCallsVC(uiStyle: uiStyle)
        }
        return nil
    }
}
