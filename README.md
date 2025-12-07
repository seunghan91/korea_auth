# Korea Auth

A multi-platform authentication SDK for Korean social logins (Kakao, Naver, Google, Apple).

## 📦 Packages

| Package                       | Platform         | Registry     | Status   |
| ----------------------------- | ---------------- | ------------ | -------- |
| [flutter](./packages/flutter) | Flutter/Dart     | pub.dev      | ✅ Ready |
| [rails](./packages/rails)     | Ruby on Rails    | rubygems.org | ✅ Ready |
| [svelte](./packages/svelte)   | Svelte/SvelteKit | npm          | ✅ Ready |
| [flask](./packages/flask)     | Python/Flask     | pypi.org     | ✅ Ready |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Client (Flutter / Svelte / React)                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  korea-auth SDK                                          │   │
│  │  • KakaoButton, NaverButton, GoogleButton, AppleButton   │   │
│  │  • AuthStore (state management)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            │ POST /auth/verify                  │
│                            │ { provider: "kakao", token: "..." }│
│                            ▼                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Backend (Rails / Flask / Express)                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  korea-auth SDK                                          │   │
│  │  • KoreaAuth.verify(provider, token)                     │   │
│  │  • Returns: { uid, name, email, photo_url }              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Flutter (Client)

```dart
import 'package:open_k_auth/open_k_auth.dart';

final authRepo = AuthRepository();
await authRepo.signIn(GoogleAuthProvider());
```

### Rails (Backend)

```ruby
result = KoreaAuth.verify("kakao", params[:token])
if result.success?
  user = User.find_or_create_by(uid: result.uid)
end
```

### Flask (Backend)

```python
from korea_auth import verify_token

result = verify_token("kakao", request.json["token"])
if result.success:
    user = User.get_or_create(uid=result.uid)
```

## 📝 License

MIT License - see [LICENSE](./LICENSE)

## 🤝 Contributing

Contributions are welcome! Please see our contributing guide for details.
