#!/usr/bin/env python3
"""
Test script for Parkezy Backend API
Run after starting the server: python manage.py runserver
"""

import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:8000/api"

def print_response(response):
    """Pretty print response"""
    print(f"\nStatus: {response.status_code}")
    try:
        print(json.dumps(response.json(), indent=2))
    except:
        print(response.text)
    print("-" * 80)

def test_user_registration():
    """Test user registration"""
    print("\n=== Testing User Registration ===")
    
    data = {
        "email": f"driver{datetime.now().timestamp()}@test.com",
        "name": "Test Driver",
        "phone_number": "+1234567890",
        "password": "testpass123",
        "password_confirm": "testpass123",
        "is_host": False
    }
    
    response = requests.post(f"{BASE_URL}/users/register/", json=data)
    print_response(response)
    
    if response.status_code == 201:
        return response.json()
    return None

def test_user_login():
    """Test user login"""
    print("\n=== Testing User Login ===")
    
    # First register a user
    timestamp = datetime.now().timestamp()
    register_data = {
        "email": f"logintest{timestamp}@test.com",
        "name": "Login Test",
        "phone_number": "+0987654321",
        "password": "testpass123",
        "password_confirm": "testpass123",
        "is_host": False
    }
    
    register_response = requests.post(f"{BASE_URL}/users/register/", json=register_data)
    print(f"Registration: {register_response.status_code}")
    
    # Now login
    login_data = {
        "email": f"logintest{timestamp}@test.com",
        "password": "testpass123"
    }
    
    response = requests.post(f"{BASE_URL}/users/login/", json=login_data)
    print_response(response)
    
    if response.status_code == 200:
        return response.json()
    return None

