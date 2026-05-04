## Changelog

### 0.0.1

- Initial release with support for:
    - Default API authentication
    - Social authentication
    - Email, phone number, and username authentication
    - Anonymous authentication

### 0.0.2

- Update readme
- Add admin plugin

### 0.0.3

- Refactoring
- Add github example

### 0.0.4

- Add Email OTP
- Add plugin example in readme

### 0.0.5

- Update readme for plugin example

### 0.0.6

- Add JWT support

### 0.0.7

- Fix: update api response types to use correct models
  from [Karuppusamy](https://github.com/karuppusamy-d)

### 0.0.8

- Break changes: We change use name parameter with BodyExtra instead of Class.
    - Before:
  ```dart
  final result = await client.signIn.email(
    body: SignInEmailBody(
      email: "test@mail.com",
      password: "12345678",
    ),
  )
  ```
    - After
  ```dart
  final result = await client.signIn.email(
    email: "test@mail.com",
    password: "12345678",
  );
  ```

### 0.0.9

- Fix body serialization

### 0.1.0

- Add `flutter_auth_web_2` for social auth.

### 0.1.1

- Remove log.

### 0.1.2

- Remove log.
- Add condition for social auth on web

### 0.1.6

- Add [**One-Time Token**](https://www.better-auth.com/docs/plugins/one-time-token) plugin (`client.oneTimeToken`): `GET /one-time-token/generate`, `POST /one-time-token/verify`.
- Add [**Anonymous**](https://www.better-auth.com/docs/plugins/anonymous) plugin: `client.anonymous.deleteAnonymousUser()` (`POST /delete-anonymous-user`). Anonymous sign-in stays on `client.signIn.anonymous()` (`POST /sign-in/anonymous`).
- Add [**Passkey**](https://www.better-auth.com/docs/plugins/passkey) plugin (`client.passkey`): full HTTP surface for [`@better-auth/passkey`](https://www.better-auth.com/docs/plugins/passkey) (generate/verify registration & authentication, list, delete, update). WebAuthn UI is left to the app (e.g. [`passkeys`](https://pub.dev/packages/passkeys)).
- Add [**Organization**](https://www.better-auth.com/docs/plugins/organization) plugin (`client.organization`): Retrofit surface for org/members/invites/teams/roles/**`has-permission`**; **`set-active` / `set-active-team`** via Dio with JSON **`null`** preserved (**`RemoveNullsInterceptor`**); **`listMembersRaw`** for list-members query parity.
- Add [**API Key**](https://www.better-auth.com/docs/plugins/api-key) plugin (`client.apiKey`).
- Add [**Two-Factor**](https://www.better-auth.com/docs/plugins/two-factor) plugin (`client.twoFactor`).
- **Session**: `Session.activeTeamId` where teams apply; regenerated client **`.g.dart`** where needed.
- **Widgets**: `BetterAuthInherit.maybeOf`; **`StateError`** when `BetterAuthConsumer` is used outside **`BetterAuthProvider`**.
- README updates (anonymous / passkey / org), **`SignInEmailResponse`** and model tests, example app updates.
