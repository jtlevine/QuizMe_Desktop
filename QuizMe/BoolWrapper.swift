//
//  BoolWrapper.swift
//  QuizMe
//
//  Created by Josh Levine on 12/7/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Foundation

/**
 Used in RecentVC
 Allows Bools to be passed around by reference
 **/
class BoolWrapper{
    var value : Bool
    
    init(val:Bool){
        self.value = val
    }
}