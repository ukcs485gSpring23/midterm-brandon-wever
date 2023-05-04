<!--
Name of your final project
-->
# Alpine Fitness
![Swift](https://img.shields.io/badge/swift-5.5-brightgreen.svg) ![Xcode 13.2+](https://img.shields.io/badge/xcode-13.2%2B-blue.svg) ![iOS 15.0+](https://img.shields.io/badge/iOS-15.0%2B-blue.svg) ![watchOS 8.0+](https://img.shields.io/badge/watchOS-8.0%2B-blue.svg) ![CareKit 2.1+](https://img.shields.io/badge/CareKit-2.1%2B-red.svg) ![ci](https://github.com/netreconlab/CareKitSample-ParseCareKit/workflows/ci/badge.svg?branch=main)

## Description
<!--
Give a short description on what your project accomplishes and what tools is uses. Basically, what problems does it solve and why it's different from other apps in the app store.
-->
An example application of [CareKit](https://github.com/carekit-apple/CareKit)'s OCKSample synchronizing CareKit data to the Cloud via [ParseCareKit](https://github.com/netreconlab/ParseCareKit).

Alpine Fitness is an app designed to aid someone in their workout routine. The goal of this applicaion is to give users an easy to use experience while doing their workout, so they do not have to worry about keeping track of what they have done or what they need to do next. This application is mainly using the CareKit and ResearchKit frameworks. 

This application has the goal of allowing its users complete control over how they plan their workout with the ability to create tasks to be completed, access areas of the Health app's information such as height and weight, access the phone's contact information, and give insights into the user's weight and workout progession.

### Demo Video
<!--
Add the public link to your YouTube or video posted elsewhere.
-->
To learn more about this application, watch the video below:

<a href="https://www.youtube.com/watch?feature=player_embedded&v=5tL2P1MByJI" target="_blank"><img src="http://img.youtube.com/vi/5tL2P1MByJI/0.jpg" 
alt="Sample demo video" width="240" height="180" border="10" /></a>

### Designed for the following users
<!--
Describe the types of users your app is designed for and who will benefit from your app.
-->
This app is designed for anyone who wishes to start getting into fitness or weight lifting. This app is designed to be a tool in aiding you to plan, keep track of, and complete your workout.
<!--
In addition, you can drop screenshots directly into your README file to add them to your README. Take these from your presentations.
-->
<img width="300" alt="Screen Shot 2023-05-03 at 7 50 32 PM" src="https://user-images.githubusercontent.com/85644343/236076555-34489bb1-08a1-42ab-8026-2dbf9742030c.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 53 57 PM" src="https://user-images.githubusercontent.com/85644343/236076761-08decb02-68ac-4e41-ad7c-225fe2b2ef02.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 58 42 PM" src="https://user-images.githubusercontent.com/85644343/236076811-9472fa89-7db4-417d-a0b4-db728f78d637.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 51 13 PM" src="https://user-images.githubusercontent.com/85644343/236076716-f9cb1673-d338-4449-8a5c-de5124758962.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 52 39 PM" src="https://user-images.githubusercontent.com/85644343/236076735-4f7701df-6959-4b08-9117-36f2f1fb7056.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 53 12 PM" src="https://user-images.githubusercontent.com/85644343/236076749-65db14cb-8910-473c-8804-76a9059fc479.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 55 09 PM" src="https://user-images.githubusercontent.com/85644343/236076788-f9201176-34dc-45c7-bd33-71139fc7f62d.png"> <img width="300" alt="Screen Shot 2023-05-03 at 7 55 59 PM" src="https://user-images.githubusercontent.com/85644343/236076804-19577fa6-95cc-4f0d-974a-f99a6decc43a.png"> <img width="300" alt="Screen Shot 2023-05-03 at 8 20 04 PM" src="https://user-images.githubusercontent.com/85644343/236078392-09edcd57-9a95-42c9-9548-e2e5fe693327.png">

<!--
List all of the members who developed the project and
link to each members respective GitHub profile
-->
Developed by: 
- [Dr. Corey Baker](https://github.com/cbaker6) - `University of Kentucky`, `Computer Science Professor`
- [Brandon Wever](https://github.com/brandon-wever) - `University of Kentucky`, `Computer Science`

ParseCareKit synchronizes the following entities to Parse tables/classes using [Parse-Swift](https://github.com/parse-community/Parse-Swift):

- [x] OCKTask <-> Task
- [x] OCKHealthKitTask <-> HealthKitTask 
- [x] OCKOutcome <-> Outcome
- [x] OCKRevisionRecord.KnowledgeVector <-> Clock
- [x] OCKPatient <-> Patient
- [x] OCKCarePlan <-> CarePlan
- [x] OCKContact <-> Contact

**Use at your own risk. There is no promise that this is HIPAA compliant and we are not responsible for any mishandling of your data**

<!--
What features were added by you, this should be descriptions of features added from the [Code](https://uk.instructure.com/courses/2030626/assignments/11151475) and [Demo](https://uk.instructure.com/courses/2030626/assignments/11151413) parts of the final. Feel free to add any figures that may help describe a feature. Note that there should be information here about how the OCKTask/OCKHealthTask's and OCKCarePlan's you added pertain to your app.
-->
## Contributions/Features
On the insights tab, there are 3 surveys that pertain to a user's taks and their related outcomes. Two of these graphs pertain to a user's response on built-in surveys that address a user's weight as well as a user's opinion of the difficulty of a workout they have completed. The third graph is a representation of the amount of exercises that the user has completed on a given day. OCKHealthKitTasks are also built into the application's funcitonality and pull data from the Health app on a user's phone to display current weight and height information. I have also created two new custom button types, the first of which is intended to let the user keep track of a weight they may have completed while doing a certain exercise. The second custom button type is a text input feature designed to be a sort of notepad for users to write out their thoughts, plans, or motivations while completing a workout. There is also added functionality to the profile tab, with the user having the ability to add their own custom OCKTasks and OCKHealthKitTasks, as well as being able to update their own profile and contact information.
## Final Checklist
<!--
This is from the checkist from the final [Code](https://uk.instructure.com/courses/2030626/assignments/11151475). You should mark completed items with an x and leave non-completed items empty
-->
- [x] Signup/Login screen tailored to app
- [x] Signup/Login with email address
- [x] Custom app logo
- [x] Custom styling
- [x] Add at least **5 new OCKTask/OCKHealthKitTasks** to your app
  - [x] Have a minimum of 7 OCKTask/OCKHealthKitTasks in your app
  - [x] 3/7 of OCKTasks should have different OCKSchedules than what's in the original app
- [x] Use at least 5/7 card below in your app
  - [x] InstructionsTaskView - typically used with a OCKTask
  - [x] SimpleTaskView - typically used with a OCKTask
  - [x] Checklist - typically used with a OCKTask
  - [x] Button Log - typically used with a OCKTask
  - [ ] GridTaskView - typically used with a OCKTask
  - [ ] NumericProgressTaskView (SwiftUI) - typically used with a OCKHealthKitTask
  - [x] LabeledValueTaskView (SwiftUI) - typically used with a OCKHealthKitTask
- [x] Add the LinkView (SwiftUI) card to your app
- [x] Replace the current TipView with a class with CustomFeaturedContentView that subclasses OCKFeaturedContentView. This card should have an initializer which takes any link
- [x] Tailor the ResearchKit Onboarding to reflect your application
- [x] Add tailored check-in ResearchKit survey to your app
- [x] Add a new tab called "Insights" to MainTabView
- [x] Replace current ContactView with Searchable contact view
- [x] Change the ProfileView to use a Form view
- [ ] Add at least two OCKCarePlan's and tie them to their respective OCKTask's and OCContact's 

## Wishlist features
<!--
Describe at least 3 features you want to add in the future before releasing your app in the app-store
-->
1. Connecting multiple OCKCarePlans to different workout types and setting them to specific schedules. For example, this would have chest day on monday, legs on Tuesday, etc.
2. Allowing multiple users to contact eachother through the contacts tab and allowing them to share information with eachother such as workouts, and personal data to track eachother's progess. This would be a major step toward tailoring this application to a more social-media style.
3. Allowing users to create custom care plans, similar to the point 1. This could allow users the oppurtunity to create their own workouts with customized schedules, giving users more choice over what their workout schedule may look like.
4. Tapping a third-party API that gave users the ability to create a specific exercise task - say bicep curls - and the API would provide a short video demonstration on how to correctly perform the exercise.

## Challenges faced while developing
<!--
Describe any challenges you faced with learning Swift, your baseline app, or adding features. You can describe how you overcame them.
-->
The biggest problem I faced during development, was allocating time to come to campus and use the university computers, as I do not personally own a Mac. Another large challenge I faced during development was navigating documentation related to problems I was experiencing. Often I would run into issues and searched possible fixes but often times Apple's documentation links were bad and there was a not of information pertaining to the situation I was in. Finally, the last problem I faced was working with a dynamic, multi-threaded application which I have not had a lot of experience working with in the past. This made me have to think very critically about problems before they arose, otherwise errors could persist on multiple builds and the only way to fix this issue was by cleaning my build folder and restarting XCode.
## Setup Your Parse Server

### Heroku
The easiest way to setup your server is using the [one-button-click](https://github.com/netreconlab/parse-hipaa#heroku) deplyment method for [parse-hipaa](https://github.com/netreconlab/parse-hipaa).


## View your data in Parse Dashboard

### Heroku
The easiest way to setup your dashboard is using the [one-button-click](https://github.com/netreconlab/parse-hipaa-dashboard#heroku) deplyment method for [parse-hipaa-dashboard](https://github.com/netreconlab/parse-hipaa-dashboard).
