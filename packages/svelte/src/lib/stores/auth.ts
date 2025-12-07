import { writable } from 'svelte/store';
import type { AuthState } from '../types';

function createAuthStore() {
  const { subscribe, set, update } = writable<AuthState>({
    user: null,
    isLoading: false,
    error: null
  });

  return {
    subscribe,
    setUser: (user: AuthState['user']) => update(state => ({ ...state, user, error: null })),
    setLoading: (isLoading: boolean) => update(state => ({ ...state, isLoading })),
    setError: (error: Error) => update(state => ({ ...state, error, isLoading: false })),
    clear: () => set({ user: null, isLoading: false, error: null })
  };
}

export const authStore = createAuthStore();
