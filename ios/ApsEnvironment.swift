import Foundation
import Security
import React

@_silgen_name("SecTaskCreateFromSelf")
private func SecTaskCreateFromSelfRaw(_ allocator: CFAllocator?) -> Unmanaged<CFTypeRef>?

@_silgen_name("SecTaskCopyValueForEntitlement")
private func SecTaskCopyValueForEntitlementRaw(
  _ task: CFTypeRef,
  _ entitlement: CFString,
  _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?
) -> Unmanaged<CFTypeRef>?

@objc(ApsEnvironment)
class ApsEnvironment: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { false }

  @objc func getInfo(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
    #if DEBUG
      let build = "debug"
    #else
      let build = "release"
    #endif

    let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    let provisioningURL = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision")
    let fallbackApsEnv = provisioningURL.flatMap(readApsEnvironmentFromProvisioningProfile)
    let apsEnv = readApsEnvironmentEntitlement() ?? fallbackApsEnv ?? "unknown"
    let hasProvisioning = provisioningURL != nil

    resolve([
      "build": build,
      "isTestFlight": isTestFlight,
      "apsEnvironment": apsEnv,
      "hasProvisioningProfile": hasProvisioning
    ])
  }


  private func readApsEnvironmentEntitlement() -> String? {
    guard let task = SecTaskCreateFromSelfRaw(nil)?.takeRetainedValue() else { return nil }

    guard let raw = SecTaskCopyValueForEntitlementRaw(task, "aps-environment" as CFString, nil)?.takeRetainedValue() else {
      return nil
    }

    if let value = raw as? String {
      return value
    }

    if CFGetTypeID(raw) == CFStringGetTypeID() {
      return (raw as! CFString) as String
    }

    return nil
  }


  private func readApsEnvironmentFromProvisioningProfile(_ url: URL) -> String? {
    guard let data = try? Data(contentsOf: url),
          let text = String(data: data, encoding: .ascii) else { return nil }

    guard let keyRange = text.range(of: "<key>aps-environment</key>") else { return nil }
    let searchStart = keyRange.upperBound..<text.endIndex

    guard let open = text.range(of: "<string>", range: searchStart),
          let close = text.range(of: "</string>", range: open.upperBound..<text.endIndex) else { return nil }

    return String(text[open.upperBound..<close.lowerBound])
  }
}
