"""
Apple provider implementation
"""

import requests
import jwt
from ..result import AuthResult


class AppleProvider:
    """Verify Apple login tokens."""
    
    APPLE_KEYS_URL = "https://appleid.apple.com/auth/keys"
    
    def verify(self, token: str) -> AuthResult:
        """Verify an Apple identity token (JWT) and return user info."""
        try:
            # Fetch Apple's public keys
            keys_response = requests.get(self.APPLE_KEYS_URL)
            if not keys_response.ok:
                return AuthResult.failure("Failed to fetch Apple public keys")
            
            jwks = keys_response.json()
            
            # Decode header to find matching key
            unverified_header = jwt.get_unverified_header(token)
            kid = unverified_header.get("kid")
            
            # Find the matching key
            key_data = None
            for key in jwks.get("keys", []):
                if key.get("kid") == kid:
                    key_data = key
                    break
            
            if not key_data:
                return AuthResult.failure("No matching key found")
            
            # Build public key and verify
            public_key = jwt.algorithms.RSAAlgorithm.from_jwk(key_data)
            payload = jwt.decode(
                token,
                public_key,
                algorithms=["RS256"],
                options={"verify_aud": False}  # You should verify aud in production
            )
            
            return AuthResult.success_result(
                uid=payload["sub"],
                provider="apple",
                name=None,  # Apple doesn't always provide name in the token
                email=payload.get("email"),
                photo_url=None,
                raw_data=payload,
            )
        except jwt.InvalidTokenError as e:
            return AuthResult.failure(f"JWT error: {str(e)}")
        except Exception as e:
            return AuthResult.failure(str(e))
