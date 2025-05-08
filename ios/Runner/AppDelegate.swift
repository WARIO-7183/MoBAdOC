import Flutter
import UIKit
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let notificationChannel = FlutterMethodChannel(
      name: "com.aidocapp/notifications",
      binaryMessenger: controller.binaryMessenger
    )
    
    notificationChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      switch call.method {
      case "initialize":
        self.requestNotificationPermission()
        result(nil)
      case "showNotification":
        if let args = call.arguments as? [String: Any],
           let title = args["title"] as? String,
           let body = args["body"] as? String,
           let payload = args["payload"] as? String {
          self.showNotification(title: title, body: body, payload: payload)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "Title and body are required",
                            details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
      if granted {
        print("Notification permission granted")
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      } else if let error = error {
        print("Error requesting notification permission: \(error.localizedDescription)")
      }
    }
  }
  
  private func showNotification(title: String, body: String, payload: String?) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    content.badge = 1
    content.categoryIdentifier = "MESSAGE"
    
    if let payload = payload {
      content.userInfo = ["payload": payload]
    }
    
    // Add actions
    let openAction = UNNotificationAction(
      identifier: "OPEN_ACTION",
      title: "Open",
      options: .foreground
    )
    
    let category = UNNotificationCategory(
      identifier: "MESSAGE",
      actions: [openAction],
      intentIdentifiers: [],
      options: []
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
    
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil
    )
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("Error showing notification: \(error.localizedDescription)")
      }
    }
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }
  
  // Handle notification when app is in background and user taps the notification
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    if let payload = userInfo["payload"] as? String {
      // Handle the payload here if needed
      print("Received notification with payload: \(payload)")
    }
    completionHandler()
  }
}
