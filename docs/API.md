# API Documentation

## Overview

This document describes the REST API endpoints for the Ghulmil Application. The API follows RESTful conventions and uses JSON for data serialization. All endpoints require authentication and return standard HTTP status codes.

## Base URL

```
https://api.ghulmil.com/v1
```

## Authentication

All API requests require authentication using Bearer tokens:

```
Authorization: Bearer <your_access_token>
```

## Response Format

All API responses follow this structure:

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully",
  "errors": null
}
```

Error responses:

```json
{
  "success": false,
  "data": null,
  "message": "Error description",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

## HTTP Status Codes

- **200 OK** - Request successful
- **201 Created** - Resource created successfully
- **400 Bad Request** - Invalid request data
- **401 Unauthorized** - Authentication required
- **403 Forbidden** - Access denied
- **404 Not Found** - Resource not found
- **422 Unprocessable Entity** - Validation errors
- **500 Internal Server Error** - Server error

## Data Models

### Service
```json
{
  "id": "string",
  "title": "string",
  "subtitle": "string",
  "packages": [
    {
      "id": "string",
      "title": "string",
      "durationMinutes": 120,
      "price": 49.99,
      "inclusions": ["string"]
    }
  ],
  "rating": 4.7,
  "tags": ["string"],
  "imageUrl": "string"
}
```

### Booking
```json
{
  "id": "string",
  "serviceId": "string",
  "packageId": "string",
  "providerId": "string",
  "status": "pending|confirmed|enroute|inProgress|completed|cancelled",
  "createdAt": "2024-01-01T10:00:00Z",
  "scheduledAt": "2024-01-02T14:00:00Z",
  "price": {
    "subtotal": 49.99,
    "tax": 5.00,
    "total": 54.99,
    "currency": "USD"
  },
  "provider": {
    "id": "string",
    "name": "string",
    "photoUrl": "string",
    "rating": 4.8,
    "verified": true,
    "languages": ["string"]
  }
}
```

### BookingDraft
```json
{
  "serviceId": "string",
  "packageId": "string",
  "providerId": "string",
  "scheduledAt": "2024-01-02T14:00:00Z",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "coordinates": {
      "latitude": 40.7128,
      "longitude": -74.0060
    }
  }
}
```

### LocationUpdate
```json
{
  "bookingId": "string",
  "providerId": "string",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "heading": 90,
  "speed": 30,
  "etaMinutes": 15,
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### Address
```json
{
  "id": "string",
  "label": "string",
  "street": "string",
  "city": "string",
  "state": "string",
  "zipCode": "string",
  "coordinates": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "isDefault": true
}
```

### Package
```json
{
  "id": "string",
  "title": "string",
  "durationMinutes": 120,
  "price": 49.99,
  "inclusions": ["string"],
  "exclusions": ["string"],
  "description": "string"
}
```

### Provider
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "photoUrl": "string",
  "rating": 4.8,
  "verified": true,
  "languages": ["string"],
  "bio": "string",
  "experience": "5 years",
  "certifications": ["string"]
}
```

### Slot
```json
{
  "start": "2024-01-02T13:00:00Z",
  "end": "2024-01-02T14:00:00Z",
  "providerCount": 3
}
```

### PaymentMethod
```json
{
  "id": "string",
  "type": "credit_card|debit_card|digital_wallet|cash",
  "lastFour": "string",
  "brand": "visa|mastercard|amex",
  "isDefault": true
}
```

### PriceBreakdown
```json
{
  "subtotal": 49.99,
  "tax": 5.00,
  "serviceFee": 2.50,
  "total": 57.49,
  "currency": "USD",
  "breakdown": [
    {
      "label": "Service Cost",
      "amount": 49.99
    },
    {
      "label": "Tax",
      "amount": 5.00
    }
  ]
}
```

## API Endpoints

### Services

#### Get All Services
**GET** `/services`

Get a list of all available services.

**Query Parameters:**
- `category` (optional) - Filter by service category
- `limit` (optional) - Number of results (default: 20)
- `offset` (optional) - Offset for pagination (default: 0)

**Response:**
```json
{
  "success": true,
  "data": {
    "services": [
      {
        "id": "cleaning_1",
        "title": "Household Cleaning",
        "subtitle": "Professional cleaning for your home",
        "packages": [...],
        "rating": 4.7,
        "tags": ["Cleaning", "Home", "Verified"],
        "imageUrl": "https://example.com/image.jpg"
      }
    ],
    "total": 1,
    "hasMore": false
  }
}
```

#### Get Service by ID
**GET** `/services/{serviceId}`

Get detailed information about a specific service.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "cleaning_1",
    "title": "Household Cleaning",
    "subtitle": "Professional cleaning for your home",
    "packages": [...],
    "rating": 4.7,
    "tags": ["Cleaning", "Home", "Verified"],
    "imageUrl": "https://example.com/image.jpg"
  }
}
```

#### Get Service Availability
**GET** `/services/{serviceId}/availability`

Get available time slots for a service on a specific date.

**Query Parameters:**
- `date` (required) - Date in YYYY-MM-DD format

**Response:**
```json
{
  "success": true,
  "data": {
    "serviceId": "cleaning_1",
    "date": "2024-01-02",
    "slots": [
      {
        "start": "2024-01-02T13:00:00Z",
        "end": "2024-01-02T14:00:00Z",
        "providerCount": 3
      }
    ]
  }
}
```

### Bookings

#### Create Booking
**POST** `/bookings`

Create a new booking from a booking draft.

**Request Body:**
```json
{
  "serviceId": "string",
  "packageId": "string",
  "providerId": "string",
  "scheduledAt": "2024-01-02T14:00:00Z",
  "address": {
    "street": "string",
    "city": "string",
    "state": "string",
    "zipCode": "string",
    "coordinates": {
      "latitude": 40.7128,
      "longitude": -74.0060
    }
  },
  "specialInstructions": "Please ring the doorbell twice"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bk_1234567890",
    "serviceId": "cleaning_1",
    "packageId": "pkg_01",
    "providerId": "prov_123",
    "status": "confirmed",
    "createdAt": "2024-01-01T10:00:00Z",
    "scheduledAt": "2024-01-02T14:00:00Z",
    "price": {
      "subtotal": 49.99,
      "tax": 5.00,
      "total": 54.99,
      "currency": "USD"
    }
  }
}
```

#### Get Booking by ID
**GET** `/bookings/{bookingId}`

Get detailed information about a specific booking.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bk_1234567890",
    "serviceId": "cleaning_1",
    "packageId": "pkg_01",
    "providerId": "prov_123",
    "status": "confirmed",
    "createdAt": "2024-01-01T10:00:00Z",
    "scheduledAt": "2024-01-02T14:00:00Z",
    "price": {
      "subtotal": 49.99,
      "tax": 5.00,
      "total": 54.99,
      "currency": "USD"
    },
    "provider": {
      "id": "prov_123",
      "name": "John Doe",
      "photoUrl": "https://example.com/photo.jpg",
      "rating": 4.8,
      "verified": true,
      "languages": ["English", "Spanish"]
    }
  }
}
```

