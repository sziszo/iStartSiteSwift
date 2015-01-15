//
//  Utils.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 15..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

public class Timer {
    // each instance has it's own handler
    private var handler: () -> ()
    
    init(handler: () -> ()) {
        self.handler = handler
    }
    
    public class func start(duration: NSTimeInterval, repeats: Bool, handler:()->()) {
        var t = Timer(handler)
        NSTimer.scheduledTimerWithTimeInterval(duration, target: t, selector: "processHandler:", userInfo: nil, repeats: repeats)
    }
    
    @objc private func processHandler(timer: NSTimer) {
        self.handler()
    }
}