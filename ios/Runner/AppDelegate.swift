import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let clipboardChannelName = "clipboard_manager/clipboard"
    private var flutterResult: FlutterResult?
    private var previousPasteboardString = ""
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller : FlutterViewController = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        let clipboardChannel = FlutterMethodChannel(name: clipboardChannelName, binaryMessenger: controller.binaryMessenger)
        clipboardChannel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call: call, result: result)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startBackgroundMonitoring":
            startBackgroundMonitoring()
            result(nil)
        case "stopBackgroundMonitoring":
            stopBackgroundMonitoring()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startBackgroundMonitoring() {
        // Register for background fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Start periodic clipboard checking
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func stopBackgroundMonitoring() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
    }
    
    private func checkClipboard() {
        let currentPasteboardString = UIPasteboard.general.string
        
        if let currentPasteboardString = currentPasteboardString, 
           currentPasteboardString != previousPasteboardString {
            previousPasteboardString = currentPasteboardString
            sendClipboardTextToFlutter(text: currentPasteboardString)
        }
    }
    
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        checkClipboard()
        completionHandler(.newData)
    }
    
    private func sendClipboardTextToFlutter(text: String) {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        
        let clipboardChannel = FlutterMethodChannel(
            name: clipboardChannelName, 
            binaryMessenger: controller.binaryMessenger
        )
        clipboardChannel.invokeMethod("addHistoryItemFromNative", arguments: text)
    }
}
