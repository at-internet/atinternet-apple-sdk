//
//  RequiredPropertiesDataObject.swift
//  Tracker
//
import Foundation

public class RequiredPropertiesDataObject : NSObject {
    
    fileprivate let propertiesSynchronizer = DispatchQueue(label: "PropertiesSynchronizer")
    fileprivate var properties = [String : Any]()
    
    @objc public func get(key: String) -> Any? {
           var val : Any? = nil
           self.propertiesSynchronizer.sync {
               val = self.properties[key]
           }
           return val
       }
    
    @objc public func set(key: String, value: Any) -> RequiredPropertiesDataObject {
        self.propertiesSynchronizer.async {
            self.properties[key] = value
        }
        return self
    }
    
    @objc public func del(key: String) -> RequiredPropertiesDataObject {
        self.propertiesSynchronizer.async {
            self.properties.removeValue(forKey: key)
        }
        return self
    }
    
    @objc public func getProps() -> [String : Any] {
        var props: [String : Any] = [String : Any]()
        self.propertiesSynchronizer.sync {
            props = self.properties
        }
        return props 
    }
    
    @objc public func setProps(obj: [String : Any]) -> RequiredPropertiesDataObject {
        self.propertiesSynchronizer.async {
            for (k,v) in obj {
                self.properties[k] = v
            }
        }
        return self
    }
    
    @objc public func delProps() -> RequiredPropertiesDataObject {
        self.propertiesSynchronizer.async {
            self.properties.removeAll()
        }
        return self
    }
    
    @available(*, deprecated, message: "Use 'setProps()' method instead")
    @objc public func setAll(obj: [String : Any]) -> RequiredPropertiesDataObject {
        return setProps(obj: obj)
    }
}
