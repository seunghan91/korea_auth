"""
Kakao provider implementation
"""

import requests
from ..result import AuthResult


class KakaoProvider:
    """Verify Kakao login tokens."""
    
    TOKEN_INFO_URL = "https://kapi.kakao.com/v1/user/access_token_info"
    USER_INFO_URL = "https://kapi.kakao.com/v2/user/me"
    
    def verify(self, token: str) -> AuthResult:
        """Verify a Kakao access token and return user info."""
        try:
            headers = {"Authorization": f"Bearer {token}"}
            
            # Verify token
            token_response = requests.get(self.TOKEN_INFO_URL, headers=headers)
            if not token_response.ok:
                return AuthResult.failure(f"Invalid token: {token_response.json().get('msg')}")
            
            # Get user info
            user_response = requests.get(self.USER_INFO_URL, headers=headers)
            if not user_response.ok:
                return AuthResult.failure("Failed to get user info")
            
            data = user_response.json()
            account = data.get("kakao_account", {})
            profile = account.get("profile", {})
            
            return AuthResult.success_result(
                uid=str(data["id"]),
                provider="kakao",
                name=profile.get("nickname"),
                email=account.get("email"),
                photo_url=profile.get("profile_image_url"),
                raw_data=data,
            )
        except Exception as e:
            return AuthResult.failure(str(e))
