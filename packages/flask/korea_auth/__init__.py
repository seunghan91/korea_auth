"""
korea-auth: Korean social login token verification for Python
"""

from .core import verify_token
from .result import AuthResult
from .providers import KakaoProvider, NaverProvider, GoogleProvider, AppleProvider

__version__ = "0.1.0"
__all__ = [
    "verify_token",
    "AuthResult",
    "KakaoProvider",
    "NaverProvider",
    "GoogleProvider",
    "AppleProvider",
]
