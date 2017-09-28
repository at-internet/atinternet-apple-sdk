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

// MARK: - Used to compute the height of the Label given a text and a font
extension UILabel {
    func resizeToFit () -> CGFloat {
        let h = self.expectedheight()
        var frame = self.frame
        frame.size.height = h
        self.frame = frame
        return frame.origin.y + frame.size.height
    }
    
    func expectedheight () -> CGFloat {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        let max = CGSize(width: self.frame.size.width,height: 9999)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let d:[NSAttributedStringKey: Any] = [NSAttributedStringKey.font:self.font, NSAttributedStringKey.paragraphStyle: paragraph]
        guard let text = self.text else {return 0}
        let x = text.boundingRect(with: max,options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: d, context: nil)
        return x.height
    }
}