#### Get User's Bookings
**GET** `/bookings`

Get all bookings for the authenticated user.

**Query Parameters:**
- `status` (optional) - Filter by booking status
- `limit` (optional) - Number of results (default: 20)
- `offset` (optional) - Offset for pagination (default: 0)

**Response:**
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "id": "bk_1234567890",
        "serviceId": "cleaning_1",
        "packageId": "pkg_01",
        "providerId": "prov_123",
        "status": "confirmed",
        "createdAt": "2024-01-01T10:00:00Z",
        "scheduledAt": "2024-01-02T14:00:00Z"
      }
    ],
    "total": 1,
    "hasMore": false
  }
}
```

#### Cancel Booking
**POST** `/bookings/{bookingId}/cancel`

Cancel an existing booking.

**Request Body:**
```json
{
  "reason": "Customer request",
  "refundAmount": 54.99
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bk_1234567890",
    "status": "cancelled",
    "cancelledAt": "2024-01-01T11:00:00Z",
    "refundAmount": 54.99
  }
}
```

### Tracking

#### Get Booking Location Updates
**GET** `/bookings/{bookingId}/tracking`

Get real-time location updates for a booking. This endpoint supports Server-Sent Events (SSE) for continuous updates.

**Response (SSE):**
```
event: location_update
data: {
  "bookingId": "bk_1234567890",
  "providerId": "prov_123",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "heading": 90,
  "speed": 30,
  "etaMinutes": 15,
  "timestamp": "2024-01-01T10:00:00Z"
}

