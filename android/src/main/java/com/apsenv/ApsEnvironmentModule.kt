package com.apsenv

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class ApsEnvironmentModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  override fun getName() = "ApsEnvironment"

  @ReactMethod
  fun getInfo(promise: Promise) {
    val map = Arguments.createMap().apply {
      putString("build", "release")
      putBoolean("isTestFlight", false)
      putString("apsEnvironment", "unknown")
      putBoolean("hasProvisioningProfile", false)
    }

    promise.resolve(map)
  }
}
