//
//  ProfileViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/10/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit
import UIImageEffects

struct UserStack {
    private var items = [User]()
    mutating func push(item: User) {
        items.append(item)
    }
    mutating func pop() -> User {
        return items.removeLast()
    }
    func peek() -> User? {
        return items.last
    }
    mutating func clear() {
        return items.removeAll()
    }
    var isEmpty : Bool {
        return items.isEmpty
    }
    var count : Int {
        return items.count
    }
}

protocol ShowProfileDelegate : class {
    func showProfileVC(user: User)
}

class UserProfileViewController: UIViewController, TimelineControllerReloadDelegate, TimelineScrollDelegate, ShowProfileDelegate {

    // MARK: model
    weak var passedUser : User?
    private var displayedUser : User! {
        didSet {
            // populate ui elements
            if let bannerURL = displayedUser.bannerURL {
                profileHeaderImageView.hidden = false
                profileHeaderImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: bannerURL)!), placeholderImage: nil, success: {
                    (request, response, image) -> Void in
                        self.bannerImage = image
                        self.profileHeaderImageView.image = image
                    }, failure: nil)
                self.profileHeaderView.sendSubviewToBack(profileHeaderImageView)
            }else{
                profileHeaderImageView.image = nil
                profileHeaderImageView.hidden = true
                profileHeaderView.backgroundColor = Constants.Colors.Blue
                self.bannerImage = nil
            }
            
            profileHeaderNameLabel.text = displayedUser.name
            profileHeaderNumTweetsLabel.text = "\(Helpers.formatNumberAsCondensed(displayedUser.numberOfTweets)) Tweets"
        }
    }
    
    // for keeping track of users....
    private var usersStack = UserStack() {
        didSet {
            self.shouldShowBackButton()
        }
    }
    
    // MARK: hacks
    var refreshControl : UIRefreshControl!
    
    // MARK: timeline controller
    var timelineController = TimelineController()
    
    // MARK: ui elements
    @IBOutlet private weak var timelineTableView: UITableView!
    @IBOutlet private weak var profileHeaderView: UIView!
    @IBOutlet private weak var profileHeaderNumTweetsLabel: UILabel!
    @IBOutlet private weak var profileHeaderNameLabel: UILabel!
    @IBOutlet private weak var profileHeaderImageView: UIImageView!
    @IBOutlet weak var backButton: UIImageView!
    
    private var profileDetailsView : UserProfileDetailsView!
    
    // MARK: UI Constraints
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageViewTopConstraint: NSLayoutConstraint!
    
    // MARK : other vars
    private var showCondensedHeader = false
    private var bannerImage : UIImage?
    private var oldHeight = Constants.Sizes.UserProfileHeaderHeightMax
    private var oldDistanceFromTop = Constants.Sizes.UserProfileHeaderHeightMax
    private var currentBorder : CALayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the user
        usersStack.push(self.passedUser!)

        // Do any additional setup after loading the view.
        
        // setup table view
        timelineController.reloadDelegate = self
        timelineController.scrollDelegate = self
        timelineController.profileViewDelegate = self
        timelineTableView.delegate = timelineController
        timelineTableView.dataSource = timelineController
        timelineTableView.estimatedRowHeight = 100
        timelineTableView.rowHeight = UITableViewAutomaticDimension
        timelineTableView.layoutMargins = UIEdgeInsetsZero
        timelineTableView.separatorInset = UIEdgeInsetsZero
        
        
        // refresh hack
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshUserTimeline", forControlEvents: UIControlEvents.ValueChanged)
        let dummyTableVC = UITableViewController()
        dummyTableVC.tableView = timelineTableView
        dummyTableVC.refreshControl = refreshControl
                
        // instantiate table header view --> shows the user profile information
        profileDetailsView = UserProfileDetailsView(frame: timelineTableView.frame)

        showAUser()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureProfileDetailsView() {
        profileDetailsView.user = displayedUser
        timelineTableView.tableHeaderView = profileDetailsView
        
        // adjust height of table header
        profileDetailsView.setNeedsLayout()
        profileDetailsView.layoutIfNeeded()
        let height = profileDetailsView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = profileDetailsView.frame
        frame.size.height = height
        profileDetailsView.frame = frame
        
        // set table header to trigger height change
        timelineTableView.tableHeaderView = profileDetailsView
        
        // add bottom border to profile details (aka table header view)
        // check if border already exists, and clear if so (otherwise we get multiple lines)
        if let current = currentBorder {
            current.removeFromSuperlayer()
        }
        
        let border = CALayer()
        border.backgroundColor = Constants.Colors.DarkGrey.CGColor
        let borderHeight = CGFloat(1.0)
        border.frame = CGRectMake(0, profileDetailsView.frame.size.height - borderHeight, profileDetailsView.frame.size.width, borderHeight)
        profileDetailsView.layer.addSublayer(border)
        currentBorder = border

    }
    
    func initializeNameAndNumTweetsHeader() {
        // update the constraints on the name and num tweets labels so they are not visible
        headerNameLabelTopConstraint.constant = Constants.Sizes.UserProfileHeaderHeightMax + 10 // magic number!
    }
    
    func refreshUserTimeline() {
        fetchUserTimeline(false)
    }
    
    func fetchUserTimeline(reloadProfile : Bool) {
        
        // this is to get the ui syncing better
        var fetchUser : User!
        if reloadProfile {
            fetchUser = self.usersStack.pop()
        }else{
            fetchUser = displayedUser
        }
        
        // get user timeline
        Twitter.userTimeline(fetchUser, params: nil){ (tweets, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()){
                    if reloadProfile {
                        self.displayedUser = fetchUser
                        // reset the scroll position
                        self.configureProfileDetailsView()
                        self.initializeNameAndNumTweetsHeader()
                    }
                    
                    self.timelineController.tweets = tweets!
                    self.refreshControl.endRefreshing()
                    Helpers.printRateStatus()
                }
            }else{
                self.refreshControl.endRefreshing()
            }
        }
    }

    
    // MARK: delegates
    // timeline controller
    func reloadDataForDisplay() {
        timelineTableView.reloadData()
    }
    
    // timeline scrolling
    func willBeginScrolling(scrollView: UIScrollView) {
    }
    
    private func showAUser() {
        // fetch user's timeline
        fetchUserTimeline(true)
        adjustUserProfileBanner(self.timelineTableView.contentOffset.y)
        self.timelineTableView.setContentOffset(CGPointZero, animated:true)
    }
    
    func clearStack() {
        self.usersStack.clear()
    }
    
    func showProfileVC(user: User){
        guard user.idStr != displayedUser.idStr else {
            return
        }
        
        usersStack.push(displayedUser)
        usersStack.push(user)
        showAUser()
    }
    
    private func adjustUserProfileBanner(yOffset : CGFloat) {
        // adjust height of banner image header
        var newHeight = Constants.Sizes.UserProfileHeaderHeightMax - yOffset
        
        // check if resulting size is too big/small
        showCondensedHeader = true
        if newHeight < Constants.Sizes.UserProfileHeaderHeightMin  {
            newHeight = Constants.Sizes.UserProfileHeaderHeightMin
        }else if newHeight > Constants.Sizes.UserProfileHeaderHeightMax {
            newHeight = Constants.Sizes.UserProfileHeaderHeightMax
            showCondensedHeader = false
        }
        
        if oldHeight != newHeight {
            // update constraint for height of the top header
            headerViewHeightConstraint.constant = newHeight
            
            oldHeight = newHeight
        }
        
        var distanceFromTop = Constants.Sizes.UserProfileHeaderHeightMin + profileDetailsView.userNameLabel.frame.origin.y - yOffset
        distanceFromTop = max(20, distanceFromTop)
        if oldDistanceFromTop != distanceFromTop {
            
            // determine whether the name and numtext labels needs to be shown, by adjusting the constraint on the condensed text
            if showCondensedHeader {
                headerNameLabelTopConstraint.constant = distanceFromTop
                
                // sigh... picture location adjustment to match twitter app behavior; only show bottom part of picture
                let distance = max(-1.0*Constants.Sizes.UserProfileHeaderHeightMin, -1.0*yOffset)
                headerImageViewTopConstraint.constant = distance
                
                
                // blur the picture
                if let image = self.bannerImage {
                    let radius = (-5.0*distanceFromTop+320)/22
                    let blurredImage = image .applyBlurWithRadius(CGFloat(2.0*radius), tintColor: UIColor.clearColor(), saturationDeltaFactor: CGFloat(1.0), maskImage: nil)
                    profileHeaderImageView.image = blurredImage
                }
                
            }
            oldDistanceFromTop = distanceFromTop
        }
    }
    
    func didScroll(scrollView: UIScrollView) {
        adjustUserProfileBanner(scrollView.contentOffset.y)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func shouldShowBackButton() {
        var showBackButton = true
        if usersStack.isEmpty {
            // empty stack, only show back button if the presenting controller is hamburger menu
            if let _ = self.presentingViewController as? HamburgerMenuViewController {
                showBackButton = false
            }
        }
        
        self.backButton.hidden = !showBackButton
    }

    
    // MARK: Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        if usersStack.isEmpty {
            // no more previous users to display... depending on presenting controller, do nothing or dismiss
            print("presenting: \(self.presentedViewController)")
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            showAUser()
        }
    }
    
    @IBAction func composeTweetTapped(sender: AnyObject) {
        print("composing tweet to user \(displayedUser!.name)")
        performSegueWithIdentifier(Constants.Segues.userProfileToCompose, sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == Constants.Segues.userProfileToCompose {
            let composeVC = segue.destinationViewController as! ComposeTweetViewController
            composeVC.atUser = displayedUser
        }
        
        // go to tweet detail
        if let id = segue.identifier where id == Constants.Segues.userProfileToTweetDetail {
            if let cell = sender as? TimelineTableViewCell {
                if let indexPath = timelineTableView.indexPathForCell(cell) {
                    let detailVC = segue.destinationViewController as! TweetDetailViewController
                    detailVC.holderTweet = timelineController.tweets[indexPath.row]
                }
            }
        }
    }

}