event: status_update
data: {
  "bookingId": "bk_1234567890",
  "status": "enroute",
  "message": "Provider is on the way"
}
```

### Addresses

#### Get User's Addresses
**GET** `/addresses`

Get all saved addresses for the authenticated user.

**Response:**
```json
{
  "success": true,
  "data": {
    "addresses": [
      {
        "id": "addr_123",
        "label": "Home",
        "street": "123 Main St",
        "city": "New York",
        "state": "NY",
        "zipCode": "10001",
        "coordinates": {
          "latitude": 40.7128,
          "longitude": -74.0060
        },
        "isDefault": true
      }
    ]
  }
}
```

#### Create Address
**POST** `/addresses`

Create a new address.

**Request Body:**
```json
{
  "label": "Work",
  "street": "456 Business Ave",
  "city": "New York",
  "state": "NY",
  "zipCode": "10002",
  "coordinates": {
    "latitude": 40.7589,
    "longitude": -73.9851
  }
}
```

### Payments

#### Get Payment Methods
**GET** `/payment-methods`

Get all saved payment methods for the authenticated user.

**Response:**
```json
{
  "success": true,
  "data": {
    "paymentMethods": [
      {
        "id": "pm_123",
        "type": "credit_card",
        "lastFour": "4242",
        "brand": "visa",
        "isDefault": true
      }
    ]
  }
}
```

#### Process Payment
**POST** `/payments`

Process a payment for a booking.

**Request Body:**
```json
{
  "bookingId": "bk_1234567890",
  "paymentMethodId": "pm_123",
  "amount": 54.99,
  "currency": "USD"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "pay_1234567890",
    "bookingId": "bk_1234567890",
    "amount": 54.99,
    "currency": "USD",
    "status": "completed",
    "processedAt": "2024-01-01T10:00:00Z"
  }
}
```

### Reviews

#### Create Review
**POST** `/reviews`

Create a review for a completed booking.

**Request Body:**
```json
{
  "bookingId": "bk_1234567890",
  "rating": 5,
  "comment": "Excellent service, very professional!",
  "photos": ["https://example.com/photo1.jpg"]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "rev_1234567890",
    "bookingId": "bk_1234567890",
    "rating": 5,
    "comment": "Excellent service, very professional!",
    "createdAt": "2024-01-02T15:00:00Z"
  }
}
```

#### Get Service Reviews
**GET** `/services/{serviceId}/reviews`

Get reviews for a specific service.

**Query Parameters:**
- `limit` (optional) - Number of results (default: 20)
- `offset` (optional) - Offset for pagination (default: 0)
- `rating` (optional) - Filter by rating (1-5)

**Response:**
```json
{
  "success": true,
  "data": {
    "reviews": [
      {
        "id": "rev_1234567890",
        "bookingId": "bk_1234567890",
        "rating": 5,
        "comment": "Excellent service!",
        "customerName": "Jane Doe",
        "createdAt": "2024-01-02T15:00:00Z"
      }
    ],
    "averageRating": 4.8,
    "totalReviews": 150
  }
}
```

### Subscriptions

#### Create Subscription
**POST** `/subscriptions`

Create a recurring service subscription.

**Request Body:**
```json
{
  "serviceId": "cleaning_1",
  "packageId": "pkg_01",
  "frequency": "weekly",
  "preferredDay": "monday",
  "preferredTime": "14:00",
  "addressId": "addr_123",
  "paymentMethodId": "pm_123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "sub_1234567890",
    "serviceId": "cleaning_1",
    "packageId": "pkg_01",
    "frequency": "weekly",
    "status": "active",
    "nextBooking": "2024-01-08T14:00:00Z",
    "createdAt": "2024-01-01T10:00:00Z"
  }
}
```

#### Get User's Subscriptions
**GET** `/subscriptions`

Get all subscriptions for the authenticated user.

**Response:**
```json
{
  "success": true,
  "data": {
    "subscriptions": [
      {
        "id": "sub_1234567890",
        "serviceId": "cleaning_1",
        "packageId": "pkg_01",
        "frequency": "weekly",
        "status": "active",
        "nextBooking": "2024-01-08T14:00:00Z",
        "createdAt": "2024-01-01T10:00:00Z"
      }
    ]
  }
}
```

### Users

#### Get User Profile
**GET** `/users/profile`

Get the authenticated user's profile information.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_123",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "avatarUrl": "https://example.com/avatar.jpg",
    "createdAt": "2023-12-01T10:00:00Z"
  }
}
```

