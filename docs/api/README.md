# API Documentation

## Overview

The Policy Logs API is a RESTful service built with Django REST Framework. It provides endpoints for managing policy logs, user authentication, comments, and more.

## Base URL
- Development: `http://localhost:8000/api/`
- Production: `https://your-domain.com/api/`

## Authentication

All authenticated endpoints require a token in the Authorization header:
```
Authorization: Token <your-token>
```

### Obtaining a Token
```bash
POST /api/auth/login/
Content-Type: application/json

{
  "username": "your_username",
  "password": "your_password"
}
```

Response:
```json
{
  "token": "your_auth_token",
  "user": {
    "id": 1,
    "username": "your_username",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

## Endpoints

### Authentication Endpoints

#### POST /api/auth/login/
Login with username and password.

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "token": "string",
  "user": {
    "id": 1,
    "username": "string",
    "email": "string",
    "first_name": "string",
    "last_name": "string"
  }
}
```

#### POST /api/auth/register/
Register a new user account.

**Request:**
```json
{
  "username": "string",
  "email": "string",
  "first_name": "string",
  "last_name": "string",
  "password": "string",
  "password_confirm": "string"
}
```

#### POST /api/auth/logout/
Logout and invalidate token (requires authentication).

#### GET /api/auth/profile/
Get current user profile (requires authentication).

### Policy Logs Endpoints

#### GET /api/policy-logs/
Get list of policy logs.

**Query Parameters:**
- `page`: Page number (default: 1)
- `search`: Search query for title/description
- `status`: Filter by status (active, pending, inactive)
- `tags`: Filter by tag IDs

**Response:**
```json
{
  "count": 100,
  "next": "http://localhost:8000/api/policy-logs/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "title": "Data Privacy Policy",
      "description": "Updated privacy policy...",
      "created_by_name": "John Doe",
      "created_at": "2023-01-01T10:00:00Z",
      "updated_at": "2023-01-02T15:30:00Z",
      "status": "active",
      "tags": [
        {
          "id": 1,
          "name": "Privacy",
          "color": "#007bff"
        }
      ],
      "comments_count": 5
    }
  ]
}
```

#### POST /api/policy-logs/
Create a new policy log (requires authentication).

**Request:**
```json
{
  "title": "string",
  "description": "string",
  "status": "pending",
  "tag_ids": [1, 2, 3]
}
```

#### GET /api/policy-logs/{id}/
Get specific policy log details.

#### PUT /api/policy-logs/{id}/
Update policy log (requires authentication and ownership).

#### DELETE /api/policy-logs/{id}/
Delete policy log (requires authentication and ownership).

#### POST /api/policy-logs/{id}/add_comment/
Add comment to policy log (requires authentication).

**Request:**
```json
{
  "content": "This is a comment"
}
```

#### GET /api/policy-logs/my_logs/
Get logs created by current user (requires authentication).

### Tags Endpoints

#### GET /api/tags/
Get list of all tags.

**Response:**
```json
[
  {
    "id": 1,
    "name": "Privacy",
    "color": "#007bff"
  },
  {
    "id": 2,
    "name": "Security",
    "color": "#28a745"
  }
]
```

#### POST /api/tags/
Create new tag (requires authentication).

**Request:**
```json
{
  "name": "string",
  "color": "#ffffff"
}
```

## Error Responses

The API uses conventional HTTP response codes:

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

Error response format:
```json
{
  "error": "Error message",
  "details": {
    "field_name": ["Field-specific error messages"]
  }
}
```

## Pagination

List endpoints use pagination with the following structure:

```json
{
  "count": 100,
  "next": "http://localhost:8000/api/policy-logs/?page=3",
  "previous": "http://localhost:8000/api/policy-logs/?page=1", 
  "results": []
}
```

Default page size is 20 items. Use the `page` query parameter to navigate.

## Rate Limiting

API requests are rate limited to:
- 1000 requests per hour for authenticated users
- 100 requests per hour for anonymous users

## Filtering and Searching

### Search
Use the `search` parameter to search across titles and descriptions:
```
GET /api/policy-logs/?search=privacy
```

### Filtering
Use field names as query parameters:
```
GET /api/policy-logs/?status=active&tags=1,2
```

### Ordering
Use the `ordering` parameter:
```
GET /api/policy-logs/?ordering=-created_at
```

Available ordering fields:
- `created_at` / `-created_at`
- `updated_at` / `-updated_at`
- `title` / `-title`

## Examples

### Create a Policy Log with cURL

```bash
curl -X POST http://localhost:8000/api/policy-logs/ \
  -H "Authorization: Token your_token_here" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Security Policy",
    "description": "This policy outlines our new security measures",
    "status": "pending",
    "tag_ids": [1, 3]
  }'
```

### Search Policy Logs

```bash
curl "http://localhost:8000/api/policy-logs/?search=security&status=active" \
  -H "Authorization: Token your_token_here"
```

### Add Comment to Log

```bash
curl -X POST http://localhost:8000/api/policy-logs/1/add_comment/ \
  -H "Authorization: Token your_token_here" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "This looks good to me!"
  }'
```