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
    
    @IBOutlet weak var goalButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    var goalStatus: GoalCounter?
    var goals = [String: GoalData]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[TodayViewController] viewDidLoad")
        // Do any additional setup after loading the view from its nib.
        self.goalButton.setTitle("--", forState: UIControlState.Normal)
        self.statusLabel.text = "--"
        fetchGoals { error in
            if error == nil {
                // update content
                print("[TodayViewController] fetchGoals: \(self.getDailyGoal()!.desc)")
                self.goalButton.setTitle(self.getDailyGoal()!.desc, forState: UIControlState.Normal)
                self.goalButton.setNeedsLayout()
            } else {
                print("[TodayViewController] fetchGoals Error: \(error.debugDescription)")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("[TodayViewController] viewDidAppear")
        
        fetchGoalStatus { error in
            if error == nil {
                self.updateStatus()
            }
            else {
                print("[TodayViewController] Error: " + error.debugDescription)
            }
        }
    }
    
    func updateStatus() {
        if self.goalStatus != nil && self.goalStatus!.rewardedToday() {
            self.statusLabel.text = "COMPLETED"
        } else {
            self.statusLabel.text = "OPEN"
        }
        self.statusLabel.setNeedsLayout()
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
        fetchGoalStatus { error in
            if error == nil {
                self.updateStatus()
                completionHandler(.NewData)
            } else {
                completionHandler(.Failed)
            }
        }
    }
    
    @IBAction func goalPressed(sender: UIButton, forEvent event: UIEvent) {
        let url = NSBundle.mainBundle().objectForInfoDictionaryKey("CCG Launch URL") as! String
        extensionContext?.openURL(NSURL(string: url)!, completionHandler: nil)
    }
    
    enum RequestError : ErrorType {
        case MissingGoalData
        case NilAuthToken
    }
    
    func fetchGoalStatus(completion: (error: ErrorType?) -> ()) {
        print("[TodayViewController] fetchGoalStatus")
        let defaults = NSUserDefaults.init(suiteName: (NSBundle.mainBundle().objectForInfoDictionaryKey("App Group") as! String))
        if let authToken = defaults?.stringForKey("authToken") {
            print("[TodayViewController] Found authToken '\(authToken)'")
            if let goalId = self.getDailyGoal()?.id {
                GoalService(token: authToken, goalId: goalId).getStatus { counter, error in
                    print("[TodayViewController] counter \(counter.debugDescription)")
                    self.goalStatus = counter
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(error: error)
                    }
                }
            } else {
                completion(error: RequestError.MissingGoalData)
            }
        } else {
            completion(error: RequestError.NilAuthToken)
        }
    }
    
    func fetchGoals(completion: (error: ErrorType?) -> ()) {
        print("[TodayViewController] fetchGoals")
        GoalDataService().fetchGoals { goals, error in
            self.goals = goals!
            dispatch_async(dispatch_get_main_queue()) {
                completion(error: error)
            }
        }
    }
    
    func dayOfWeek() -> Int {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let comp = cal.components(.Weekday, fromDate: NSDate())
        return comp.weekday
    }
    
    func getDailyGoal() -> GoalData? {
        return goals[GoalData.DailyGoalId[dayOfWeek() - 1]]
    }
}
