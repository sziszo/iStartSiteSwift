//
//  Appearance.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 28..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

class Appearance {
    
    struct TableHeader {
//        static let backgroundColor = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1.0)
        static let backgroundColor = MP_HEX_RGB("D1EEFC")
    }
    struct TableFooter {
        static let backgroundColor = TableHeader.backgroundColor
    }
    
    struct TableCell {
        static let backgroundColor = UIColor.whiteColor()
    }
    
}