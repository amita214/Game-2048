//
//  TileView.swift
//  Game-2048
//
//  Created by Amita Pai on 2/25/16.
//  Copyright © 2016 Amita Pai. All rights reserved.
//

import UIKit

struct TileSlideInfo {
//    var destinationIndex: Int
    var destinationRow: Int
    var destinationColumn: Int
    var destinationFrame: CGRect
    var merge: Bool
    var tileToRemove: TileView?
}

class TileView: UIControl {
    
    var row: Int = 0
    var column: Int = 0
    
    var index: Int = 0 {
        didSet {
            self.row = rowFromIndex(self.index)
            self.column = columnFromIndex(self.index)
            
            self.tag = tagForTileAtIndex(self.index)
        }
    }
    
    var value: Int = 0 {
        didSet {
            self.tile.contents = UIImage(named: "\(value)")?.CGImage
        }
    }
    
    var leftSlideInfo: TileSlideInfo!
    var rightSlideInfo: TileSlideInfo!
    var upSlideInfo: TileSlideInfo!
    var downSlideInfo: TileSlideInfo!
    
    private let tile = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add minute hand
        self.tile.bounds = CGRectMake(0.0, 0.0, frame.width, frame.height)
        self.tile.contents = UIImage(named: "\(value)")?.CGImage
        self.tile.position = CGPointMake(frame.width/2, frame.height/2)
        self.tile.anchorPoint = CGPointMake(0.5, 0.5)
//        self.tile.fillColor = UIColor.blackColor().CGColor
//        self.tile.shadowOffset = CGSizeMake(0.0, 3.0)
//        self.tile.shadowOpacity = 0.3
        self.layer.addSublayer(self.tile)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "slideTileLeft", name: kSwipeLeftNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "slideTileRight", name: kSwipeRightNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "slideTileUpward", name: kSwipeUpNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "slideTileDownward", name: kSwipeDownNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kSwipeLeftNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kSwipeRightNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kSwipeUpNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kSwipeDownNotification, object: nil)
    }
    
    
    func slideTo(index: Int, frame: CGRect, merge: Bool, completion: (() -> Void)?) {
        print("\(self.index) -> \(index): \(merge)")
        UIView.animateWithDuration(0.2, animations: {
            self.frame = frame
            }) { (completed) -> Void in
                self.index = index
                if merge {
                    self.value *= 2
                    self.leftSlideInfo.tileToRemove?.removeFromSuperview()
                }
                self.leftSlideInfo = nil
                completion?()
        }
    }
    
    private func slideTile(slideInfo: TileSlideInfo) {
        let index = indexForPosition(slideInfo.destinationRow, slideInfo.destinationColumn)
        self.slideTo(index, frame: slideInfo.destinationFrame, merge: slideInfo.merge, completion: nil)
    }
    
    // MARK: Slide
    func slideTileLeft() {
        guard let slideInfo = self.leftSlideInfo else {
            return
        }
        
        self.slideTile(slideInfo)
    }
    
    func slideTileRight() {
        guard let slideInfo = self.rightSlideInfo else {
            return
        }
        
        self.slideTile(slideInfo)
    }
    
    func slideTileUpward() {
        guard let slideInfo = self.upSlideInfo else {
            return
        }
        
        self.slideTile(slideInfo)
    }
    
    func slideTileDownward() {
        guard let slideInfo = self.downSlideInfo else {
            return
        }
        
        self.slideTile(slideInfo)
    }
}
