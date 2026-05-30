// =====================================
// GHULMIL APPLICATION - SUPABASE API ENDPOINTS
// =====================================

/**
 * This file documents the REST API endpoints that will be used by the Flutter app.
 * These endpoints are designed to match the existing API documentation.
 */

// =====================================
// AUTHENTICATION ENDPOINTS
// =====================================

GET /auth/user
- Get current authenticated user profile
- Returns: User object with profile information

POST /auth/login
- Authenticate user with email/password
- Body: { email, password }
- Returns: Auth tokens and user profile

POST /auth/register
- Register new user
- Body: { email, password, full_name, phone, user_type }
- Returns: Auth tokens and user profile

POST /auth/logout
- Logout current user
- Returns: Success confirmation

// =====================================
// SERVICES ENDPOINTS
// =====================================

GET /services
- Get all available services with pagination
- Query params: category, limit, offset
- Returns: { services: [], total, hasMore }

GET /services/{serviceId}
- Get detailed service information
- Returns: Service object with packages

GET /services/{serviceId}/availability
- Get available time slots for a service
- Query params: date (YYYY-MM-DD)
- Returns: { slots: [] }

// =====================================
// PROVIDERS ENDPOINTS
// =====================================

GET /providers/available
- Get available providers for service and time
- Query params: serviceId, dateTime, limit
- Returns: { providers: [] }

GET /providers/{providerId}
- Get detailed provider information
- Returns: Provider object with stats and reviews

GET /providers/{providerId}/availability
- Get provider's availability schedule
- Returns: { availability: [] }

// =====================================
// BOOKINGS ENDPOINTS
// =====================================

GET /bookings
- Get user's bookings with pagination
- Query params: status, limit, offset
- Returns: { bookings: [], total, hasMore }

GET /bookings/{bookingId}
- Get detailed booking information
- Returns: Booking object with related data

POST /bookings
- Create new booking
- Body: BookingDraft object
- Returns: Created booking

POST /bookings/{bookingId}/cancel
- Cancel existing booking
- Body: { reason, refundAmount }
- Returns: Updated booking

// =====================================
// TRACKING ENDPOINTS
// =====================================

GET /bookings/{bookingId}/tracking
- Get real-time tracking updates (Server-Sent Events)
- Returns: Stream of location updates

POST /bookings/{bookingId}/tracking
- Update provider location (Provider only)
- Body: LocationUpdate object
- Returns: Success confirmation

// =====================================
// PAYMENTS ENDPOINTS
// =====================================

GET /payment-methods
- Get user's saved payment methods
- Returns: { paymentMethods: [] }

POST /payment-methods
- Add new payment method
- Body: PaymentMethod object
- Returns: Created payment method

DELETE /payment-methods/{paymentMethodId}
- Remove payment method
- Returns: Success confirmation

POST /payments
- Process payment for booking
- Body: { bookingId, paymentMethodId, amount, currency }
- Returns: Payment object

GET /payments/{paymentId}
- Get payment details
- Returns: Payment object

// =====================================
// REVIEWS ENDPOINTS
// =====================================

GET /services/{serviceId}/reviews
- Get reviews for a service
- Query params: limit, offset, rating
- Returns: { reviews: [], averageRating, totalReviews }

GET /providers/{providerId}/reviews
- Get reviews for a provider
- Query params: limit, offset, rating
- Returns: { reviews: [], averageRating, totalReviews }

POST /reviews
- Create review for completed booking
- Body: { bookingId, rating, comment, photos }
- Returns: Created review

// =====================================
// SUBSCRIPTIONS ENDPOINTS
// =====================================

GET /subscriptions
- Get user's subscriptions
- Returns: { subscriptions: [] }

POST /subscriptions
- Create new subscription
- Body: Subscription object
- Returns: Created subscription

PUT /subscriptions/{subscriptionId}
- Update subscription
- Body: Partial subscription updates
- Returns: Updated subscription

DELETE /subscriptions/{subscriptionId}
- Cancel subscription
- Returns: Success confirmation

// =====================================
// ADDRESSES ENDPOINTS
// =====================================

GET /addresses
- Get user's saved addresses
- Returns: { addresses: [] }

POST /addresses
- Create new address
- Body: Address object
- Returns: Created address

PUT /addresses/{addressId}
- Update address
- Body: Partial address updates
- Returns: Updated address

DELETE /addresses/{addressId}
- Delete address
- Returns: Success confirmation

// =====================================
// NOTIFICATIONS ENDPOINTS
// =====================================

GET /notifications
- Get user's notifications
- Query params: limit, offset, is_read
- Returns: { notifications: [], total, hasMore }

PUT /notifications/{notificationId}/read
- Mark notification as read
- Returns: Updated notification

PUT /notifications/mark-all-read
- Mark all notifications as read
- Returns: Success confirmation

// =====================================
// ADMIN ENDPOINTS
// =====================================

GET /admin/analytics
- Get platform analytics
- Query params: period, metric
- Returns: Analytics data

GET /admin/users
- Get all users (Admin only)
- Query params: user_type, limit, offset
- Returns: { users: [], total, hasMore }

GET /admin/bookings
- Get all bookings (Admin only)
- Query params: status, limit, offset
- Returns: { bookings: [], total, hasMore }

POST /admin/services
- Create new service (Admin only)
- Body: Service object
- Returns: Created service

PUT /admin/services/{serviceId}
- Update service (Admin only)
- Body: Partial service updates
- Returns: Updated service

// =====================================
// REAL-TIME SUBSCRIPTIONS
// =====================================

WebSocket /realtime/bookings/{bookingId}
// Real-time booking status updates

WebSocket /realtime/tracking/{bookingId}
// Real-time location tracking

WebSocket /realtime/notifications
// Real-time notifications

// =====================================
// WEBHOOK ENDPOINTS
// =====================================

POST /webhooks/stripe
- Handle Stripe payment webhooks
- Headers: X-Signature (webhook signature)
- Body: Stripe webhook payload

POST /webhooks/sendgrid
- Handle email delivery webhooks
- Body: SendGrid webhook payload

POST /webhooks/twilio
- Handle SMS delivery webhooks
- Body: Twilio webhook payload

// =====================================
// FILE UPLOAD ENDPOINTS
// =====================================

POST /upload/avatar
- Upload user avatar
- Body: FormData with image file
- Returns: { url: "uploaded_image_url" }

POST /upload/service-images
- Upload service images
- Body: FormData with image files
- Returns: { urls: ["url1", "url2"] }

POST /upload/review-photos
- Upload review photos
- Body: FormData with image files
- Returns: { urls: ["url1", "url2"] }

// =====================================
// UTILITY ENDPOINTS
// =====================================

GET /health
- Health check endpoint
- Returns: { status: "healthy", timestamp }

GET /config
- Get public configuration
- Returns: { stripe_publishable_key, maps_api_key, ... }
