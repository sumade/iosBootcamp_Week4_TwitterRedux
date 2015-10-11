## Twitter Redux

Time spent: `20`

### Features
- added some stuff to the previous twitter client
- due to time constraints, i didn't get a chance to clean up the encapsulation of properties (private, etc)
- user profile view mimics the existing twitter client by having the banner image shrink in size as you start scrolling through the user's timeline.  also, the banner image becomes blurry, and i display the name and number of tweets in the blurred banner image.
- the hamburger menu is implemented with a custom view controller loaded from a .xib. for a clean separation of concerns, the hamburger menu uses a delegate to populate the actual fields and respond to events.  "TwitterHamburgers.swift" is the implementation of the delegate for my twitter client.
- however, i had some problems trying to create a custom table cell class from a xib.  i tried to use this cell in my TwitterHamburgers class, but ran into some problems with auto layout.  I couldn't quite figure out how to get the cell to obey the auto layout constraints of the containing table, even though the auto layout editor doesnt show any problems with the constraints i configured in the xib itself.  hence the weird looking ui for the hamburger menu

#### Required

- [x] Hamburger menu
   - [-] Dragging anywhere in the view should reveal the menu.
      - Not quite anywhere... only certain screens support the hamburger menu. 
   - [x] The menu should include links to your profile, the home timeline, and the mentions view.
   - [x] The menu can look similar to the LinkedIn menu below or feel free to take liberty with the UI.
- [x] Profile page
   - [x] Contains the user header view
   - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Home Timeline
   - [x] Tapping on a user image should bring up that user's profile page

#### Optional

- [ ] Profile Page
   - [ ] Optional: Implement the paging view for the user description.
   - [x] Optional: As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [ ] Optional: Pulling down the profile page should blur and resize the header image.
- [ ] Optional: Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account

### Walkthrough

![Video Walkthrough](TwitterRedux_Walkthrough.gif)


### Credits
* [Twitter API](https://apps.twitter.com/)
* [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [UIImageEffects](https://cocoapods.org/pods/UIImageEffects) for blurring
* follow icon: Add Contact by Mike Ashley from the Noun Project
* following icon: Verified User by Keta Shah from the Noun Project
* logout icon: User by José Manuel de Laá from the Noun Project
* compose icon: quill by Simple Icons from the Noun Project
* my wife for letting me do this again, again
