//
//  TileView.swift
//  Game-2048
//
//  Created by Amita Pai on 2/25/16.
//  Copyright © 2016 Amita Pai. All rights reserved.
//

import UIKit

class TileView: UIControl {
    
    var row: Int = 0 {
        didSet {
//            self.index = indexForPosition(self.row, self.column)
        }
    }
    var column: Int = 0 {
        didSet {
//            self.index = indexForPosition(self.row, self.column)
        }
    }
    
    var index: Int = 0 {
        didSet {
            self.row = rowFromIndex(self.index)
            self.column = columnFromIndex(self.column)
            
            self.tag = kTileTagStart + self.index
        }
    }
    
    var value: Int = 0 {
        didSet {
            self.tile.contents = UIImage(named: "\(value)")?.CGImage
        }
    }
    
//    var tag: Int = 0
    
    private let tile = CAShapeLayer()

    convenience init(frame: CGRect, value: Int, index: Int) {
        self.init(frame: frame)
        
        // add minute hand
        self.tile.bounds = CGRectMake(0.0, 0.0, frame.width, frame.height)
        self.tile.contents = UIImage(named: "\(value)")?.CGImage
        self.tile.position = CGPointMake(frame.width/2, frame.height/2)
        self.tile.anchorPoint = CGPointMake(0.5, 0.5)
//        self.tile.fillColor = UIColor.blackColor().CGColor
//        self.tile.shadowOffset = CGSizeMake(0.0, 3.0)
//        self.tile.shadowOpacity = 0.3
        self.layer.addSublayer(self.tile)
        
        
        self.value = value
    }

}
