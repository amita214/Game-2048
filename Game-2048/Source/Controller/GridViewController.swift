//
//  GridViewController.swift
//  Game-2048
//
//  Created by Amita Pai on 2/25/16.
//  Copyright © 2016 Amita Pai. All rights reserved.
//

import UIKit

enum TileSwipeDirection {
    case Left, Right, Up, Down, None
}

class GridViewController: UIViewController {

    var gameOver = false
    @IBOutlet weak var gridImageView: UIImageView!
    
    @IBOutlet weak var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var upwardSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var downwardSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showWinningAlert", name: kWinningNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.createRandomTile()
        self.createRandomTile()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kWinningNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IB Action
    @IBAction func resetGameAction(sender: UIBarButtonItem?) {
        self.gameOver = false
        self.enableSwipeGestureRecognizers(true)
        for tile in self.gridImageView.subviews {
            tile.removeFromSuperview()
        }
        
        self.createRandomTile()
        self.createRandomTile()
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        self.enableSwipeGestureRecognizers(false)
        let name: String
        switch sender {
        case self.leftSwipeGestureRecognizer: name = kSwipeLeftNotification
        case self.rightSwipeGestureRecognizer: name = kSwipeRightNotification
        case self.upwardSwipeGestureRecognizer: name = kSwipeUpNotification
        case self.downwardSwipeGestureRecognizer: name = kSwipeDownNotification
        default: name = ""
        }
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "createRandomTile", userInfo: nil, repeats: false)
    }

    private func enableSwipeGestureRecognizers(enable: Bool) {
        self.leftSwipeGestureRecognizer.enabled = enable
        self.rightSwipeGestureRecognizer.enabled = enable
        self.upwardSwipeGestureRecognizer.enabled = enable
        self.downwardSwipeGestureRecognizer.enabled = enable
    }
    
    // MARK: - Grid related calculation
    private func hDimensionForGrid(value: Double) -> CGFloat {
        return CGFloat(value) * self.gridImageView.frame.width / CGFloat(kRefDimension)
    }
    
    private func vDimensionForGrid(value: Double) -> CGFloat {
        return CGFloat(value) * self.gridImageView.frame.height / CGFloat(kRefDimension)
    }
    
    private func originFor(row:Int, column:Int) -> CGPoint {
        let x = self.hDimensionForGrid(kOuterPadding + (kWidth + kInnerPadding) * Double(column))
        let y = self.vDimensionForGrid(kOuterPadding + (kHeight + kInnerPadding) * Double(row))
        return CGPointMake(CGFloat(x), CGFloat(y))
    }
    
    private func frameFor(row:Int, column:Int) -> CGRect {
        let origin = self.originFor(row, column: column)
        return CGRectMake(origin.x, origin.y, self.hDimensionForGrid(kWidth), self.vDimensionForGrid(kHeight))
    }
    
    private func areMoreMovesAvailable() -> Bool {
        for tile in self.gridImageView.subviews as! [TileView] {
            if tile.willSlide {
                return true
            }
        }
        return false
    }
    
    // MARK: - Notification
    func showWinningAlert() {
        self.enableSwipeGestureRecognizers(false)
        
        let alertController = UIAlertController(title: "Congratulations", message: "You Won!!", preferredStyle: .Alert)
        self.presentViewController(alertController, animated: true, completion: {
            
        })
    }
    
    // MARK: - Tile creation, deletion
    func createRandomTile() {
        if !self.gameOver {
            if self.gridImageView.subviews.count == kMaxTileCount && !self.areMoreMovesAvailable(){
                self.gameOver = true
                self.enableSwipeGestureRecognizers(false)
                
                let alertController = UIAlertController(title: "Game Over", message: "Do you want to try again?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                    self.resetGameAction(nil)
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action) -> Void in
                    
                }))
                self.presentViewController(alertController, animated: true, completion: {
                    
                })
                
                return
            }
            
            var tileIndex:UInt32 = 0
            repeat {
                tileIndex = arc4random_uniform(UInt32(kMaxTileCount))
            } while (self.tileExistsAtIndex(tileIndex))
            
            self.createTileAt(Int(tileIndex) , value: random2Or4())
            
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "socialize", userInfo: nil, repeats: false)
        }
    }
    
    private func tileExistsAtIndex(index: UInt32) -> Bool {
        if (self.gridImageView.viewWithTag(tagForTileAtIndex(Int(index))) != nil) {
            return true
        }
        return false
    }

    private func createTileAt(index: Int, value: Int) {
        let row = rowFromIndex(index)
        let column = columnFromIndex(index)
        
        let frame = self.frameFor(row, column: column)
        let tile = TileView(frame: frame)
        tile.index = index
        tile.value = value
//        print("\(tile.tag)")
        self.gridImageView.addSubview(tile)
    }
    
    private func removeTileAt(row: Int, column: Int) {
        if let tile = self.gridImageView.viewWithTag(tagForTileAtIndex(indexForPosition(row, column))) as? TileView {
            self.removeTile(tile)
        }
    }
    
    private func removeTile(tile: UIControl) {
        tile.removeFromSuperview()
    }
    
    // MARK: - Slide calculations
    func socialize() {
        self.socializeLeft()
        self.socializeRight()
        self.socializeUp()
        self.socializeDown()
        
        self.enableSwipeGestureRecognizers(true)
    }
    
    private func slideInfoTo(row: Int, column: Int, merge: Bool) -> TileSlideInfo {
        let frame = frameFor(row, column: column)
        
        return TileSlideInfo(destinationRow: row, destinationColumn: column, destinationFrame: frame, merge: merge, tileToRemove: nil)
    }
    
    private func socializeLeft() {
        
        for var row = 0; row < kGridSize; row++ { // iterate top to bottom
            
            for var column = 1; column < kGridSize; column++ { // iterate left to right
                let index = indexForPosition(row, column)
                if let currentTile = self.gridImageView.viewWithTag(tagForTileAtIndex(index)) as? TileView {
                    
                    var leftSlideInfo: TileSlideInfo? = self.slideInfoTo(row, column: 0, merge: false)
                    for var ic = column-1; ic >= 0; ic-- { // iterate to slide left
                        let icIndex = indexForPosition(row, ic)
                        if let nearbyTile = self.gridImageView.viewWithTag(tagForTileAtIndex(icIndex)) as? TileView {
                            if let nearbyTileLeftSlideInfo = nearbyTile.leftSlideInfo {
                                // if nearby tile is already sliding check if it is also merging
                                if !nearbyTileLeftSlideInfo.merge &&  currentTile.value == nearbyTile.value {
                                    // if nearby tile is NOT merging, and the values are equal then MERGE
                                    leftSlideInfo = self.slideInfoTo(row, column: nearbyTileLeftSlideInfo.destinationColumn, merge: true)
                                    leftSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextColumn = nearbyTileLeftSlideInfo.destinationColumn + 1
                                    leftSlideInfo = (nextColumn < column) ? self.slideInfoTo(row, column: nextColumn, merge: false) : nil
                                }
                            } else { // if nearby tile is NOT already sliding
                                if currentTile.value == nearbyTile.value {
                                    leftSlideInfo = self.slideInfoTo(row, column: ic, merge: true)
                                    leftSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextColumn = ic + 1
                                    leftSlideInfo = (nextColumn < column) ? self.slideInfoTo(row, column: nextColumn, merge: false) : nil
                                }
                            }
                            break
                        }
                    }
                    currentTile.leftSlideInfo = leftSlideInfo
                }
            }
        }
    }

    private func socializeRight() {
        
        for var row = 0; row < kGridSize; row++ { // iterate top to bottom
            let lastColumn = kGridSize - 1
            for var column = lastColumn-1; column >= 0; column-- { // iterate right to left
                let index = indexForPosition(row, column)
                if let currentTile = self.gridImageView.viewWithTag(tagForTileAtIndex(index)) as? TileView {
                    
                    var rightSlideInfo: TileSlideInfo? = self.slideInfoTo(row, column: lastColumn, merge: false)
                    for var ic = column+1; ic < kGridSize; ic++ { // iterate to slide right
                        let icIndex = indexForPosition(row, ic)
                        if let nearbyTile = self.gridImageView.viewWithTag(tagForTileAtIndex(icIndex)) as? TileView {
                            if let nearbyTileRightSlideInfo = nearbyTile.rightSlideInfo {
                                // if nearby tile is already sliding check if it is also merging
                                if !nearbyTileRightSlideInfo.merge &&  currentTile.value == nearbyTile.value {
                                    // if nearby tile is NOT merging, and the values are equal then MERGE
                                    rightSlideInfo = self.slideInfoTo(row, column: nearbyTileRightSlideInfo.destinationColumn, merge: true)
                                    rightSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextColumn = nearbyTileRightSlideInfo.destinationColumn - 1
                                    rightSlideInfo = (nextColumn > column) ? self.slideInfoTo(row, column: nextColumn, merge: false) : nil
                                }
                            } else { // if nearby tile is NOT already sliding
                                if currentTile.value == nearbyTile.value {
                                    rightSlideInfo = self.slideInfoTo(row, column: ic, merge: true)
                                    rightSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextColumn = ic - 1
                                    rightSlideInfo = (nextColumn > column) ? self.slideInfoTo(row, column: nextColumn, merge: false) : nil
                                }
                            }
                            break
                        }
                    }
                    currentTile.rightSlideInfo = rightSlideInfo
                    
                }
            }
        }
    }

    private func socializeUp() {
        
        for var column = 0; column < kGridSize; column++ { // iterate left to right
            
            for var row = 1; row < kGridSize; row++ { // iterate top to bottom
                let index = indexForPosition(row, column)
                if let currentTile = self.gridImageView.viewWithTag(tagForTileAtIndex(index)) as? TileView {
                    
                    var upSlideInfo: TileSlideInfo? = self.slideInfoTo(0, column: column, merge: false)
                    for var ir = row-1; ir >= 0; ir-- { // iterate to slide up
                        let irIndex = indexForPosition(ir, column)
                        if let nearbyTile = self.gridImageView.viewWithTag(tagForTileAtIndex(irIndex)) as? TileView {
                            if let nearbyTileUpSlideInfo = nearbyTile.upSlideInfo {
                                // if nearby tile is already sliding check if it is also merging
                                if !nearbyTileUpSlideInfo.merge &&  currentTile.value == nearbyTile.value {
                                    // if nearby tile is NOT merging, and the values are equal then MERGE
                                    upSlideInfo = self.slideInfoTo(nearbyTileUpSlideInfo.destinationRow, column: column, merge: true)
                                    upSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextRow = nearbyTileUpSlideInfo.destinationRow + 1
                                    upSlideInfo = (nextRow < row) ? self.slideInfoTo(nextRow, column: column, merge: false) : nil
                                }
                            } else { // if nearby tile is NOT already sliding
                                if currentTile.value == nearbyTile.value {
                                    upSlideInfo = self.slideInfoTo(ir, column: column, merge: true)
                                    upSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextRow = ir + 1
                                    upSlideInfo = (nextRow < row) ? self.slideInfoTo(nextRow, column: column, merge: false) : nil
                                }
                            }
                            break
                        }
                    }
                    currentTile.upSlideInfo = upSlideInfo
                }
            }
        }
    }
    
    private func socializeDown() {
        
        for var column = 0; column < kGridSize; column++ { // iterate right to left
            
            let lastRow = kGridSize - 1
            for var row = lastRow-1; row >= 0; row-- { // iterate top to bottom

                let index = indexForPosition(row, column)
                if let currentTile = self.gridImageView.viewWithTag(tagForTileAtIndex(index)) as? TileView {
                    
                    var downSlideInfo: TileSlideInfo? = self.slideInfoTo(lastRow, column: column, merge: false)
                    for var ir = row+1; ir < kGridSize; ir++ { // iterate to slide down
                        let irIndex = indexForPosition(ir, column)
                        if let nearbyTile = self.gridImageView.viewWithTag(tagForTileAtIndex(irIndex)) as? TileView {
                            if let nearbyTileDownSlideInfo = nearbyTile.downSlideInfo {
                                // if nearby tile is already sliding check if it is also merging
                                if !nearbyTileDownSlideInfo.merge &&  currentTile.value == nearbyTile.value {
                                    // if nearby tile is NOT merging, and the values are equal then MERGE
                                    downSlideInfo = self.slideInfoTo(nearbyTileDownSlideInfo.destinationRow, column: column, merge: true)
                                    downSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextRow = nearbyTileDownSlideInfo.destinationRow - 1
                                    downSlideInfo = (nextRow > row) ? self.slideInfoTo(nextRow, column: column, merge: false) : nil
                                }
                            } else { // if nearby tile is NOT already sliding
                                if currentTile.value == nearbyTile.value {
                                    downSlideInfo = self.slideInfoTo(ir, column: column, merge: true)
                                    downSlideInfo!.tileToRemove = nearbyTile
                                } else {
                                    let nextRow = ir - 1
                                    downSlideInfo = (nextRow > row) ? self.slideInfoTo(nextRow, column: column, merge: false) : nil
                                }
                            }
                            break
                        }
                    }
                    currentTile.downSlideInfo = downSlideInfo
                    
                }
            }
        }
    }
}

