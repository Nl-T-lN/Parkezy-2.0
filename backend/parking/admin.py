from django.contrib import admin
from .models import (
    ParkingSpot, CommercialParkingFacility, CommercialParkingSlot,
    PrivateParkingListing, PrivateParkingSlot
)


@admin.register(ParkingSpot)
class ParkingSpotAdmin(admin.ModelAdmin):
    list_display = ['address', 'spot_type', 'price_per_hour', 'is_occupied', 'rating', 'owner']
    list_filter = ['spot_type', 'is_occupied', 'has_cctv', 'is_covered', 'has_ev_charging']
    search_fields = ['address', 'owner__name']
    ordering = ['-created_at']


@admin.register(CommercialParkingFacility)
class CommercialParkingFacilityAdmin(admin.ModelAdmin):
    list_display = ['name', 'facility_type', 'default_hourly_rate', 'rating', 'owner']
    list_filter = ['facility_type', 'has_cctv', 'has_ev_charging', 'has_valet_service']
    search_fields = ['name', 'address', 'owner__name']
    ordering = ['-created_at']


@admin.register(CommercialParkingSlot)
class CommercialParkingSlotAdmin(admin.ModelAdmin):
    list_display = ['slot_number', 'facility', 'floor', 'slot_type', 'is_occupied']
    list_filter = ['facility', 'floor', 'slot_type', 'is_occupied', 'is_disabled']
    search_fields = ['slot_number', 'facility__name']


@admin.register(PrivateParkingListing)
class PrivateParkingListingAdmin(admin.ModelAdmin):
    list_display = ['title', 'hourly_rate', 'total_slots', 'rating', 'owner']
    list_filter = ['auto_accept_bookings', 'has_cctv', 'is_covered', 'has_ev_charging']
    search_fields = ['title', 'address', 'owner__name']
    ordering = ['-created_at']


@admin.register(PrivateParkingSlot)
class PrivateParkingSlotAdmin(admin.ModelAdmin):
    list_display = ['listing', 'slot_number', 'is_occupied', 'is_disabled']
    list_filter = ['listing', 'is_occupied', 'is_disabled']
    search_fields = ['listing__title']

