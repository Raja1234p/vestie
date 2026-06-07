import Flutter
import UIKit

/// Stripe Connect / OAuth (`vestie://kyc/*`, `vestie://bank/*`) needs scene URL
/// forwarding and a visible [FlutterViewController] for ASWebAuthenticationSession.
class SceneDelegate: FlutterSceneDelegate {
  private static let splashBackgroundColor = UIColor(
    red: 76.0 / 255.0,
    green: 36.0 / 255.0,
    blue: 160.0 / 255.0,
    alpha: 1.0
  )

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    applySplashBackground()
    syncAppDelegateWindow()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    applySplashBackground()
    syncAppDelegateWindow()
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    syncAppDelegateWindow()
  }

  private func applySplashBackground() {
    window?.backgroundColor = Self.splashBackgroundColor
    if let flutterViewController = window?.rootViewController as? FlutterViewController {
      flutterViewController.view.backgroundColor = Self.splashBackgroundColor
    }
  }

  private func syncAppDelegateWindow() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.syncWindowFromScene(window)
  }
}
