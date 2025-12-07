# korea_auth

Rails gem for verifying Korean social login tokens (Kakao, Naver, Google, Apple).

## Installation

```ruby
gem 'korea_auth'
```

## Usage

```ruby
# In your ApplicationController or AuthController
class AuthController < ApplicationController
  def verify
    result = KoreaAuth.verify(params[:provider], params[:token])

    if result.success?
      user = User.find_or_create_by(provider: result.provider, uid: result.uid) do |u|
        u.email = result.email
        u.name = result.name
      end
      sign_in(user)
      render json: { user: user }
    else
      render json: { error: result.error }, status: :unauthorized
    end
  end
end
```

## License

MIT
