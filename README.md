# react-native-aps-environment

Tiny cross-platform React Native module that exposes the iOS `aps-environment` entitlement (`development` or `production`) and a handful of other build flags you can send to your backend. On Android sensible defaults are returned.

> Use case: decide on the server whether to call `https://api.sandbox.push.apple.com` or `https://api.push.apple.com` for (VoIP) APNs by trusting what the signed app says.

## Install

```bash
# Add to your app, pointing to YOUR Git URL
npm i git+https://github.com/p7161/react-native-aps-environment.git
# or
yarn add git+https://github.com/p7161/react-native-aps-environment.git

# iOS pods
cd ios && pod install && cd -
```

No manual linking needed (autolinking works). Requires React Native 0.68+ (older likely fine, but untested).

## API

```ts
import { getInfo, type AppEnvInfo } from 'react-native-aps-environment';

const info: AppEnvInfo = await getInfo();
// info = {
//   build: 'debug' | 'release',
//   isTestFlight: boolean,
//   apsEnvironment: 'development' | 'production' | 'unknown',
//   hasProvisioningProfile: boolean,
//   jsDev: boolean,
// }
```

Example usage when registering a VoIP token:

```ts
const info = await getInfo();
VoipPushNotification.addEventListener('register', async (token) => {
  await fetch('https://your.api/voip/register', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ token, ...info }),
  });
});
```

On the server, switch APNs endpoint via `apsEnvironment`.

## Troubleshooting

- **Getting `BadDeviceToken` on prod APNs**: ensure the installed app is signed with a Distribution profile (Ad Hoc/TestFlight). In Xcode → Archives → select your build → **Show in Finder** → `Products/*.app` → inspect entitlements (should contain `aps-environment = production`).
- **`Native module not found`**: run `pod install`, clean build folder, reinstall the app.
- **Need ESM build**: the package ships CJS+types; if you want ESM, adjust `tsconfig` & `package.json` fields.

## License

MIT
