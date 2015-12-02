//
//  TodayViewController.swift
//  nba today
//
//  Created by Scott Graessle on 11/12/15.
//
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var goalText: UILabel!

    var goalStatus: GoalCounter?
    var goals = [String: GoalData]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[TodayViewController] viewDidLoad")
        // Do any additional setup after loading the view from its nib.
        fetchGoals { error in
            if error == nil {
                // update content
                self.goalText.text = self.goals["146df1bb-2ecf-4374-b523-bbee3f7668f4"]?.desc
            } else {
                print("[TodayViewController] Error: \(error.debugDescription)")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("[TodayViewController] viewDidAppear")
        
        fetchGoalStatus { error in
            if error == nil {
                // update content
                print("[TodayViewController] goal update: " + (self.goalStatus?.goal_id)! ?? "INVALID")
            }
            else {
                print("[TodayViewController] Error: " + error.debugDescription)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    enum RequestError : ErrorType {
        case NilAuthToken(String)
    }
    
    func fetchGoalStatus(completion: (error: ErrorType?) -> ()) {
        print("[TodayViewController] fetchGoalStatus")
        let suite = NSBundle.mainBundle().objectForInfoDictionaryKey("App Group") as! String
        let defaults = NSUserDefaults.init(suiteName: suite)
        let authToken = defaults!.stringForKey("authToken")
        print("[TodayViewController] Found authToken '\(authToken)'")

        if (authToken != nil) {
            GoalService(token: authToken!).getStatus { counter, error in
                print("[TodayViewController] counter \(counter.debugDescription)")
                self.goalStatus = counter
                completion(error: error)
            }
        } else {
            completion(error: RequestError.NilAuthToken("No auth token found."))
        }
    }
    
    func fetchGoals(completion: (error: ErrorType?) -> ()) {
        GoalDataService().fetchGoals { goals, error in
            self.goals = goals!
            completion(error: error)
        }
    }
    
}
