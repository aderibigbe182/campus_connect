# Campus Connect backend integration

This Flutter project connects to two independent services. Authentication,
profile, privacy, storage, invites, and feedback use the Node/Express service.
Chats, groups, stories, calls, media, contextual search, and presence use the
Python/FastAPI service.

## Configure service URLs

The Android emulator defaults are Node `http://10.0.2.2:3000` and Python
`http://10.0.2.2:8000`. For a physical phone, use the computer's LAN IP. For
deployed services, use HTTPS URLs. Configure both at build time:

```sh
flutter run \
  --dart-define=NODE_API_BASE_URL=https://your-node-host \
  --dart-define=PYTHON_API_BASE_URL=https://your-python-host
```

The Node origin is the server root (the client adds `/api/...`). The Python
origin is also the server root; Python routes already contain `/api` and do
not use `/api/v1`.

## Authentication contract

The app posts JSON to `POST /api/auth/register` and `POST /api/auth/login`.
Both Node responses contain `token` and `user`; the Flutter auth service stores
the token and user id. Authenticated requests send `Authorization: Bearer <token>`.
`GET /api/auth/me` retrieves the current user.

The Python service verifies the Node-issued JWT. Configure both services with
the same strong `JWT_SECRET` and compatible algorithm (`HS256` in the supplied
Python config). Both services must use the same PostgreSQL database and matching
user ids for this shared token flow to work.

## Python route map used by the client facade

- `/api/chats`, `/api/chat-requests`, and `/api/friends`
- `/api/groups`
- `/api/stories`
- `/api/calls`
- `/api/search`
- `/api/media`
- `/ws/chats/{chat_id}` and `/ws/calls/{call_id}` WebSockets

Python success payloads are generally `{success: true, data: {...}}`; the
`CampusConnectApi` facade unwraps this envelope for its high-level operations.
See `lib/core/services/campus_connect_api.dart` for method-to-route mappings
and `lib/core/services/api_service.dart` for authenticated JSON transport.

## Database migrations

Run the Node project’s base user schema first, then the Python project’s
`database/phase2_schema.sql` and `database/phase3_friends.sql`. The friend
migration creates the `friend_requests` and `blocked_users` tables consumed
by the new friend, chat-request, and story privacy routes.

The Flutter chat and group services now call the Python routes and translate
their `{success, data}` responses into the existing app models. Friend search,
lists, requests, accept/reject, and removal use the new Python friend routes.
Starting a direct chat creates a pending chat request for non-friends; incoming
and outgoing requests appear in the chat list, where the recipient can accept
or decline.
Node registration requires `full_name`, `username`, `phone`, `email`,
`password`, and `university`; the Flutter registration service sends all six.

Do not put backend credentials or `.env` files in the Flutter archive. Supply
secrets through each backend's deployment environment.
