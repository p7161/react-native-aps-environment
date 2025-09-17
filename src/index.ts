import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-aps-environment' doesn't seem to be linked.\n` +
  Platform.select({ ios: "\n• Did you run 'pod install' in the ios/ directory?", default: '' });

type ApsEnvNative = {
  getInfo(): Promise<{
    build: 'debug' | 'release';
    isTestFlight: boolean;
    apsEnvironment: 'development' | 'production' | 'unknown';
    hasProvisioningProfile: boolean;
  }>;
};

const Native: ApsEnvNative = NativeModules.ApsEnvironment
  ? NativeModules.ApsEnvironment
  : (new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    ) as any);

export type AppEnvInfo = {
  build: 'debug' | 'release';
  isTestFlight: boolean;
  apsEnvironment: 'development' | 'production' | 'unknown';
  hasProvisioningProfile: boolean;
  jsDev: boolean;
};

export async function getInfo(): Promise<AppEnvInfo> {
  if (Platform.OS !== 'ios') {
    return {
      build: 'release',
      isTestFlight: false,
      apsEnvironment: 'unknown',
      hasProvisioningProfile: false,
      jsDev: __DEV__,
    };
  }

  const native = await Native.getInfo();
  return { ...native, jsDev: __DEV__ };
}
