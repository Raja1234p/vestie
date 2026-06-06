import Flutter
import UIKit

/// Stripe Connect / OAuth (`vestie://kyc/*`, `vestie://bank/*`) needs scene URL
/// forwarding and a visible [FlutterViewController] for ASWebAuthenticationSession.
class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    syncAppDelegateWindow()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    syncAppDelegateWindow()
  }

  private func syncAppDelegateWindow() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.syncWindowFromScene(window)
  }
}
