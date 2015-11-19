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
}

class GoalService {
    let session: NSURLSession

    // TODO update these from build process
    let appId = "7000"
    let accessId = "6cn3xNkCXRkjxOHkNi75"
    let secretKey = "gJs5tyBu4AzQqdLm8YFM8kEjdyiVIWStG6JqG89A"
    let baseUrl = "https://tc-ccg-integration.herokuapp.com"
    let relativeUrl = "/v3/goals/927796e7-5ad7-4aef-ba88-7e0f32128fc4"
    
    // TODO get from local storage
    let token = "SKVlrmtGUVcV1BsLUifDiU1ojkn9VbQyteHvj3Zb"

    class var sharedInstance: GoalService {
        struct Singleton {
            static let instance = GoalService()
        }
        return Singleton.instance
    }
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let epoch = String(Int(NSDate().timeIntervalSince1970))
        
        var stringToSign = "GET\n" + epoch
        stringToSign += "\nx-chaos-app-id:" + appId
        stringToSign += "\nx-chaos-timestamp:" + epoch
        stringToSign += "\nx-chaos-token:" + token
        stringToSign += "\n" + relativeUrl
        
        let signature = stringToSign.hmac(HMACAlgorithm.SHA256, key: secretKey)

        print("stringToSign: " + stringToSign)
        print("signature: " + signature)
        
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