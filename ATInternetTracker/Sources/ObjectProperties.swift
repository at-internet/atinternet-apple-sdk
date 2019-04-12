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

//
//  ObjectProperties.swift
//  Tracker
//

import Foundation

public class ECommerceCart: RequiredPropertiesDataObject {
    override init() {
        super.init()
        propertiesPrefixMap["id"] = "s"
        propertiesPrefixMap["currency"] = "s"
        
        propertiesPrefixMap["creation_utc"] = "d"
        
        propertiesPrefixMap["turnovertaxincluded"] = "f"
        propertiesPrefixMap["turnovertaxfree"] = "f"
        
        propertiesPrefixMap["quantity"] = "n"
        propertiesPrefixMap["nbdistinctproduct"] = "n"
    }
}

public class ECommerceCustomer: RequiredPropertiesDataObject {
    override init() {
        super.init()
        propertiesPrefixMap["new"] = "b"
    }
}

public class ECommercePayment: RequiredPropertiesDataObject {
    override init() {
        super.init()
        propertiesPrefixMap["mode"] = "s"
    }
}

public class ECommerceProduct: RequiredPropertiesDataObject {
    override init() {
        super.init()
        propertiesPrefixMap["id"] = "s"
        propertiesPrefixMap["$"] = "s"
        propertiesPrefixMap["brand"] = "s"
        propertiesPrefixMap["currency"] = "s"
        propertiesPrefixMap["variant"] = "s"
        propertiesPrefixMap["category1"] = "s"
        propertiesPrefixMap["category2"] = "s"
        propertiesPrefixMap["category3"] = "s"
        propertiesPrefixMap["category4"] = "s"
        propertiesPrefixMap["category5"] = "s"
        propertiesPrefixMap["category6"] = "s"
        
        propertiesPrefixMap["discount"] = "b"
        propertiesPrefixMap["stock"] = "b"
        propertiesPrefixMap["cartcreation"] = "b"
        
        propertiesPrefixMap["pricetaxincluded"] = "f"
        propertiesPrefixMap["pricetaxfree"] = "f"
        
        propertiesPrefixMap["quantity"] = "n"
    }
    
    @objc public convenience init(obj: [String : Any]) {
        self.init()
        for (k,v) in obj {
            _ = self.set(key: k, value: v)
        }
    }
}

public class ECommerceShipping: RequiredPropertiesDataObject {
    override init() {
        super.init()
        propertiesPrefixMap["delivery"] = "s"
        
        propertiesPrefixMap["costtaxincluded"] = "f"
        propertiesPrefixMap["costtaxfree"] = "f"
    }
}

public class ECommerceTransaction: RequiredPropertiesDataObject {
    override init() {
        super.init()
        propertiesPrefixMap["id"] = "s"
    }
}
