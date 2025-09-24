import Foundation
import React

@objc(ApsEnvironment)
class ApsEnvironment: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { false }

  // Прочитать override из Info.plist (APS_PUSH_ENV = development | production | auto | <нет>)
  private func readOverrideFromInfoPlist() -> String? {
    guard let raw = Bundle.main.object(forInfoDictionaryKey: "APS_PUSH_ENV") as? String else { return nil }
    let val = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    switch val {
    case "development", "production", "auto": return val
    default: return nil
    }
  }

  // Вытащить aps-environment из embedded.mobileprovision (Dev/AdHoc)
  private func readApsEnvFromProvisioning() -> String? {
    guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
          let data = try? Data(contentsOf: url),
          let text = String(data: data, encoding: .ascii) else { return nil }

    if let keyRange = text.range(of: "<key>aps-environment</key>") {
      let searchStart = keyRange.upperBound..<text.endIndex
      if let open = text.range(of: "<string>", range: searchStart),
         let close = text.range(of: "</string>", range: open.upperBound..<text.endIndex) {
        return String(text[open.upperBound..<close.lowerBound])
      }
    }
    return nil
  }

  private func computeIsTestFlight(hasProvisioning: Bool) -> Bool {
    // TestFlight обычно: НЕТ embedded.mobileprovision И квитанция sandboxReceipt
    let isSandboxReceipt = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    return !hasProvisioning && isSandboxReceipt
  }

  private func resolveApsEnvironment() -> (aps: String, hasProvisioning: Bool, isTestFlight: Bool) {
    let hasProvisioning = (Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil)

    // 1) Пытаемся взять override из Info.plist
    if let override = readOverrideFromInfoPlist() {
      if override == "development" || override == "production" {
        return (override, hasProvisioning, computeIsTestFlight(hasProvisioning: hasProvisioning))
      }
      // override == "auto" → идём дальше
    }

    // 2) Пробуем прочитать из provisioning профиля (Dev/AdHoc)
    if let fromProv = readApsEnvFromProvisioning() {
      return (fromProv, hasProvisioning, computeIsTestFlight(hasProvisioning: hasProvisioning))
    }

    // 3) Если профиля нет — это Distribution (TestFlight/App Store) ⇒ production
    if !hasProvisioning {
      return ("production", false, computeIsTestFlight(hasProvisioning: false))
    }

    // 4) Фолбек
    return ("unknown", hasProvisioning, computeIsTestFlight(hasProvisioning: hasProvisioning))
  }

  @objc func getInfo(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    #if DEBUG
      let build = "debug"
    #else
      let build = "release"
    #endif

    let result = resolveApsEnvironment()

    resolve([
      "build": build,
      "isTestFlight": result.isTestFlight,
      "apsEnvironment": result.aps,
      "hasProvisioningProfile": result.hasProvisioning
    ])
  }
}
