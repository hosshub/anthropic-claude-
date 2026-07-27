import Flutter
import UIKit

// نُبقي الملف موجوداً لأن project.pbxproj يشير إليه، لكن UIApplicationSceneManifest
// محذوف من Info.plist فلن يُستخدم هذا الـ SceneDelegate. لو احتاجه iOS مستقبلاً
// فسيمرّر روابط النظام إلى AppDelegate حتى يلتقطها app_links.
@objc class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    for ctx in connectionOptions.urlContexts {
      _ = UIApplication.shared.delegate?.application?(
        UIApplication.shared, open: ctx.url, options: [:]
      )
    }
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for ctx in URLContexts {
      _ = UIApplication.shared.delegate?.application?(
        UIApplication.shared, open: ctx.url, options: [:]
      )
    }
  }
}