def test_parking_spots(token):
    """Test parking spots endpoints"""
    print("\n=== Testing Parking Spots ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Create a parking spot
    print("\n1. Creating Parking Spot")
    spot_data = {
        "address": "123 Test Street, Delhi",
        "latitude": "28.6139",
        "longitude": "77.2090",
        "spot_type": "private_driveway",
        "price_per_hour": "50.00",
        "daily_rate": "400.00",
        "has_cctv": True,
        "is_covered": True,
        "has_ev_charging": False,
        "is_24_hours": True,
        "access_pin": "123456"
    }
    
    response = requests.post(f"{BASE_URL}/parking-spots/", json=spot_data, headers=headers)
    print_response(response)
    
    spot_id = None
    if response.status_code == 201:
        spot_id = response.json()['id']
    
    # List parking spots
    print("\n2. Listing Parking Spots")
    response = requests.get(f"{BASE_URL}/parking-spots/", headers=headers)
    print_response(response)
    
    # Get nearby spots
    print("\n3. Getting Nearby Spots")
    params = {
        "lat": "28.6139",
        "lon": "77.2090",
        "radius": "5000"
    }
    response = requests.get(f"{BASE_URL}/parking-spots/nearby/", params=params, headers=headers)
    print_response(response)
    
    return spot_id

def test_commercial_facilities(token):
    """Test commercial facilities endpoints"""
    print("\n=== Testing Commercial Facilities ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Create a facility
    print("\n1. Creating Commercial Facility")
    facility_data = {
        "name": "Test Mall Parking",
        "address": "456 Mall Road, Delhi",
        "latitude": "28.5285",
        "longitude": "77.2182",
        "facility_type": "mall",
        "default_hourly_rate": "80.00",
        "flat_day_rate": "500.00",
        "has_cctv": True,
        "has_ev_charging": True,
        "is_24_hours": True
    }
    
    response = requests.post(f"{BASE_URL}/commercial-facilities/", json=facility_data, headers=headers)
    print_response(response)
    
    facility_id = None
    if response.status_code == 201:
        facility_id = response.json()['id']
        
        # Create slots for the facility
        print("\n2. Creating Slots for Facility")
        slots_data = {
            "count": 10,
            "floor": 1,
            "slot_type": "regular"
        }
        response = requests.post(
            f"{BASE_URL}/commercial-facilities/{facility_id}/create_slots/",
            json=slots_data,
            headers=headers
        )
        print_response(response)
    
    # List facilities
    print("\n3. Listing Commercial Facilities")
    response = requests.get(f"{BASE_URL}/commercial-facilities/", headers=headers)
    print_response(response)
    
    return facility_id

def test_private_listings(token):
    """Test private listings endpoints"""
    print("\n=== Testing Private Listings ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Create a listing
    print("\n1. Creating Private Listing")
    listing_data = {
        "title": "Test Driveway",
        "address": "789 Home Street, Delhi",
        "latitude": "28.5494",
        "longitude": "77.2344",
        "description": "Nice and secure parking",
        "total_slots": 2,
        "hourly_rate": "40.00",
        "daily_rate": "300.00",
        "monthly_rate": "3000.00",
        "has_cctv": True,
        "is_covered": False,
        "has_ev_charging": False,
        "auto_accept_bookings": True,
        "is_24_hours": True
    }
    
    response = requests.post(f"{BASE_URL}/private-listings/", json=listing_data, headers=headers)
    print_response(response)
    
    listing_id = None
    if response.status_code == 201:
        listing_id = response.json()['id']
        
        # Get pricing intelligence
        print("\n2. Getting Pricing Intelligence")
        response = requests.post(
            f"{BASE_URL}/private-listings/{listing_id}/pricing_intelligence/",
            headers=headers
        )
        print_response(response)
    
    # List listings
    print("\n3. Listing Private Listings")
    response = requests.get(f"{BASE_URL}/private-listings/", headers=headers)
    print_response(response)
    
    return listing_id

def test_bookings(token, spot_id):
    """Test booking endpoints"""
    print("\n=== Testing Bookings ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    if not spot_id:
        print("No spot ID available, skipping booking tests")
        return None
    
    # Create a booking
    print("\n1. Creating Booking")
    now = datetime.now()
    start_time = now + timedelta(minutes=5)
    end_time = start_time + timedelta(hours=2)
    
    booking_data = {
        "spot_id": spot_id,
        "spot_type": "parking_spot",
        "scheduled_start_time": start_time.isoformat(),
        "scheduled_end_time": end_time.isoformat(),
        "duration": 2.0,
        "total_cost": "118.00",
        "access_code": "123456"
    }
    
    response = requests.post(f"{BASE_URL}/bookings/", json=booking_data, headers=headers)
    print_response(response)
    
    booking_id = None
    if response.status_code == 201:
        booking_id = response.json()['id']
        
        # Start the booking
        print("\n2. Starting Booking")
        response = requests.post(f"{BASE_URL}/bookings/{booking_id}/start/", headers=headers)
        print_response(response)
        
        # Get active bookings
        print("\n3. Getting Active Bookings")
        response = requests.get(f"{BASE_URL}/bookings/active/", headers=headers)
        print_response(response)
    
    # List all bookings
    print("\n4. Listing All Bookings")
    response = requests.get(f"{BASE_URL}/bookings/", headers=headers)
    print_response(response)
    
    return booking_id

def test_user_profile(token):
    """Test user profile endpoints"""
    print("\n=== Testing User Profile ===")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Get current user
    print("\n1. Getting Current User")
    response = requests.get(f"{BASE_URL}/users/me/", headers=headers)
    print_response(response)
    
    # Update profile
    print("\n2. Updating Profile")
    update_data = {
        "name": "Updated Test User"
    }
    response = requests.patch(f"{BASE_URL}/users/update_profile/", json=update_data, headers=headers)
    print_response(response)
    
    # Get user stats
    print("\n3. Getting User Stats")
    response = requests.get(f"{BASE_URL}/users/stats/", headers=headers)
    print_response(response)
    
    # Switch role
    print("\n4. Switching Role")
    response = requests.post(f"{BASE_URL}/users/switch_role/", headers=headers)
    print_response(response)

def main():
    """Run all tests"""
    print("=" * 80)
    print("PARKEZY BACKEND API TEST SUITE")
    print("=" * 80)
    
    # Test registration and login
    login_result = test_user_login()
    
    if not login_result:
        print("\n❌ Login failed, cannot continue with tests")
        return
    
    token = login_result['tokens']['access']
    print(f"\n✓ Got access token: {token[:20]}...")
    
    # Test user profile
    test_user_profile(token)
    
    # Test parking spots
    spot_id = test_parking_spots(token)
    
    # Test commercial facilities
    facility_id = test_commercial_facilities(token)
    
    # Test private listings
    listing_id = test_private_listings(token)
    
    # Test bookings
    booking_id = test_bookings(token, spot_id)
    
    print("\n" + "=" * 80)
    print("✓ TEST SUITE COMPLETED")
    print("=" * 80)

if __name__ == "__main__":
    main()
