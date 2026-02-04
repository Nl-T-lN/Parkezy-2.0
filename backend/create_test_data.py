import os
import django
from decimal import Decimal
from django.utils import timezone
from datetime import timedelta

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'parkezy_backend.settings')
django.setup()

from users.models import User
from parking.models import (
    ParkingSpot, CommercialParkingFacility, CommercialParkingSlot,
    PrivateParkingListing, PrivateParkingSlot
)
from bookings.models import BookingSession

print("Creating test data...")

# Create test users
driver = User.objects.create_user(
    email='kartik@example.com',
    password='password123',
    name='Kartik Sharma',
    phone_number='+91 98765 12345',
    is_host=False
)
print(f"✓ Created driver: {driver.email}")

host = User.objects.create_user(
    email='rohit@parkezy.com',
    password='password123',
    name='Rohit Sharma',
    phone_number='+91 98765 43210',
    is_host=True,
    host_rating=Decimal('4.8'),
    total_bookings=456
)
print(f"✓ Created host: {host.email}")

# Create admin user
admin = User.objects.create_superuser(
    email='admin@parkezy.com',
    password='admin123',
    name='Admin User',
    phone_number='+91 99999 99999'
)
print(f"✓ Created admin: {admin.email}")

# Create parking spots
spots_data = [
    {
        'address': 'Select Citywalk, Saket',
        'latitude': Decimal('28.5285'),
        'longitude': Decimal('77.2182'),
        'spot_type': 'mall',
        'price_per_hour': Decimal('60'),
    },
    {
        'address': 'DLF Promenade, Vasant Kunj',
        'latitude': Decimal('28.5398'),
        'longitude': Decimal('77.1546'),
        'spot_type': 'mall',
        'price_per_hour': Decimal('80'),
    },
    {
        'address': 'Greater Kailash I, Block M',
        'latitude': Decimal('28.5494'),
        'longitude': Decimal('77.2344'),
        'spot_type': 'private_driveway',
        'price_per_hour': Decimal('50'),
    },
    {
        'address': 'Hauz Khas Village',
        'latitude': Decimal('28.5494'),
        'longitude': Decimal('77.1960'),
        'spot_type': 'private_driveway',
        'price_per_hour': Decimal('45'),
    },
]

for spot_data in spots_data:
    spot = ParkingSpot.objects.create(
        owner=host,
        has_cctv=True,
        is_covered=True,
        has_ev_charging=spot_data['spot_type'] == 'mall',
        is_accessible=True,
        is_24_hours=True,
        has_insurance=True,
        rating=Decimal('4.5'),
        review_count=128,
        access_pin='428915',
        **spot_data
    )
    print(f"✓ Created parking spot: {spot.address}")

# Create commercial parking facility
facility = CommercialParkingFacility.objects.create(
    owner=host,
    name='Ambience Mall Parking',
    address='Ambience Mall, Gurugram',
    latitude=Decimal('28.5040'),
    longitude=Decimal('77.0968'),
    facility_type='mall',
    default_hourly_rate=Decimal('100'),
    flat_day_rate=Decimal('500'),
    has_cctv=True,
    has_ev_charging=True,
    has_valet_service=True,
    has_car_wash=True,
    is_24_hours=True,
    rating=Decimal('4.6'),
    review_count=687
)
print(f"✓ Created commercial facility: {facility.name}")

# Create slots for facility (just a few)
for slot_num in range(1, 6):  # Just 5 slots
    slot = CommercialParkingSlot.objects.create(
        facility=facility,
        slot_number=f"A{slot_num:02d}",
        floor=1,
        slot_type='regular',
        is_occupied=False
    )
print(f"✓ Created {facility.slots.count()} slots for {facility.name}")

# Create private listing
listing = PrivateParkingListing.objects.create(
    owner=host,
    title='Spacious Driveway in GK-1',
    address='Greater Kailash I, New Delhi',
    latitude=Decimal('28.5494'),
    longitude=Decimal('77.2344'),
    description='Safe and secure private parking with CCTV coverage',
    total_slots=2,
    hourly_rate=Decimal('40'),
    daily_rate=Decimal('300'),
    monthly_rate=Decimal('3000'),
    auto_accept_bookings=True,
    has_cctv=True,
    is_covered=True,
    has_ev_charging=False,
    has_security_guard=True,
    is_24_hours=True,
    rating=Decimal('4.8'),
    review_count=95,
    max_booking_duration='daily'
)
print(f"✓ Created private listing: {listing.title}")

# Create slots for private listing
for slot_num in range(1, 3):
    PrivateParkingSlot.objects.create(
        listing=listing,
        slot_number=slot_num,
        is_occupied=False
    )
print(f"✓ Created {listing.total_slots} slots for {listing.title}")

# Create some bookings
spot = ParkingSpot.objects.first()
now = timezone.now()

# Active booking
active_booking = BookingSession.objects.create(
    user=driver,
    spot_id=spot.id,
    spot_type='parking_spot',
    scheduled_start_time=now - timedelta(hours=1),
    actual_start_time=now - timedelta(hours=1),
    scheduled_end_time=now + timedelta(hours=1),
    duration=Decimal('2.0'),
    total_cost=Decimal('118.0'),
    status='active',
    access_code='428915'
)
print(f"✓ Created active booking: {active_booking.id}")

# Completed booking
completed_booking = BookingSession.objects.create(
    user=driver,
    spot_id=spot.id,
    spot_type='parking_spot',
    scheduled_start_time=now - timedelta(days=1, hours=2),
    actual_start_time=now - timedelta(days=1, hours=2),
    scheduled_end_time=now - timedelta(days=1),
    actual_end_time=now - timedelta(days=1),
    duration=Decimal('2.0'),
    total_cost=Decimal('118.0'),
    status='completed',
    access_code='428915'
)
print(f"✓ Created completed booking: {completed_booking.id}")

print("\n✅ Test data created successfully!")
print("\nTest Accounts:")
print(f"  Driver: {driver.email} / password123")
print(f"  Host: {host.email} / password123")
print(f"  Admin: {admin.email} / admin123")
