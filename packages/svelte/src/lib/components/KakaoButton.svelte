<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import { authStore } from '../stores/auth';
  import type { AuthUser } from '../types';

  export let restApiKey: string = '';

  const dispatch = createEventDispatcher<{
    success: { token: string; user: AuthUser };
    error: Error;
  }>();

  let Kakao: any;

  onMount(async () => {
    // Load Kakao SDK
    if (typeof window !== 'undefined' && !window.Kakao) {
      const script = document.createElement('script');
      script.src = 'https://developers.kakao.com/sdk/js/kakao.js';
      script.onload = () => {
        Kakao = window.Kakao;
        if (restApiKey) {
          Kakao.init(restApiKey);
        }
      };
      document.head.appendChild(script);
    } else if (window.Kakao) {
      Kakao = window.Kakao;
    }
  });

  async function handleClick() {
    if (!Kakao?.isInitialized()) {
      dispatch('error', new Error('Kakao SDK not initialized'));
      return;
    }

    authStore.setLoading(true);

    try {
      const response = await new Promise<any>((resolve, reject) => {
        Kakao.Auth.login({
          success: resolve,
          fail: reject
        });
      });

      const userInfo = await new Promise<any>((resolve, reject) => {
        Kakao.API.request({
          url: '/v2/user/me',
          success: resolve,
          fail: reject
        });
      });

      const user: AuthUser = {
        uid: String(userInfo.id),
        provider: 'kakao',
        name: userInfo.kakao_account?.profile?.nickname,
        email: userInfo.kakao_account?.email,
        photoUrl: userInfo.kakao_account?.profile?.profile_image_url,
        rawData: userInfo
      };

      authStore.setUser(user);
      dispatch('success', { token: response.access_token, user });
    } catch (error) {
      authStore.setError(error as Error);
      dispatch('error', error as Error);
    } finally {
      authStore.setLoading(false);
    }
  }
</script>

<button
  class="kakao-button"
  on:click={handleClick}
>
  <svg viewBox="0 0 24 24" width="20" height="20">
    <path fill="currentColor" d="M12 3C6.48 3 2 6.58 2 11c0 2.84 1.86 5.33 4.64 6.73-.2.76-.72 2.74-.82 3.17-.14.52.19.51.39.37.16-.1 2.54-1.73 3.58-2.43.74.11 1.49.16 2.21.16 5.52 0 10-3.58 10-8s-4.48-8-10-8z"/>
  </svg>
  <span>카카오 로그인</span>
</button>

<style>
  .kakao-button {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    height: 48px;
    background-color: #FEE500;
    color: #191919;
    border: none;
    border-radius: 6px;
    font-size: 16px;
    font-weight: 500;
    cursor: pointer;
    transition: opacity 0.2s;
  }

  .kakao-button:hover {
    opacity: 0.9;
  }
</style>
