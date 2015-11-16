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
    
    var goalStatus: GoalCounter?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchGoalStatus { error in
            if error == nil {
                // update content
                print("goal update: " + (self.goalStatus?.goal_id)! ?? "INVALID")
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
    
    func fetchGoalStatus(completion: (error: NSError?) -> ()) {
        GoalService.sharedInstance.getStatus { counter, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.goalStatus = counter
                completion(error: error)
            }
        }
    }
    
}
