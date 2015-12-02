//
//  Goal Data Service.swift
//  Dummy Game
//
//  Created by Scott Graessle on 12/1/15.
//  Copyright © 2015 Team Chaos. All rights reserved.
//

import Foundation

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
