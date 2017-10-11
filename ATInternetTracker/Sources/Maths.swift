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

/// Basic Maths operations
class Maths {
    static let PI = CGFloat(Double.pi)
    
    /**
     Substract 2 CGPoints
     
     - parameter a: point a
     - parameter b: point b
     
     - returns: a-b
     */
    class func CGPointSub(_ a: CGPoint, b: CGPoint) -> CGPoint {
        return CGPoint(x: a.x-b.x, y: a.y-b.y)
    }
    
    /**
     Distance between 2 CGPoints
     
     - parameter a: point a
     - parameter b: point b
     
     - returns: the distance
     */
    class func CGPointDist(_ a: CGPoint, b:CGPoint) -> CGFloat {
        return sqrt(  (b.x-a.x)*(b.x-a.x) + (b.y-a.y)*(b.y-a.y) )
    }
    
    /**
     helper method for distance between 2 points
     
     - parameter a: a point
     
     - returns: ??
     */
    class func CGPointLen(_ a: CGPoint) -> Float {
        return sqrtf(Float(a.x*a.x+a.y*a.y))
    }
    
    /**
     Angle between 2 lines (defined by 4 points)
     
     - parameter initialP1: Line1.p1
     - parameter initialP2: Line1.p2
     - parameter finalP1:   Line2.p1
     - parameter finalP2:   Line2.p2
     
     - returns: the angle between the 2 lines in degree 0-360
     */
    class func angleBetween(_ initialP1: CGPoint, initialP2: CGPoint, finalP1: CGPoint, finalP2: CGPoint) -> CGFloat {
        let vector1 = (initialP1.x - initialP2.x, initialP1.y - initialP2.y)
        let vector2 = (finalP1.x - finalP2.x, finalP1.y - finalP2.y)
        var angle = atan2(vector2.1, vector2.0) - atan2(vector1.1, vector1.0);
        if angle < 0 {
            angle += 2 * PI;
        }
        return angle*180/PI

    }
}
