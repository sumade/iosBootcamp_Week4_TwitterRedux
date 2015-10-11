//
//  TwitterHamburgers.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/11/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import Foundation
import UIKit

class TwitterHamburgers : HamburgerMenuDelegate {
    
    private var viewControllers = [UIViewController]()
    private var names = [String]()
    private var images = [UIImage?]()
    private unowned var storyboard : UIStoryboard
    
    private enum MahViews : Int {
        case HomeTimeline = 0
        case ProfileView = 1
        case Mentions = 2
    }
    
    init(storyboard : UIStoryboard ){
        self.storyboard = storyboard

        initializeData()        
    }
    
    private func initializeData() {
        // create the home timeline controllers
        let homeVC = storyboard.instantiateViewControllerWithIdentifier(Constants.Storyboards.timelineStoryboardName) as! TimelineViewController
        homeVC.isHandlingMentions = false
        
        // passed user will always be the current user when instantiated from here
        let profileVC = storyboard.instantiateViewControllerWithIdentifier(Constants.Storyboards.profileStoryboardName) as! UserProfileViewController
        profileVC.passedUser = User.currentUser
        
        // create the mentions view controller
        let mentionVC = storyboard.instantiateViewControllerWithIdentifier(Constants.Storyboards.timelineStoryboardName) as! TimelineViewController
        mentionVC.isHandlingMentions = true

        viewControllers = [homeVC, profileVC, mentionVC]
        
        // create the names array
        names = [ "My Home", "My Profile", "My Mentions"]
        
        // set the images for the cells
        images = [ UIImage(named: "timeline"), UIImage(named:"my_profile"), UIImage(named: "mentions") ]
    }
    
    func registerCells(tableView: UITableView) {
        let cellNib = UINib(nibName: Constants.TableCells.twitterBurgersCellName, bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: Constants.TableCells.twitterBurgersCellName)
    }
    
    func getRowCount() -> Int {
        return viewControllers.count
    }
    
    func populateCellForRow(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.twitterBurgersCellName) as! TwitterBurgerTableViewCell
        
        cell.theImageView.image = images[indexPath.row]
        cell.theNameLabel.text = names[indexPath.row]
                
        return cell
    }

    func switchToViewController(index: Int) -> UIViewController {
        // do any prework...        
        return viewControllers[index]
    }

    func switchToViewController(name: String) -> UIViewController {
        if let index = names.indexOf(name)  {
            return viewControllers[index]
        }else{
            // just return the first one, print error
            print("unknown name! \(name)")
            return viewControllers[0]
        }
    }
    
    func switchingFromViewController(vc : UIViewController?) {
        if let vc = vc {
            if vc == self.viewControllers[MahViews.ProfileView.rawValue] {
                // in the profile view... clear the user stack
                let profileVC = vc as! UserProfileViewController
                profileVC.clearStack()
            }
        }
    }

}