import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Keeps `delegate.window` set for UIScene apps — required by flutter_web_auth_2
  /// (Stripe KYC / bank linking ASWebAuthenticationSession).
  func syncWindowFromScene(_ sceneWindow: UIWindow?) {
    guard let sceneWindow else { return }
    if window == nil {
      window = sceneWindow
    }
  }

  private func activeSceneWindow() -> UIWindow? {
    if let window {
      return window
    }
    if #available(iOS 13.0, *) {
      for scene in UIApplication.shared.connectedScenes {
        guard let windowScene = scene as? UIWindowScene else { continue }
        if windowScene.activationState == .foregroundActive
          || windowScene.activationState == .foregroundInactive
        {
          if let key = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return key
          }
          if let first = windowScene.windows.first {
            return first
          }
        }
      }
    }
    return nil
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for flutter_local_notifications + firebase_messaging foreground delivery.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if window == nil, let sceneWindow = activeSceneWindow() {
      window = sceneWindow
    }
    return result
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
