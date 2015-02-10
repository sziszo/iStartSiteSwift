//
//  DictionaryUtils.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 02. 09..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class DictionaryUtils {
    
    /**
    Creates a dictionary with an optional
    entry for every element in an array.
    */
    class func toDictionary<E, K, V>(
        array:       [E],
        transformer: (element: E) -> (key: K, value: V)?)
        -> Dictionary<K, V>
    {
        return array.reduce([:]) {
            (var dict, e) in
            if let (key, value) = transformer(element: e)
            {
                dict[key] = value
            }
            return dict
        }
    }

}