//
//  Goal Data Service.swift
//  Dummy Game
//
//  Created by Scott Graessle on 12/1/15.
//  Copyright © 2015 Team Chaos. All rights reserved.
//

import Foundation

enum DailyGoal: String {
    case Sunday = "146df1bb-2ecf-4374-b523-bbee3f7668f4"
    case Monday = "749f97ad-7128-4b07-b93b-6b4156a2b841"
    case Tuesday = "82d4bd2d-f54f-4cf6-b226-9acd6d3ec69b"
    case Wednesday = "5fac3f18-705b-4b4d-8c47-bbf66cbbe726"
    case Thursday = "e730fdba-c448-41dd-a07b-6ac6e59daca4"
    case Friday = "927796e7-5ad7-4aef-ba88-7e0f32128fc4"
    case Saturday = "a348dcba-d4df-4dda-a571-f9ba6e14822a"
}

public class GoalData : NSObject {
    let id: String
    let desc: String
    var rewards: [String: AnyObject]?
    var stat_reset: [String: String]
    let type: String
    let created_at: String
    let updated_at: String
    
    public init(fromJSON json: JSON) {
        id = json["id"].stringValue
        desc = json["description"].stringValue
        type = json["type"].stringValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        stat_reset = [String: String]()
        for (key, subJson):(String, JSON) in json["stats"] {
            stat_reset[key] = subJson.stringValue
        }
    }
    
    static let DailyGoalId = [
        "146df1bb-2ecf-4374-b523-bbee3f7668f4",
        "749f97ad-7128-4b07-b93b-6b4156a2b841",
        "82d4bd2d-f54f-4cf6-b226-9acd6d3ec69b",
        "5fac3f18-705b-4b4d-8c47-bbf66cbbe726",
        "e730fdba-c448-41dd-a07b-6ac6e59daca4",
        "927796e7-5ad7-4aef-ba88-7e0f32128fc4",
        "a348dcba-d4df-4dda-a571-f9ba6e14822a"
    ]
}

public class GoalDataService {
    func fetchGoals(completion: (goals: [String:GoalData]?, error: ErrorType?) -> ()) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let goalUrl = NSURL(string: NSBundle.mainBundle().objectForInfoDictionaryKey("CCG Goal Data URL") as! String)
        let request = NSURLRequest(URL: goalUrl!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if (error == nil) {
                var goals = [String:GoalData]()
                let responseData = JSON(data: data!)
                if let goalJson = responseData["goals"].array {
                    for json in goalJson {
                        let goal = GoalData(fromJSON: json)
                        goals[goal.id] = goal
                    }
                }
                completion(goals: goals, error: nil)
            } else {
                completion(goals: nil, error: error)
            }
        }
        
        task.resume()
    }
}
