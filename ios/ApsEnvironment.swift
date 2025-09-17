import Foundation
import Security
import React

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

    var apsEnv = "unknown"
    if let task = SecTaskCreateFromSelf(nil),
       let val = SecTaskCopyValueForEntitlement(task, "aps-environment" as CFString, nil) as? String {
      apsEnv = val
    }

    let hasProvisioning = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil

    resolve([
      "build": build,
      "isTestFlight": isTestFlight,
      "apsEnvironment": apsEnv,
      "hasProvisioningProfile": hasProvisioning
    ])
  }
}
