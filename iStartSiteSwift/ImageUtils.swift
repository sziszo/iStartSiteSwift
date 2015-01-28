//
//  ImageUtils.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 20..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation


class ImageUtils {
    
    class func imageFromText(text: String, withFontSize fontSize: CGFloat = 64.0, backgroundColor: UIColor = UIColor.blueColor(), foregroundColor: UIColor = UIColor.orangeColor()) -> UIImage {
        
        let font = UIFont.systemFontOfSize(fontSize)
        let nsText = NSString(string: text)
        let size = nsText.sizeWithAttributes([NSFontAttributeName: font])
        
//        println("imagesize: \(size)")
        
        UIGraphicsBeginImageContext(size)
        
        nsText.drawAtPoint(CGPointMake(0.0, 0.0), withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: foregroundColor,
            NSBackgroundColorAttributeName: backgroundColor])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}