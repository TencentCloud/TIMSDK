//
//  GCDTimer.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/13.
//

import Foundation

typealias GCDTimerTaskEvent = () -> Void

class GCDTimer {
    
    static var timerDic: [String: DispatchSourceTimer] = Dictionary()
    
    static func start(interval:Int, repeats: Bool, async: Bool, task:@escaping GCDTimerTaskEvent) -> String {
        
        let codeTimer = DispatchSource.makeTimerSource(queue: async ? DispatchQueue.global() : DispatchQueue.main)
        
        let timerName = String(Date().timeIntervalSinceReferenceDate)
        timerDic[timerName] = codeTimer
        
        codeTimer.schedule(deadline: .now(), repeating: .seconds(interval))
        codeTimer.setEventHandler(handler: {
            DispatchQueue.main.async {
                task()
            }
            if !repeats {
                self.cancel(timerName: timerName) {
                }
            }
        })
        
        if codeTimer.isCancelled { return timerName}
        codeTimer.resume()
        return timerName
    }
    
    static func cancel(timerName: String, task: @escaping GCDTimerTaskEvent) {
        if let timer = timerDic[timerName] {
            timer.cancel()
            timerDic.removeValue(forKey: timerName)
        }
        task()
    }
    
    static func secondToHMS(second: Int) -> (hour: Int, min: Int, sec: Int) {
        var sec: Int  = 0
        var min: Int = 0
        var hour: Int = 0
        
        let oneHour = 3_600
        let oneMin = 60
        
        hour = second / oneHour
        min = (second % oneHour) / oneMin
        sec = (second % oneHour) % oneMin
        
        return (hour, min, sec)
    }
    
    static func secondToHMSString(second: Int) -> String {
        let time = GCDTimer.secondToHMS(second: second)
        var hour: String
        var min: String
        var seconds: String
        
        if time.hour <= 0 {
            hour = ""
        } else if time.hour >= 0 && time.hour < 10 {
            hour = "0\(time.hour):"
        } else {
            hour = String(time.hour) + ":"
        }
        
        if time.min <= 0 {
            min = "00:"
        } else if time.min >= 0 && time.min < 10 {
            min = "0\(time.min):"
        } else {
            min = String(time.min) + ":"
        }
        
        if time.sec <= 0 {
            seconds = "00"
        } else if time.sec >= 0 && time.sec < 10 {
            seconds = "0\(time.sec)"
        } else {
            seconds = String(time.sec)
        }
        
        return "\(hour)\(min)\(seconds)"
    }
}
