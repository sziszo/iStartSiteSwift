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
        static let backgroundColor = MP_HEX_RGB("D7D7D7")
    }
    struct TableFooter {
        static let backgroundColor = TableHeader.backgroundColor
    }
    
    struct TableCell {
        static let backgroundColor = UIColor.whiteColor() //MP_HEX_RGB("F7F7F7")
        static let actionColorRed = MP_HEX_RGB("FF3B30")
        static let actionColorGreen = MP_HEX_RGB("5AD427")
    }
    
    struct MessageView {
        static let backgroundColor = TableHeader.backgroundColor
        
    }
    
    struct ProfileImage {
        static let backgroundColor = MP_HEX_RGB("34AADC")
        static let textColor = MP_HEX_RGB("F7F7F7")
//        static let textColor = MP_HEX_RGB("0BD318")
    }
    
    struct Menu {
        static let backgroundColor =  MP_HEX_RGB("D1EEFC")
        static let tableViewBackground = Menu.backgroundColor
        static let loginViewBackground = TableCell.backgroundColor
    }
    
    struct NavigationBar {
        static let backgroundColor = MP_HEX_RGB("34AADC")
    }
    
    struct LoginView {
        static let backgroundColor = MP_HEX_RGB("D1EEFC")
    }
    

}