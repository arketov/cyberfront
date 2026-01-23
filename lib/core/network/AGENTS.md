# AGENTS.md

## API Usage Rules
- Private API calls live in API service classes (under `lib/features/**/data` or `lib/core/**`), not in UI/widgets.
- UI must not build `Authorization` headers or pass raw tokens.
- Use `AuthService.withAuth(...)` inside the API service for private endpoints.
- If a private call needs a token, expose a `getXWithAuth(AuthService auth)` method that wraps `withAuth`.
- Handle `401` only via `AuthService.withAuth` (refresh + logout on failure). Do not re-implement this in UI.
- Use `RestApiClient` from `createApiClient(AppConfig.dev)` in services.

## Token Storage
- Store session only via `AuthStorage` (secure storage). Never use `SharedPreferences` for tokens.
- Do not cache tokens in UI state; rely on `AuthService.session` for display and `withAuth` for calls.

## Error Handling
- API services throw `ApiException` for non-2xx responses.
- Do not swallow errors in services unless specifically required; let UI decide how to show errors.

