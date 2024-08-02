//
//  UIView+Extension.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/27.
//

#if USE_OPENCOMBINE
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#else
import Combine
#endif

extension DispatchQueue {
#if USE_OPENCOMBINE
    static var mainQueue: DispatchQueue.OCombine {
        return DispatchQueue.main.ocombine
    }
#else
    static var mainQueue: DispatchQueue {
        return DispatchQueue.main
    }
#endif
}
