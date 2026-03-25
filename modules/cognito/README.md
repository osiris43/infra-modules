# cognito

Terraform module that creates a Cognito user pool configured for social-only login via Google, Facebook, and Sign In with Apple. Includes a hosted UI domain and a user pool client with Authorization Code flow.

## Resources created

- `aws_cognito_user_pool` — user pool with email as username, email verification, password policy, and account recovery
- `aws_cognito_user_pool_domain` — hosted UI subdomain
- `aws_cognito_user_pool_client` — app client with OAuth code flow and social identity providers
- `aws_cognito_identity_provider` — one each for Google, Facebook, and Apple

## Variables

| Name | Description | Required | Sensitive |
|------|-------------|----------|-----------|
| `app_name` | Application name used for naming and tagging | yes | no |
| `environment` | Deployment environment (prod, staging, dev) | yes | no |
| `domain_prefix` | Cognito hosted UI subdomain prefix | yes | no |
| `callback_urls` | List of allowed OAuth callback URLs | yes | no |
| `logout_urls` | List of allowed logout redirect URLs | yes | no |
| `google_client_id` | Google OAuth client ID | yes | yes |
| `google_client_secret` | Google OAuth client secret | yes | yes |
| `facebook_app_id` | Facebook app ID | yes | yes |
| `facebook_app_secret` | Facebook app secret | yes | yes |
| `apple_services_id` | Apple services ID for Sign In with Apple | yes | yes |
| `apple_team_id` | Apple developer team ID | yes | yes |
| `apple_key_id` | Apple private key ID | yes | yes |
| `apple_private_key` | Full contents of the Apple .p8 private key file | yes | yes |

## Outputs

| Name | Description |
|------|-------------|
| `user_pool_id` | ID of the Cognito user pool |
| `user_pool_arn` | ARN of the Cognito user pool |
| `user_pool_client_id` | ID of the user pool app client |
| `user_pool_domain` | Full hosted UI base URL (e.g. `https://your-prefix.auth.us-east-2.amazoncognito.com`) |
| `user_pool_endpoint` | JWKS issuer URL for JWT validation (e.g. in Flask with `python-jose`) |

## Usage

```hcl
module "cognito" {
  source = "git@github.com:osiris43/infra-modules.git//modules/cognito?ref=vX.Y.Z"

  app_name      = "myapp"
  environment   = "prod"
  domain_prefix = "myapp-auth"

  callback_urls = [
    "http://localhost:3000/callback",
    "https://myapp.com/callback",
  ]
  logout_urls = [
    "http://localhost:3000",
    "https://myapp.com",
  ]

  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  facebook_app_id     = var.facebook_app_id
  facebook_app_secret = var.facebook_app_secret

  apple_services_id = var.apple_services_id
  apple_team_id     = var.apple_team_id
  apple_key_id      = var.apple_key_id
  apple_private_key = file("path/to/AuthKey.p8")
}
```

## JWT validation in Flask

Use the `user_pool_endpoint` output as the issuer and `user_pool_client_id` as the audience:

```python
from jose import jwt

COGNITO_ISSUER   = "<user_pool_endpoint output>"
COGNITO_AUDIENCE = "<user_pool_client_id output>"
JWKS_URL         = f"{COGNITO_ISSUER}/.well-known/jwks.json"

def verify_token(token: str) -> dict:
    headers = jwt.get_unverified_headers(token)
    jwks = requests.get(JWKS_URL).json()
    public_key = next(k for k in jwks["keys"] if k["kid"] == headers["kid"])
    return jwt.decode(token, public_key, algorithms=["RS256"],
                      audience=COGNITO_AUDIENCE, issuer=COGNITO_ISSUER)
```

## Notes

- `domain_prefix` must be globally unique across all AWS accounts.
- The Apple `.p8` private key should be kept in a secrets manager; pass it via environment variable or SSM rather than committing it.
- Facebook's `api_version` is pinned to `v17.0`. Update it when Meta deprecates older versions.
