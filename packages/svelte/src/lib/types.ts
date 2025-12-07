export interface AuthUser {
  uid: string;
  provider: 'kakao' | 'naver' | 'google' | 'apple';
  name?: string;
  email?: string;
  photoUrl?: string;
  rawData?: Record<string, unknown>;
}

export interface AuthState {
  user: AuthUser | null;
  isLoading: boolean;
  error: Error | null;
}
