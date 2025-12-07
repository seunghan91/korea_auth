"""
Naver provider implementation
"""

import requests
from ..result import AuthResult


class NaverProvider:
    """Verify Naver login tokens."""
    
    USER_INFO_URL = "https://openapi.naver.com/v1/nid/me"
    
    def verify(self, token: str) -> AuthResult:
        """Verify a Naver access token and return user info."""
        try:
            headers = {"Authorization": f"Bearer {token}"}
            
            response = requests.get(self.USER_INFO_URL, headers=headers)
            data = response.json()
            
            if not response.ok or data.get("resultcode") != "00":
                return AuthResult.failure(f"Invalid token: {data.get('message')}")
            
            user_data = data.get("response", {})
            
            return AuthResult.success_result(
                uid=user_data["id"],
                provider="naver",
                name=user_data.get("name") or user_data.get("nickname"),
                email=user_data.get("email"),
                photo_url=user_data.get("profile_image"),
                raw_data=user_data,
            )
        except Exception as e:
            return AuthResult.failure(str(e))
