//
//  HamburgerMenuViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/11/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

protocol HamburgerMenuDelegate : class {
    func registerCells(tableView: UITableView)
    func getRowCount() -> Int
    func populateCellForRow(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
    func switchToViewController(index: Int) -> UIViewController
    func switchToViewController(name: String) -> UIViewController
    func switchingFromViewController(vc : UIViewController?)
}

class HamburgerMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var activeViewContainer: UIView!
    @IBOutlet weak var tableWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeViewContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableLeadingConstraint: NSLayoutConstraint!
    
    var burgerDelegate : HamburgerMenuDelegate!
    
    private var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.estimatedRowHeight = 50
        menuTableView.rowHeight = UITableViewAutomaticDimension
        menuTableView.layoutMargins = UIEdgeInsetsZero
        menuTableView.separatorInset = UIEdgeInsetsZero
        
        menuTableView.backgroundColor = Constants.Colors.Black
        
        // menu is hidden to start
        hideMenu(CGFloat(0.0))
      
        //tableWidthConstraint.constant = 0
        //tableLeadingConstraint.constant = 0
        
        // add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: "swiped:")
        self.view.addGestureRecognizer(panGesture)
        
        // register cells
        burgerDelegate.registerCells(menuTableView)
        
        // set initial view controller
        activeViewController = burgerDelegate.switchToViewController(0)
        updateActiveViewController()
                
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = burgerDelegate.populateCellForRow(tableView, indexPath: indexPath)
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        activeViewController = burgerDelegate?.switchToViewController(indexPath.row)
        hideMenu(CGFloat(0.0))
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return burgerDelegate.getRowCount()
    }
    
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if isViewLoaded() {
            if let inActiveVC = inactiveViewController {
                inActiveVC.willMoveToParentViewController(nil)
                inActiveVC.view.removeFromSuperview()
                inActiveVC.removeFromParentViewController()
                burgerDelegate.switchingFromViewController(inactiveViewController)
            }
        }
    }
    
    private func updateActiveViewController() {
        if isViewLoaded() {
            if let activeVC = activeViewController {
                addChildViewController(activeVC)
                activeVC.view.frame = activeViewContainer.bounds
                activeViewContainer.addSubview(activeVC.view)
                activeVC.didMoveToParentViewController(self)
            }
        }
    }

    // MARK: pan gesture recognizer
    var panStart : CGPoint!
    var isSwipingLeft : Bool = false
    @IBAction func swiped(recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            panStart = recognizer.locationInView(self.view)
        case .Changed:
            if recognizer.translationInView(self.view).x > panStart.x {
                isSwipingLeft = false
            }else{
                isSwipingLeft = true
            }
        case .Ended:
            if isSwipingLeft {
                // hide menu
                hideMenu(CGFloat(0.0))
            }else{
                // show menu
                showMenu(Constants.Sizes.HamburgerMenuVisibleWidth)
            }
        case .Cancelled:
            print("cancelled")
        default:
            print("default")
        }
    }
    
    private func hideMenu(size: CGFloat) {
        UIView .animateWithDuration(0.3, animations: { () -> Void in
            // move the menu off screen
            self.tableLeadingConstraint.constant = -1.0*Constants.Sizes.HamburgerMenuVisibleWidth
            
            // reposition the active view container on the screen
            self.activeViewContainerTrailingConstraint.constant = size
        });
    }
    
    private func showMenu(size: CGFloat) {
        UIView .animateWithDuration(0.3, animations: { () -> Void in
            // move the menu on screen
            self.tableLeadingConstraint.constant = 0

            // move the active view container off the screen
            self.activeViewContainerTrailingConstraint.constant = -1.0*size
        });
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
