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
import UIKit

extension UIImage {
    /**
     Crop : crop an UIImage
     
     - parameter rect: A Rectangle that represent the area to crop
     
     - returns: The cropped image
     */
    func crop(_ rect: CGRect) -> UIImage? {
        let rectangle = CGRect(x: rect.origin.x * self.scale,
            y: rect.origin.y*self.scale,
            width: rect.size.width*self.scale,
            height: rect.size.height*self.scale);
        
        let imageRef = self.cgImage?.cropping(to: rectangle);
        
        if let image = imageRef {
            let result = UIImage(cgImage: image, scale: self.scale, orientation: self.imageOrientation)
            return result;
        }
        else {
            return nil
        }
    }
    
    /**
     toBase64: convenience method to concert an image to a base64 String
     
     - returns: The base64 representation of the image
     */
    func toBase64 () -> String? {
        return UIImageJPEGRepresentation(self, 0.25)?.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
    }
}
