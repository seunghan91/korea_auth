# korea-auth (Svelte)

Korean social login SDK for Svelte/SvelteKit.

## Installation

```bash
npm install korea-auth
```

## Usage

```svelte
<script>
  import { KakaoButton, NaverButton, GoogleButton, AppleButton } from 'korea-auth';
  import { authStore } from 'korea-auth';

  async function handleKakaoLogin(event) {
    const { token, user } = event.detail;
    // Send token to your backend for verification
    await fetch('/api/auth/verify', {
      method: 'POST',
      body: JSON.stringify({ provider: 'kakao', token })
    });
  }
</script>

<div class="login-buttons">
  <KakaoButton on:success={handleKakaoLogin} />
  <NaverButton on:success={handleNaverLogin} />
  <GoogleButton clientId="YOUR_CLIENT_ID" on:success={handleGoogleLogin} />
  <AppleButton clientId="YOUR_CLIENT_ID" on:success={handleAppleLogin} />
</div>

{#if $authStore.user}
  <p>Welcome, {$authStore.user.name}!</p>
{/if}
```

## Configuration

### Kakao

Add your Kakao JavaScript Key to your app's environment.

### Naver

Configure Naver Login in your app settings.

## License

MIT
