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
//  Campaign.swift
//  Tracker
//

import Foundation

enum CampaignKeys: String, EnumCollection {
    case ATCampaign = "ATCampaign"
    case ATCampaignDate = "ATCampaignDate"
    case ATCampaignAdded = "ATCampaignAdded"
}

/// Wrapper class for marketing campaign tracking
public class Campaign: ScreenInfo {
    /// Campaign id (XTO)
    @objc public var campaignId: String = ""
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /// Create a new campaign with an identifier
    ///
    /// - Parameter campaignId: campaignId identifier
    @objc public init(campaignId: String) {
        super.init()
        
        self.campaignId = campaignId
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let userDefaults = UserDefaults.standard
        let encodeOption = ParamOption()
        encodeOption.encode = true
        
        if let remanentCampaign = userDefaults.value(forKey: CampaignKeys.ATCampaign.rawValue) as? String, let campaignDate = userDefaults.object(forKey: CampaignKeys.ATCampaignDate.rawValue) as? Date {
            let nbDays: Int = Tool.daysBetweenDates(campaignDate, toDate: Date())
            
            if let campaignValue = tracker.configuration.parameters["campaignLifetime"], let campaignIntValue = Int(campaignValue), nbDays > campaignIntValue {
                userDefaults.removeObject(forKey: CampaignKeys.ATCampaign.rawValue)
            } else {
                let remanent = remanentCampaign
                
                _ = tracker.setParam("xtor", value: remanent, options: encodeOption)
            }
        } else {
            _ = Privacy.storeData(Privacy.StorageFeature.campaign, pairs: (CampaignKeys.ATCampaignDate.rawValue, Date()), (CampaignKeys.ATCampaign.rawValue, campaignId))
        }
        
        _ = tracker.setParam("xto", value: campaignId, options: encodeOption)
        _ = Privacy.storeData(Privacy.StorageFeature.campaign, pairs: (CampaignKeys.ATCampaignAdded.rawValue, true))
        
        if(tracker.configuration.parameters["campaignLastPersistence"]?.lowercased() == "true") {
            _ = Privacy.storeData(Privacy.StorageFeature.campaign, pairs: (CampaignKeys.ATCampaignDate.rawValue, Date()), (CampaignKeys.ATCampaign.rawValue, campaignId))
        }
    }
}

/// Wrapper class to manage Campaign instances
public class Campaigns: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Campaigns initializer
    - parameter tracker: the tracker instance
    - returns: Campaigns instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    /// Add tagging data for a campaign
    ///
    /// - Parameter campaignId: campaign identifier
    /// - Returns: the Campaign instance
    @objc public func add(campaignId: String) -> Campaign {
        let campaign = Campaign(tracker: tracker)
        campaign.campaignId = campaignId
        tracker.businessObjects[campaign.id] = campaign
        
        return campaign
    }
}
