# Parkezy Backend API Documentation

## Base URL
```
http://localhost:8000/api/
```

## Authentication
The API uses JWT (JSON Web Token) authentication. Include the access token in the Authorization header:
```
Authorization: Bearer <access_token>
```

---

## API Endpoints

### 1. User Management

#### Register User
```http
POST /api/users/register/
Content-Type: application/json

{
  "email": "user@example.com",
  "name": "John Doe",
  "phone_number": "+1234567890",
  "password": "password123",
  "password_confirm": "password123",
  "is_host": false
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "phone_number": "+1234567890",
    "is_host": false,
    "host_rating": null,
    "total_bookings": 0
  },
  "tokens": {
    "refresh": "refresh_token",
    "access": "access_token"
  }
}
```

#### Login
```http
POST /api/users/login/
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Get Current User
```http
GET /api/users/me/
Authorization: Bearer <token>
```

#### Update Profile
```http
PATCH /api/users/update_profile/
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Jane Doe",
  "phone_number": "+0987654321"
}
```

#### Switch Role (Driver ↔ Host)
```http
POST /api/users/switch_role/
Authorization: Bearer <token>
```

#### Get User Stats
```http
GET /api/users/stats/
Authorization: Bearer <token>
```

---

### 2. Parking Spots

#### List All Parking Spots
```http
GET /api/parking-spots/
Authorization: Bearer <token>

Query Parameters:
- spot_type: mall, private_driveway, office, apartment, hospital, airport, stadium
- is_occupied: true/false
- has_ev_charging: true/false
- has_cctv: true/false
- is_covered: true/false
- max_price: decimal
- available_only: true/false
- lat: latitude (for distance calculation)
- lon: longitude (for distance calculation)
- search: address search
```

#### Get Nearby Spots
```http
GET /api/parking-spots/nearby/
Authorization: Bearer <token>

Query Parameters:
- lat: latitude (required)
- lon: longitude (required)
- radius: meters (default: 5000)
```

#### Create Parking Spot
```http
POST /api/parking-spots/
Authorization: Bearer <token>
Content-Type: application/json

{
  "address": "123 Main St, City",
  "latitude": "28.5494",
  "longitude": "77.2344",
  "spot_type": "private_driveway",
  "price_per_hour": "50.00",
  "daily_rate": "400.00",
  "has_cctv": true,
  "is_covered": true,
  "has_ev_charging": false,
  "is_24_hours": true,
  "access_pin": "123456"
}
```

#### Update Parking Spot
```http
PATCH /api/parking-spots/{id}/
Authorization: Bearer <token>
Content-Type: application/json

{
  "price_per_hour": "60.00",
  "is_occupied": false
}
```

#### Toggle Occupancy
```http
POST /api/parking-spots/{id}/toggle_occupancy/
Authorization: Bearer <token>
```

---

### 3. Commercial Parking Facilities

#### List Commercial Facilities
```http
GET /api/commercial-facilities/
Authorization: Bearer <token>

Query Parameters:
- facility_type: mall, office, apartment, hospital, airport, stadium
- has_ev_charging: true/false
- has_valet_service: true/false
- is_24_hours: true/false
- lat: latitude
- lon: longitude
- search: name or address
```

#### Create Commercial Facility
```http
POST /api/commercial-facilities/
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "City Mall Parking",
  "address": "456 Shopping Ave",
  "latitude": "28.5285",
  "longitude": "77.2182",
  "facility_type": "mall",
  "default_hourly_rate": "80.00",
  "flat_day_rate": "500.00",
  "has_cctv": true,
  "has_ev_charging": true,
  "is_24_hours": true
}
```

#### Get Facility Slots
```http
GET /api/commercial-facilities/{id}/slots/
Authorization: Bearer <token>

Query Parameters:
- floor: floor number
- available: true/false
```

#### Create Slots (Bulk)
```http
POST /api/commercial-facilities/{id}/create_slots/
Authorization: Bearer <token>
Content-Type: application/json

