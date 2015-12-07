//
//  GoalService.swift
//  Breakaway Challenge
//
//  Created by Scott Graessle on 11/13/15.
//
//

import Foundation

public class GoalCounter : NSObject {
    let id: String
    let goal_id: String
    let account_id: String
    var stats: [String: String]
    let last_rewarded_at: String
    let created_at: String
    let updated_at: String
    
    public init(fromJSON json: JSON) {
        id = json["id"].stringValue
        goal_id = json["goal_id"].stringValue
        account_id = json["account_id"].stringValue
        last_rewarded_at = json["last_rewarded_at"].stringValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        stats = [String: String]()
        for (key, subJson):(String, JSON) in json["stats"] {
            stats[key] = subJson.stringValue
        }
    }
    
    public func rewardedToday() -> Bool {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxx"
        if let lastAward = formatter.dateFromString(last_rewarded_at) {
            let cal = NSCalendar.currentCalendar()
            let last = cal.components([.Year, .Month, .Day], fromDate: lastAward)
            let today = cal.components([.Year, .Month, .Day], fromDate: NSDate())
            return last == today
        }
        return false
    }
}

class GoalService {
    var baseUrl = ""
    var relativeUrl = "/v3/goals/927796e7-5ad7-4aef-ba88-7e0f32128fc4"

    let session: NSURLSession

    init(token: String, goalId: String) {
        let epoch = String(Int(NSDate().timeIntervalSince1970))
        
        relativeUrl = "/v3/goals/\(goalId)"
        baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("CCG Base URL") as! String
        let appId = NSBundle.mainBundle().objectForInfoDictionaryKey("CCG App ID") as! String
        let accessId = NSBundle.mainBundle().objectForInfoDictionaryKey("CCG Access ID") as! String
        let secret = NSBundle.mainBundle().objectForInfoDictionaryKey("CCG Secret") as! String

        let stringToSign = "GET\n" + epoch
            + "\nx-chaos-app-id:" + appId
            + "\nx-chaos-timestamp:" + epoch
            + "\nx-chaos-token:" + token
            + "\n" + relativeUrl
        
        let signature = stringToSign.hmac(HMACAlgorithm.SHA256, key: secret)
        print("stringToSign: " + stringToSign)
        print("signature: " + signature)
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = [
            "Authorization" : "CHAOS " + accessId + ":" + signature,
            "x-chaos-app-id" : appId,
            "x-chaos-timestamp" : epoch,
            "x-chaos-token" : token,
        ]
        session = NSURLSession(configuration: configuration)
    }

    func getStatus(completion: (counter: GoalCounter?, error: NSError?) -> ()) {
        let goalUrl = NSURL(string: relativeUrl, relativeToURL: NSURL(string: baseUrl))
        let request = NSURLRequest(URL: goalUrl!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error == nil {
                print("response:\n \(response.debugDescription)")
                let responseData = JSON(data: data!)
                print("responseDict:\n \(responseData.debugDescription)")
                let payload = responseData["payload"]
                let gc = payload["goal_counter"]
                let counter = GoalCounter(fromJSON: gc)
                completion(counter: counter, error: nil)
            } else {
                completion(counter: nil, error: error)
            }
        }
        
        task.resume()
    }
    
    
}