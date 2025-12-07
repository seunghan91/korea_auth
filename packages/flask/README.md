# korea-auth (Python/Flask)

Korean social login token verification for Flask and other Python frameworks.

## Installation

```bash
pip install korea-auth
```

## Usage

```python
from flask import Flask, request, jsonify
from korea_auth import verify_token

app = Flask(__name__)

@app.route('/auth/verify', methods=['POST'])
def verify():
    data = request.json
    provider = data.get('provider')
    token = data.get('token')

    result = verify_token(provider, token)

    if result.success:
        # Create or fetch user from your database
        return jsonify({
            'uid': result.uid,
            'name': result.name,
            'email': result.email
        })
    else:
        return jsonify({'error': result.error}), 401

if __name__ == '__main__':
    app.run()
```

## Supported Providers

- Kakao (`kakao`)
- Naver (`naver`)
- Google (`google`)
- Apple (`apple`)

## License

MIT
