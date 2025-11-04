import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "AIzaSyAyR-xVoIbkX3mQH9577iI1My28xM9a8HE") as? String else {
      fatalError("API Key 'GOOGLE_MAPS_API_KEY' não encontrada no Info.plist")
    }
    
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
