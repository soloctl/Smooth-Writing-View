//
//  WritingView.swift
//  Smooth Writing View
//
//  Created by Solomon Li on 2/7/15.
//  Copyright (c) 2015 Solomon Li, Maid in China. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit


class SmoothWritingView: UIView {

    @IBInspectable var strokeWidth:CGFloat = 7
    @IBInspectable var strokeColor = UIColor.blackColor()
    
    // MARK: - Properties
    let minDistanceSquared:CGFloat = 16 // as if min distance is 4
    var lastPoint:CGPoint = CGPoint()
    var previousLastPoint:CGPoint = CGPoint()
    var currentPoint:CGPoint = CGPoint()
    var path = CGPathCreateMutable()
    var empty = false
    
    // MARK: - Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - Override methods
    override func drawRect(rect: CGRect) {
        
        self.backgroundColor?.set()
        UIRectFill(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path)
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, strokeWidth)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextStrokePath(context)
        self.empty = false
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        
        self.lastPoint = touch.previousLocationInView(self)
        self.previousLastPoint = touch.previousLocationInView(self)
        self.currentPoint = touch.locationInView(self)
        self.touchesMoved(touches, withEvent: event) // workaround zero move
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(self)
        
        // if the finger has moved too short to less than the min distance, then ignore this move
        let dx:CGFloat = point.x - self.currentPoint.x;
        let dy:CGFloat = point.y - self.currentPoint.y;
        if ((dx * dx + dy * dy) < minDistanceSquared) {
            return;
        }
        
        // rules: previousLast -> mid1 -> last -> mid2 -> current
        self.previousLastPoint = self.lastPoint
        self.lastPoint = touch.previousLocationInView(self)
        self.currentPoint = touch.locationInView(self)
        
        let mid1:CGPoint = mid(point1: self.lastPoint, point2: self.previousLastPoint)
        let mid2:CGPoint = mid(point1: self.currentPoint, point2: self.lastPoint)
        
        // to represent the finger move, create a new path segment,
        // a quadratic bezier path from mid1 to mid2, using previous as a control point
        let subpath = CGPathCreateMutable();
        CGPathMoveToPoint(subpath, nil, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(subpath, nil,
            self.lastPoint.x, self.lastPoint.y,
            mid2.x, mid2.y);
        
        // compute the rect containing the new segment plus padding for drawn line
        let bounds:CGRect = CGPathGetBoundingBox(subpath);
        let drawBox:CGRect = CGRectInset(bounds, -2.0 * self.strokeWidth, -2.0 * self.strokeWidth);
        
        // append the quad curve to the accumulated path so far
        CGPathAddPath(path, nil, subpath);

        self.setNeedsDisplayInRect(drawBox)
    }
    
    // MARK: - Methods
    func clear() {
        path = CGPathCreateMutable()
        self.setNeedsDisplay()
    }
    
    func mid(#point1: CGPoint, point2: CGPoint) -> CGPoint {
        return CGPointMake((point1.x + point2.x) * 0.5, (point1.y + point2.y) * 0.5)
    }
}
