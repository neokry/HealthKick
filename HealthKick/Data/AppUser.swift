//
//  Authorization.swift
//  HealthKick
//
//  Created by Patrick Genevich on 4/29/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFunctions
import SwiftUI
import GoogleSignIn
import Purchases
import GetStream

class AppUser: ObservableObject {
    @Published private(set) var isLoggedIn: Bool
    @Published private(set) var isLoaded = false
    @Published var userRecipes: [ImportedRecipe]?
    @Published var userMealPreps: UserMealPreps?
    @Published var userRecommendations: [Recommendation]?
    @Published var featuredRecipes: [Recommendation]?
    @Published var userGroceryList: UserGroceryList?
    @Published var userProfile: UserProfile?
    @Published var recommendationsLoaded = false
    @Published var isUserAdmin = false
    @Published var recommendedIngredients = [String]()
    @Published var streamClient: StreamClient?
    @Published var showTutorial = false
    @Published var cloudImageCache = [String: UIImage]()
    var displayName: String?
    let timelineLoadedSem = DispatchSemaphore(value: 0)
    let recipesLoadedSem = DispatchSemaphore(value: 0)
    lazy var functions = Functions.functions()

    var userID: String?

    init() {
        let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
        isLoggedIn = status

        if status {
            signIn()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in
            let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
            self.isLoggedIn = status
            if status {

                if let name = self.displayName {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges { err in
                        if err != nil {
                            print("Error updating firebase info")
                        }
                        self.signIn()
                    }
                } else {
                    self.signIn()
                }
            }
        }
    }

    func isAdmin() {
        functions.httpsCallable("isAdmin").call(["UID": self.userID]) { (result, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }

            if let isAdminResult = (result?.data as? [String: Any])?["isAdmin"] as? Bool {
                self.isUserAdmin = isAdminResult
            }
        }
    }

    func signIn() {
        if let userID = Auth.auth().currentUser?.uid {
            let startTime = CFAbsoluteTimeGetCurrent()
            self.userID = userID
            streamClient = StreamClient(userID: userID, isLoadedSem: timelineLoadedSem)

            let dispatchQueue = DispatchQueue(label: "waitingForLoadQueue", qos: .background)
            dispatchQueue.async {
                self.timelineLoadedSem.wait()
                DispatchQueue.main.async {
                    let loadTime = CFAbsoluteTimeGetCurrent() - startTime
                    Analytics.logEvent("initial_load_time", parameters: ["seconds": loadTime])

                    let defaults = UserDefaults.standard
                    self.showTutorial = !defaults.bool(forKey: "finishedTutorial")
                    self.isLoaded = true

                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }

            LoadSettings()
            isAdmin()

            RecipeClient().LoadRecipes { success, recipes in
                if success {
                    self.userRecipes = recipes!
                    for rec in recipes! {
                        if rec.imageURL == nil {
                            let loader = CloudImageLoader(id: rec.id)
                            loader.load { img in
                                self.cloudImageCache[rec.id] = img
                            }
                        }
                    }
                }
            }

            //Purchases.debugLogsEnabled = true
            //Purchases.configure(withAPIKey: "hkONmIjXoTzpyyFkMzrnijYVhOvXOUjb")

            userMealPreps = UserMealPreps(userID: userID)
            userGroceryList = UserGroceryList(userID: userID)
            getIngredients()

            Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: "AutoSignIn"])

        } else {
            self.signOut()
        }
    }

    func getIngredients() {
        if let path = Bundle.main.path(forResource: "example", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoded = try JSONDecoder().decode(Recommendations.self, from: data)
                self.recommendedIngredients = decoded.exampleIngredients.shuffled()
            } catch {
                print("Error getting example searches")
            }
        }
    }

    func LoadSettings() {
        let filename = getDocumentsDirectory().appendingPathComponent("UserSettings")
        do {
            let data = try Data(contentsOf: filename)
            userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("Error loading settings \(error.localizedDescription)")
            Crashlytics.crashlytics().log("Error loading settings \(error.localizedDescription)")
            userProfile = UserProfile()
        }
    }

    func signOut() {
        try! Auth.auth().signOut()
        GIDSignIn.sharedInstance()?.signOut()
        self.setLogInStatus(false)
        userID = nil
        userRecipes = nil
        userGroceryList = nil
        userProfile = nil
        isUserAdmin = false
        UserDefaults.standard.removeObject(forKey: "SavedRecipes")
    }

    func signInWithEmail(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(false, (error?.localizedDescription)!)
                return
            }

            completion(true, (result?.user.email)!)
        }
    }

    func signUpWithEmail(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(false, (error?.localizedDescription)!)
                return
            }

            completion(true, (result?.user.email)!)
        }
    }

    func setLogInStatus(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: "status")
        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
        self.isLoggedIn = status
    }

}
