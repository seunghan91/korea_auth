"""
Google provider implementation
"""

import requests
from ..result import AuthResult


class GoogleProvider:
    """Verify Google login tokens."""
    
    TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo"
    
    def verify(self, token: str) -> AuthResult:
        """Verify a Google ID token and return user info."""
        try:
            response = requests.get(f"{self.TOKEN_INFO_URL}?id_token={token}")
            
            if not response.ok:
                return AuthResult.failure("Invalid token")
            
            data = response.json()
            
            return AuthResult.success_result(
                uid=data["sub"],
                provider="google",
                name=data.get("name"),
                email=data.get("email"),
                photo_url=data.get("picture"),
                raw_data=data,
            )
        except Exception as e:
            return AuthResult.failure(str(e))
