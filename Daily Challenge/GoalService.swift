//
//  GoalService.swift
//  Breakaway Challenge
//
//  Created by Scott Graessle on 11/13/15.
//
//

import Foundation
import CryptoSwift

public class GoalCounter : NSObject {
    let id: String
    let goal_id: String
    let account_id: String
    let stats: [String: AnyObject]
    let last_rewarded_at: String
    let created_at: String
    let updated_at: String
    
    public init(fromJSON json: JSON) {
        id = json["id"].string!
        goal_id = json["goal_id"].string!
        account_id = json["account_id"].string!
        stats = json["stats"].dictionaryObject!
        last_rewarded_at = json["last_recorded_at"].string!
        created_at = json["created_at"].string!
        updated_at = json["updated_at"].string!
    }
}

class GoalService {
    let session: NSURLSession
    
    class var sharedInstance: GoalService {
        struct Singleton {
            static let instance = GoalService()
        }
        return Singleton.instance
    }
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let authString = ""
        let appId = "7000"
        let epoch = String(Int(NSDate().timeIntervalSince1970))
        let token = ""
        let accessId = ""
        let relativeUrl = "v3/goals"
        
        var stringToSign = "GET\n" + epoch
        stringToSign += "\nx-chaos-app-id:" + appId
        stringToSign += "\nx-chaos-timestamp:" + epoch
        stringToSign += "\nx-chaos-token:" + token
        stringToSign += "\n" + relativeUrl
        
        let signature = stringToSign

        configuration.HTTPAdditionalHeaders = [
            "Authorization" : "CHAOS " + accessId + ":" + signature,
            "x-chaos-app-id" : appId,
            "x-chaos-timestamp" : epoch,
            "x-chaos-token" : token,
        ]
        session = NSURLSession(configuration: configuration)
    }

    func getStatus(completion: (counter: GoalCounter?, error: NSError?) -> ()) {
        let baseUrl = NSURL(string: "https://tc-ccg-integration/")
        let goalUrl = NSURL(string: "goals", relativeToURL: baseUrl)
        let request = NSURLRequest(URL: goalUrl!)
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error == nil {
                do {
                    let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    let counter = GoalCounter(fromJSON: JSON(responseDictionary))
                    completion(counter: counter, error: nil)
                } catch let jsonError as NSError {
                    completion(counter: nil, error: jsonError)
                }
            } else {
                completion(counter: nil, error: error)
            }
        }
        
        task.resume()
    }
}