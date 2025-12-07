"""
Core verification logic
"""

from typing import Literal
from .result import AuthResult
from .providers import KakaoProvider, NaverProvider, GoogleProvider, AppleProvider

Provider = Literal["kakao", "naver", "google", "apple"]

PROVIDERS = {
    "kakao": KakaoProvider,
    "naver": NaverProvider,
    "google": GoogleProvider,
    "apple": AppleProvider,
}


def verify_token(provider: Provider, token: str) -> AuthResult:
    """
    Verify a social login token from the specified provider.
    
    Args:
        provider: One of 'kakao', 'naver', 'google', 'apple'
        token: The access token or ID token from the client
        
    Returns:
        AuthResult with user information if successful, or error if failed
    """
    if provider not in PROVIDERS:
        return AuthResult.failure(f"Unknown provider: {provider}")
    
    provider_class = PROVIDERS[provider]
    return provider_class().verify(token)
