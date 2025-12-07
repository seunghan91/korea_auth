"""
Result class for authentication operations
"""

from dataclasses import dataclass
from typing import Optional, Dict, Any


@dataclass
class AuthResult:
    """Result of an authentication verification attempt."""
    
    success: bool
    uid: Optional[str] = None
    provider: Optional[str] = None
    name: Optional[str] = None
    email: Optional[str] = None
    photo_url: Optional[str] = None
    raw_data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    
    @classmethod
    def success_result(
        cls,
        uid: str,
        provider: str,
        name: Optional[str] = None,
        email: Optional[str] = None,
        photo_url: Optional[str] = None,
        raw_data: Optional[Dict[str, Any]] = None,
    ) -> "AuthResult":
        """Create a successful result."""
        return cls(
            success=True,
            uid=uid,
            provider=provider,
            name=name,
            email=email,
            photo_url=photo_url,
            raw_data=raw_data,
        )
    
    @classmethod
    def failure(cls, error: str) -> "AuthResult":
        """Create a failed result."""
        return cls(success=False, error=error)
