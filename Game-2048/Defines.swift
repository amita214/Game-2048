//
//  Defines.swift
//  Game-2048
//
//  Created by Amita Pai on 2/25/16.
//  Copyright © 2016 Amita Pai. All rights reserved.
//

import Foundation

let kTileTagStart = 2016

let kGridSize: Int = 4
let kMaxTileCount = kGridSize * kGridSize

// These dimensions are for a grid size 300x300
let kOuterPadding = 8.0
let kInnerPadding = kOuterPadding
let kWidth = 65.0
let kHeight = kWidth
let kRefDimension = 300.0

// Macros
let random2Or4: Void -> Int = { return Int(pow(Double(2), Double(arc4random_uniform(2) + 1))) }
let rowFromIndex: Int -> Int = { index in return index / kGridSize }
let columnFromIndex: Int -> Int = { index in return index % kGridSize }
let indexForPosition: (Int, Int) -> Int = { (row, column) in return row * kGridSize + column }
let tagForTileAtIndex: Int -> Int = { index in return kTileTagStart + index }

// Notifications
let kSwipeLeftNotification = "Swipe Left Notification"
let kSwipeRightNotification = "Swipe Right Notification"
let kSwipeUpNotification = "Swipe Up Notification"
let kSwipeDownNotification = "Swipe Down Notification"
