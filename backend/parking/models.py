from django.db import models
from django.conf import settings
import uuid


class ParkingSpot(models.Model):
    """Base model for both private and commercial parking spots"""
    SPOT_TYPE_CHOICES = [
        ('mall', 'Mall Parking'),
        ('private_driveway', 'Private Driveway'),
        ('office', 'Office'),
        ('apartment', 'Apartment'),
        ('hospital', 'Hospital'),
        ('airport', 'Airport'),
        ('stadium', 'Stadium'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='parking_spots')
    
    # Location
    address = models.TextField()
    latitude = models.DecimalField(max_digits=10, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, decimal_places=7)
    spot_type = models.CharField(max_length=20, choices=SPOT_TYPE_CHOICES)
    
    # Pricing
    price_per_hour = models.DecimalField(max_digits=8, decimal_places=2)
    daily_rate = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    monthly_rate = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    
    # Features
    has_cctv = models.BooleanField(default=False)
    is_covered = models.BooleanField(default=False)
    has_ev_charging = models.BooleanField(default=False)
    is_accessible = models.BooleanField(default=False)
    is_24_hours = models.BooleanField(default=False)
    has_insurance = models.BooleanField(default=False)
    has_valet_service = models.BooleanField(default=False)
    has_car_wash = models.BooleanField(default=False)
    has_security_guard = models.BooleanField(default=False)
    has_water_access = models.BooleanField(default=False)
    
    # Status
    is_occupied = models.BooleanField(default=False)
    is_disabled = models.BooleanField(default=False)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    review_count = models.IntegerField(default=0)
    
    # Access
    access_pin = models.CharField(max_length=10, null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'parking_spots'
        indexes = [
            models.Index(fields=['latitude', 'longitude']),
            models.Index(fields=['spot_type']),
            models.Index(fields=['is_occupied']),
        ]
    
    def __str__(self):
        return f"{self.address} - {self.get_spot_type_display()}"


class CommercialParkingFacility(models.Model):
    """Commercial parking facility with multiple slots"""
    FACILITY_TYPE_CHOICES = [
        ('mall', 'Mall'),
        ('office', 'Office'),
        ('apartment', 'Apartment'),
        ('hospital', 'Hospital'),
        ('airport', 'Airport'),
        ('stadium', 'Stadium'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='commercial_facilities')
    
    # Info
    name = models.CharField(max_length=255)
    address = models.TextField()
    latitude = models.DecimalField(max_digits=10, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, decimal_places=7)
    facility_type = models.CharField(max_length=20, choices=FACILITY_TYPE_CHOICES)
    
    # Pricing
    default_hourly_rate = models.DecimalField(max_digits=8, decimal_places=2)
    flat_day_rate = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    
    # Amenities
    has_cctv = models.BooleanField(default=False)
    has_ev_charging = models.BooleanField(default=False)
    has_valet_service = models.BooleanField(default=False)
    has_car_wash = models.BooleanField(default=False)
    is_24_hours = models.BooleanField(default=False)
    
    # Ratings
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    review_count = models.IntegerField(default=0)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'commercial_parking_facilities'
    
    def __str__(self):
        return f"{self.name} - {self.get_facility_type_display()}"
    
    @property
    def total_slots(self):
        return self.slots.count()
    
    @property
    def available_slots(self):
        return self.slots.filter(is_occupied=False, is_disabled=False).count()


class CommercialParkingSlot(models.Model):
    """Individual slot in a commercial facility"""
    SLOT_TYPE_CHOICES = [
        ('regular', 'Regular'),
        ('compact', 'Compact'),
        ('ev', 'EV Charging'),
        ('handicap', 'Handicap'),
        ('vip', 'VIP'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    facility = models.ForeignKey(CommercialParkingFacility, on_delete=models.CASCADE, related_name='slots')
    
    # Slot Info
    slot_number = models.CharField(max_length=20)
    floor = models.IntegerField()
    slot_type = models.CharField(max_length=20, choices=SLOT_TYPE_CHOICES, default='regular')
    
    # Status
    is_occupied = models.BooleanField(default=False)
    is_disabled = models.BooleanField(default=False)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'commercial_parking_slots'
        unique_together = ['facility', 'slot_number']
        indexes = [
            models.Index(fields=['facility', 'floor']),
        ]
    
    def __str__(self):
        return f"{self.facility.name} - Slot {self.slot_number}"


class PrivateParkingListing(models.Model):
    """Private parking listing from home owners"""
    DURATION_LIMIT_CHOICES = [
        ('hourly', 'Hourly Only'),
        ('daily', 'Up to 1 Day'),
        ('weekly', 'Up to 1 Week'),
        ('monthly', 'Up to 1 Month'),
        ('unlimited', 'Unlimited'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='private_listings')
    
    # Info
    title = models.CharField(max_length=255)
    address = models.TextField()
    latitude = models.DecimalField(max_digits=10, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, decimal_places=7)
    description = models.TextField()
    
    # Slots
    total_slots = models.IntegerField(default=1)
    
    # Pricing
    hourly_rate = models.DecimalField(max_digits=8, decimal_places=2, default=40.00)
    daily_rate = models.DecimalField(max_digits=8, decimal_places=2, default=300.00)
    monthly_rate = models.DecimalField(max_digits=8, decimal_places=2, default=3000.00)
    flat_full_booking_rate = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    
    # Booking settings
    auto_accept_bookings = models.BooleanField(default=False)
    instant_booking_discount = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # Amenities
    has_cctv = models.BooleanField(default=False)
    is_covered = models.BooleanField(default=False)
    has_ev_charging = models.BooleanField(default=False)
    has_security_guard = models.BooleanField(default=False)
    has_water_access = models.BooleanField(default=False)
    
    # Availability
    is_24_hours = models.BooleanField(default=False)
    available_from = models.TimeField(null=True, blank=True)
    available_to = models.TimeField(null=True, blank=True)
    
    # Rating
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    review_count = models.IntegerField(default=0)
    
    # Booking limits
    max_booking_duration = models.CharField(max_length=20, choices=DURATION_LIMIT_CHOICES, default='unlimited')
    
    # Pricing Intelligence
    suggested_hourly_rate = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'private_parking_listings'
    
    def __str__(self):
        return f"{self.title} by {self.owner.name}"
    
    @property
    def available_slots(self):
        occupied = self.slots.filter(is_occupied=True).count()
        return self.total_slots - occupied


class PrivateParkingSlot(models.Model):
    """Individual slot in a private listing"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    listing = models.ForeignKey(PrivateParkingListing, on_delete=models.CASCADE, related_name='slots')
    
    slot_number = models.IntegerField()
    is_occupied = models.BooleanField(default=False)
    is_disabled = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'private_parking_slots'
        unique_together = ['listing', 'slot_number']
    
    def __str__(self):
        return f"{self.listing.title} - Slot {self.slot_number}"

