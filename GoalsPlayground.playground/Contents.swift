//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import Foundation

public class GoalData : NSObject {
    let id: String
    let goalDescription: String
    var rewards: [String: AnyObject]?
    var stat_reset: [String: String]
    let type: String
    let created_at: String
    let updated_at: String
    
    public init(fromJSON json: JSON) {
        id = json["id"].stringValue
        goalDescription = json["description"].stringValue
        type = json["type"].stringValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        stat_reset = [String: String]()
        for (key, subJson):(String, JSON) in json["stats"] {
            stat_reset[key] = subJson.stringValue
        }
    }
}

var str = "Hello, playground"


let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
let goalUrl = NSURL(string: "https://s3.amazonaws.com/assets-integration.gamepass.com/7000/data/goals.json")
let request = NSURLRequest(URL: goalUrl!)

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let task = session.dataTaskWithRequest(request) { (data, response, error) in
    if (error == nil) {
        let responseData = JSON(data: data!)
        if let goalJson = responseData["goals"].array {
            var goals = [String:GoalData]()
            for json in goalJson {
                let goal = GoalData(fromJSON: json)
                goals[goal.id] = goal
            }
            goals
        }
    } else {
        print("error: \(error.debugDescription)")
//        completion(goal: nil, error: error)
    }
}

//task.resume()
//task.response

//    {
//    "payload" : {
//        "goal_counter" : {
//            "stats" : {
//                "daily_quest:completed" : 0
//            },
//            "goal_id" : "749f97ad-7128-4b07-b93b-6b4156a2b841",
//            "id" : "ab5b3e8c-e629-4f1b-8c95-622063354d6a",
//            "last_rewarded_at" : null,
//            "created_at" : "2015-12-07 17:53:06 +0000",
//            "updated_at" : "2015-12-07 17:53:06 +0000",
//            "account_id" : "0e4f88d2-f467-4ccd-bd03-c1bf497ac18b"
//        }
//    }

let last = "2015-12-07 19:53:06 +0000"
var formatter = NSDateFormatter()
formatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxx"

if let lastAward = formatter.dateFromString(last) {
    "yes"
    lastAward
    let cal = NSCalendar.currentCalendar()
    let delta = cal.components([.Year, .Month, .Day], fromDate: lastAward)
    let today = cal.components([.Year, .Month, .Day], fromDate: NSDate())
    delta == today
} else {
    "no"
}


let calendar = NSCalendar.currentCalendar()
NSDate()
calendar.components(.Weekday, fromDate: NSDate()).weekday