{
  "count": 50,
  "floor": 1,
  "slot_type": "regular"
}
```

---

### 4. Private Parking Listings

#### List Private Listings
```http
GET /api/private-listings/
Authorization: Bearer <token>

Query Parameters:
- has_cctv: true/false
- is_covered: true/false
- has_ev_charging: true/false
- is_24_hours: true/false
- lat: latitude
- lon: longitude
- search: title, address, or description
```

#### Create Private Listing
```http
POST /api/private-listings/
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Spacious Driveway in GK-1",
  "address": "Greater Kailash I, New Delhi",
  "latitude": "28.5494",
  "longitude": "77.2344",
  "description": "Secure parking with 24/7 access",
  "total_slots": 2,
  "hourly_rate": "40.00",
  "daily_rate": "300.00",
  "monthly_rate": "3000.00",
  "has_cctv": true,
  "is_covered": false,
  "has_ev_charging": false,
  "auto_accept_bookings": true,
  "is_24_hours": true
}
```

#### Get Pricing Intelligence
```http
POST /api/private-listings/{id}/pricing_intelligence/
Authorization: Bearer <token>
```

**Response:**
```json
{
  "suggested_hourly_rate": "45.00",
  "current_rate": "40.00",
  "nearby_listings_count": 5,
  "avg_nearby_rate": "45.50",
  "min_nearby_rate": "35.00",
  "max_nearby_rate": "55.00"
}
```

---

### 5. Bookings

#### Create Booking
```http
POST /api/bookings/
Authorization: Bearer <token>
Content-Type: application/json

{
  "spot_id": "uuid-of-spot",
  "spot_type": "parking_spot",
  "scheduled_start_time": "2026-02-04T10:00:00Z",
  "scheduled_end_time": "2026-02-04T12:00:00Z",
  "duration": 2.0,
  "total_cost": "118.00",
  "access_code": "123456"
}
```

#### List User Bookings
```http
GET /api/bookings/
Authorization: Bearer <token>

Query Parameters:
- status: pending, confirmed, active, completed, cancelled, disputed
- spot_id: uuid
- spot_type: parking_spot, commercial_slot, private_slot
```

#### Get Active Bookings
```http
GET /api/bookings/active/
Authorization: Bearer <token>
```

#### Get Booking History
```http
GET /api/bookings/history/
Authorization: Bearer <token>
```

#### Start Booking Session
```http
POST /api/bookings/{id}/start/
Authorization: Bearer <token>
```

#### End Booking Session
```http
POST /api/bookings/{id}/end/
Authorization: Bearer <token>
```

#### Extend Booking
```http
POST /api/bookings/{id}/extend/
Authorization: Bearer <token>
Content-Type: application/json

{
  "additional_hours": 1.0
}
```

#### Cancel Booking
```http
POST /api/bookings/{id}/cancel/
Authorization: Bearer <token>
```

#### Get Host Bookings
```http
GET /api/bookings/?host_spots=true
Authorization: Bearer <token>
```

---

### 6. Disputes

#### Create Dispute
```http
POST /api/disputes/
Authorization: Bearer <token>
Content-Type: application/json

{
  "booking": "uuid-of-booking",
  "reason": "Spot was not as described",
  "description": "The parking spot was occupied when I arrived",
  "photo_urls": ["url1", "url2"]
}
```

#### List Disputes
```http
GET /api/disputes/
Authorization: Bearer <token>

Query Parameters:
- status: pending, under_review, resolved, rejected
- booking: booking_id
```

#### Update Dispute Status
```http
PATCH /api/disputes/{id}/
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "resolved",
  "resolution": "Refund issued"
}
```

---

## Response Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Missing or invalid authentication
- **403 Forbidden**: Not authorized to access resource
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error

---

## Error Response Format

```json
{
  "error": "Error message description",
  "details": {
    "field": ["Error detail"]
  }
}
```

---

## Pagination

List endpoints return paginated results:

```json
{
  "count": 100,
  "next": "http://localhost:8000/api/endpoint/?page=2",
  "previous": null,
  "results": [...]
}
```

Query Parameters:
- `page`: Page number
- `page_size`: Items per page (default: 20, max: 100)
