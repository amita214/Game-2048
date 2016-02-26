//
//  GridViewController.swift
//  Game-2048
//
//  Created by Amita Pai on 2/25/16.
//  Copyright © 2016 Amita Pai. All rights reserved.
//

import UIKit

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


enum TileSwipeDirection {
    case Left, Right, Up, Down, None
}

class GridViewController: UIViewController {

    @IBOutlet weak var gridImageView: UIImageView!
    
    var swipeDirection: TileSwipeDirection = .None
    var numberOfAddedTiles: Int = 0
    
    @IBOutlet weak var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var upwardSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var downwardSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func initializeGrid() {
        self.numberOfAddedTiles = 0
        self.swipeDirection = .None
        
    }

    // MARK: - IB Action
    @IBAction func resetGameAction(sender: UIBarButtonItem) {
        for tile in self.gridImageView.subviews {
            tile.removeFromSuperview()
        }
        self.numberOfAddedTiles = 0
        
        self.createRandomTile()
        self.createRandomTile()
    }
    
    @IBAction func didSwipe(sender: AnyObject) {
        
    }
    
    // MARK: - Grid related calculation
    private func hDimensionForGrid(value: Double) -> CGFloat {
        return CGFloat(value) * self.gridImageView.frame.width / CGFloat(kRefDimension)
    }
    
    private func vDimensionForGrid(value: Double) -> CGFloat {
        return CGFloat(value) * self.gridImageView.frame.height / CGFloat(kRefDimension)
    }
    
    private func originFor(row:Int, column:Int) -> CGPoint {
        let x = self.hDimensionForGrid(kOuterPadding + (kWidth + kInnerPadding) * Double(row))
        let y = self.vDimensionForGrid(kOuterPadding + (kHeight + kInnerPadding) * Double(column))
        return CGPointMake(CGFloat(x), CGFloat(y))
    }
    
    private func frameFor(row:Int, column:Int) -> CGRect {
        let origin = self.originFor(row, column: column)
        return CGRectMake(origin.x, origin.y, self.hDimensionForGrid(kWidth), self.vDimensionForGrid(kHeight))
    }
    
    // MARK: - Tile creation, deletion
    private func createRandomTile() {
        if self.numberOfAddedTiles == kMaxTileCount {
            return
        }
        
        var tileIndex:UInt32 = 0
        repeat {
            tileIndex = arc4random_uniform(UInt32(kMaxTileCount))
        } while (self.tileExistsAtIndex(tileIndex))
        
        self.createTileAt(rowFromIndex(Int(tileIndex)), column: columnFromIndex(Int(tileIndex)), value: random2Or4())
    }
    
    private func tileExistsAtIndex(index: UInt32) -> Bool {
        for tile in self.gridImageView.subviews as! [TileView] {
            if tile.index == Int(index) {
//                print("\(index): exists")
                return true
            }
        }
//        print("\(index): not exists")
        return false
    }

    private func createTileAt(row: Int, column: Int, value: Int) {
        let frame = self.frameFor(row, column: column)
        let tile = TileView(frame: frame, value: value, index: indexForPosition(row, column))
        self.gridImageView.addSubview(tile)
        self.numberOfAddedTiles++
    }
    
    private func removeTileAt(row: Int, column: Int) {
        if let tile = self.gridImageView.viewWithTag(kTileTagStart + indexForPosition(row, column)) as? TileView {
            tile.removeFromSuperview()
            self.numberOfAddedTiles--
        }
    }
}