#### Update User Profile
**PUT** `/users/profile`

Update the authenticated user's profile information.

**Request Body:**
```json
{
  "name": "John Doe",
  "phone": "+1234567890"
}
```

### Providers

#### Get Available Providers
**GET** `/providers/available`

Get available providers for a specific service and time.

**Query Parameters:**
- `serviceId` (required) - Service ID
- `dateTime` (required) - Date and time for the service
- `limit` (optional) - Number of results (default: 10)

**Response:**
```json
{
  "success": true,
  "data": {
    "providers": [
      {
        "id": "prov_123",
        "name": "John Doe",
        "photoUrl": "https://example.com/photo.jpg",
        "rating": 4.8,
        "verified": true,
        "languages": ["English", "Spanish"],
        "distance": 2.5,
        "etaMinutes": 15
      }
    ]
  }
}
```

#### Get Provider by ID
**GET** `/providers/{providerId}`

Get detailed information about a specific provider.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "prov_123",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "photoUrl": "https://example.com/photo.jpg",
    "rating": 4.8,
    "verified": true,
    "languages": ["English", "Spanish"],
    "bio": "Experienced cleaning professional with 5+ years",
    "experience": "5 years",
    "certifications": ["Licensed Professional Cleaner"],
    "reviews": 127,
    "completedJobs": 342
  }
}
```

## Error Handling

### Validation Errors
When request data fails validation:

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email is required", "Email format is invalid"],
    "phone": ["Phone number is required"]
  }
}
```

### Common HTTP Status Codes
- **400 Bad Request** - Invalid request parameters or JSON
- **401 Unauthorized** - Missing or invalid authentication
- **403 Forbidden** - User doesn't have permission for the resource
- **404 Not Found** - Resource doesn't exist
- **422 Unprocessable Entity** - Validation errors
- **429 Too Many Requests** - Rate limiting exceeded
- **500 Internal Server Error** - Server-side error

## Rate Limiting

API requests are rate-limited to prevent abuse:

- **Authentication endpoints**: 5 requests per minute
- **Booking endpoints**: 10 requests per minute
- **General endpoints**: 60 requests per minute

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1609459200
```

## Webhooks

Ghulmil supports webhooks for real-time notifications:

### Webhook Events
- `booking.created` - New booking created
- `booking.updated` - Booking status changed
- `booking.cancelled` - Booking cancelled
- `payment.succeeded` - Payment processed successfully
- `review.created` - New review submitted

### Webhook Payload
```json
{
  "event": "booking.created",
  "timestamp": "2024-01-01T10:00:00Z",
  "data": {
    "id": "bk_1234567890",
    "serviceId": "cleaning_1",
    "packageId": "pkg_01",
    "providerId": "prov_123",
    "status": "confirmed",
    "createdAt": "2024-01-01T10:00:00Z"
  }
}
```

### Webhook Registration
**POST** `/webhooks`

Register a webhook endpoint.

**Request Body:**
```json
{
  "url": "https://your-app.com/webhooks",
  "events": ["booking.created", "booking.updated"],
  "secret": "your_webhook_secret"
}
```
