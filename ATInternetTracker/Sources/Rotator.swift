/*
 This SDK is licensed under the MIT license (MIT)
 Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


import Foundation
import CoreGraphics

/// Helper class to handle rotations
class Rotator {
    /// the initial touch points
    var initialPoints: (CGPoint, CGPoint)
    
    /// the current touch points
    var currentPoints: (CGPoint, CGPoint)
    
    /// the initial rotation (~0)
    var initialRotation:CGFloat?
    
    /**
     Init method with the 2 initial touch location
     
     - parameter p1: p1
     - parameter p2: p2
     
     - returns: Rotator object
     */
    init(p1: CGPoint, p2: CGPoint) {
        initialPoints = (p1, p2)
        currentPoints = (p1, p2)
        initialRotation = nil
    }
    
    /**
     Set the current touch points
     
     - parameter p1: p1
     - parameter p2: p2
     */
    func setCurrentPoints(_ p1: CGPoint, p2: CGPoint) {
        currentPoints = (p1, p2)
        if initialRotation == nil {
            initialRotation = getCurrentRotation()
        }
    }
    
    /**
     get the current rotation between the initial and current lines formed by the 4 points
     
     - returns: the value between -180/180 degree
     */
    func getCurrentRotation() -> CGFloat {
        let angle = Maths.angleBetween(initialPoints.0, initialP2: initialPoints.1, finalP1: currentPoints.0, finalP2: currentPoints.1)
        if angle > 180 {
            return angle-360
        }
        return angle
    }
    
    /**
     check if the 2 lines (formed by the 2 points) are considered as a rotation
     
     - returns: true if we consider it as a rotation
     */
    func isValidRotation() -> Bool {
        if let _ = initialRotation {
            return (abs(initialRotation! - getCurrentRotation())) > 30 && (abs(initialRotation! - getCurrentRotation()) < 150)
        } else {
            return false
        }
    }
}
