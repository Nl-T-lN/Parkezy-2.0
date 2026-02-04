#!/usr/bin/env python3
"""Quick API verification script"""
import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8000/api"

def test_endpoint(name, method, url, data=None, headers=None, expected_status=None):
    """Test a single endpoint"""
    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=5)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=5)
        
        status = response.status_code
        success = (expected_status is None) or (status == expected_status) or (200 <= status < 300 and expected_status is None)
        
        symbol = "✅" if success else "❌"
        print(f"{symbol} {name}: {status}")
        
        if not success and response.text:
            print(f"   Error: {response.text[:100]}")
        
        return response if success else None
    except Exception as e:
        print(f"❌ {name}: ERROR - {str(e)}")
        return None

print("=" * 60)
print("PARKEZY API QUICK VERIFICATION")
print("=" * 60)

# 1. User Registration
print("\n📝 User Management:")
timestamp = datetime.now().timestamp()
register_data = {
    "email": f"apitest{timestamp}@test.com",
    "name": "API Test User",
    "password": "test123",
    "password_confirm": "test123",
    "phone_number": "+1234567890",
    "is_host": True
}
register_response = test_endpoint(
    "Register User",
    "POST",
    f"{BASE_URL}/users/register/",
    data=register_data,
    expected_status=201
)

token = None
if register_response:
    try:
        token = register_response.json()["tokens"]["access"]
        print(f"   📌 Token obtained: {token[:30]}...")
    except:
        pass

# 2. Login
if token is None:
    login_data = {"email": "demo@parkezy.com", "password": "password123"}
    login_response = test_endpoint(
        "Login User",
        "POST",
        f"{BASE_URL}/users/login/",
        data=login_data,
        expected_status=200
    )
    if login_response:
        try:
            token = login_response.json()["tokens"]["access"]
        except:
            pass

# 3. Get Current User
if token:
    headers = {"Authorization": f"Bearer {token}"}
    test_endpoint(
        "Get Current User",
        "GET",
        f"{BASE_URL}/users/me/",
        headers=headers,
        expected_status=200
    )
    
    # 4. Switch Role
    test_endpoint(
        "Switch Role",
        "POST",
        f"{BASE_URL}/users/switch_role/",
        headers=headers,
        expected_status=200
    )
    
    print("\n🅿️  Parking Management:")
    
    # 5. Create Parking Spot
    spot_data = {
        "address": "123 Test St, Delhi",
        "latitude": "28.6139",
        "longitude": "77.2090",
        "spot_type": "private_driveway",
        "price_per_hour": "50.00",
        "has_cctv": True,
        "is_24_hours": True
    }
    spot_response = test_endpoint(
        "Create Parking Spot",
        "POST",
        f"{BASE_URL}/parking-spots/",
        data=spot_data,
        headers=headers,
        expected_status=201
    )
    
    # 6. List Parking Spots
    test_endpoint(
        "List Parking Spots",
        "GET",
        f"{BASE_URL}/parking-spots/",
        headers=headers,
        expected_status=200
    )
    
    # 7. Get Nearby Spots
    test_endpoint(
        "Get Nearby Spots",
        "GET",
        f"{BASE_URL}/parking-spots/nearby/?lat=28.6139&lon=77.2090&radius=5000",
        headers=headers,
        expected_status=200
    )
    
    print("\n🏢 Commercial Facilities:")
    
    # 8. Create Commercial Facility
    facility_data = {
        "name": "Test Mall Parking",
        "address": "456 Mall Rd, Delhi",
        "latitude": "28.5285",
        "longitude": "77.2182",
        "facility_type": "mall",
        "default_hourly_rate": "80.00",
        "has_cctv": True,
        "is_24_hours": True
    }
    facility_response = test_endpoint(
        "Create Commercial Facility",
        "POST",
        f"{BASE_URL}/commercial-facilities/",
        data=facility_data,
        headers=headers,
        expected_status=201
    )
    
    # 9. List Commercial Facilities
    test_endpoint(
        "List Commercial Facilities",
        "GET",
        f"{BASE_URL}/commercial-facilities/",
        headers=headers,
        expected_status=200
    )
    
    print("\n🏠 Private Listings:")
    
    # 10. Create Private Listing
    listing_data = {
        "title": "Test Driveway",
        "address": "789 Home St, Delhi",
        "latitude": "28.5494",
        "longitude": "77.2344",
        "description": "Test listing",
        "total_slots": 2,
        "hourly_rate": "40.00",
        "has_cctv": True,
        "is_24_hours": True,
        "auto_accept_bookings": True
    }
    listing_response = test_endpoint(
        "Create Private Listing",
        "POST",
        f"{BASE_URL}/private-listings/",
        data=listing_data,
        headers=headers,
        expected_status=201
    )
    
    # 11. List Private Listings
    test_endpoint(
        "List Private Listings",
        "GET",
        f"{BASE_URL}/private-listings/",
        headers=headers,
        expected_status=200
    )

print("\n" + "=" * 60)
print("✅ API Verification Complete!")
print("=" * 60)
