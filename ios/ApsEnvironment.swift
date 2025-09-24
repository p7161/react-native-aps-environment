import Foundation
import React

@objc(ApsEnvironment)
class ApsEnvironment: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { false }

  private func inferApsEnvironment() -> String {
    // 1) Попробовать вытащить значение из embedded.mobileprovision (Dev/AdHoc)
    if let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
       let data = try? Data(contentsOf: url),
       let text = String(data: data, encoding: .ascii) {
      if let keyRange = text.range(of: "<key>aps-environment</key>") {
        let searchStart = keyRange.upperBound..<text.endIndex
        if let open = text.range(of: "<string>", range: searchStart),
           let close = text.range(of: "</string>", range: open.upperBound..<text.endIndex) {
          return String(text[open.upperBound..<close.lowerBound])
        }
      }
    }

    // 2) Если профиля нет — это Distribution (TestFlight/App Store) => production
    let hasProvisioning = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
    if !hasProvisioning {
      return "production"
    }

    // 3) Фолбек
    let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    return isTestFlight ? "production" : "unknown"
  }

  @objc func getInfo(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    #if DEBUG
      let build = "debug"
    #else
      let build = "release"
    #endif

    let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    let apsEnv = inferApsEnvironment()
    let hasProvisioning = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil

    resolve([
      "build": build,
      "isTestFlight": isTestFlight,
      "apsEnvironment": apsEnv,
      "hasProvisioningProfile": hasProvisioning
    ])
  }
}
