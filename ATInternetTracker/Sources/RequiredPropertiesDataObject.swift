//
//  RequiredPropertiesDataObject.swift
//  Tracker
//
import Foundation

public class RequiredPropertiesDataObject : NSObject {
    
    var properties = [String : Any]()
    var propertiesPrefixMap = [String : String]()
    
    @objc public func set(key: String, value: Any) -> RequiredPropertiesDataObject {
        if let prefix = propertiesPrefixMap[key] {
            properties[String(format: "%@:%@", prefix, key)] = value
        } else {
            properties[key] = value
        }
        return self
    }
    
    @objc public func setAll(obj: [String : Any]) -> RequiredPropertiesDataObject {
        for (k,v) in obj {
            if let prefix = propertiesPrefixMap[k] {
                properties[String(format: "%@:%@", prefix, k)] = v
            } else {
                properties[k] = v
            }
        }
        return self
    }
    
    func get(key: String) -> Any? {
        return properties[key]
    }
}
