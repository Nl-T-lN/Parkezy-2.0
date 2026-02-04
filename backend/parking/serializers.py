from rest_framework import serializers
from .models import (
    ParkingSpot, CommercialParkingFacility, CommercialParkingSlot,
    PrivateParkingListing, PrivateParkingSlot
)


class ParkingSpotSerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='owner.name', read_only=True)
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True, required=False)
    
    class Meta:
        model = ParkingSpot
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at', 'rating', 'review_count']


class ParkingSpotListSerializer(serializers.ModelSerializer):
    """Simplified serializer for list view"""
    owner_name = serializers.CharField(source='owner.name', read_only=True)
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True, required=False)
    
    class Meta:
        model = ParkingSpot
        fields = [
            'id', 'address', 'latitude', 'longitude', 'spot_type',
            'price_per_hour', 'has_cctv', 'is_covered', 'has_ev_charging',
            'is_accessible', 'is_24_hours', 'has_insurance', 'is_occupied',
            'rating', 'review_count', 'owner_name', 'distance'
        ]


class CommercialParkingSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = CommercialParkingSlot
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']


class CommercialParkingFacilitySerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='owner.name', read_only=True)
    slots = CommercialParkingSlotSerializer(many=True, read_only=True)
    total_slots = serializers.IntegerField(read_only=True)
    available_slots = serializers.IntegerField(read_only=True)
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True, required=False)
    
    class Meta:
        model = CommercialParkingFacility
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at', 'rating', 'review_count']


class CommercialParkingFacilityListSerializer(serializers.ModelSerializer):
    """Simplified serializer for list view"""
    owner_name = serializers.CharField(source='owner.name', read_only=True)
    total_slots = serializers.IntegerField(read_only=True)
    available_slots = serializers.IntegerField(read_only=True)
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True, required=False)
    
    class Meta:
        model = CommercialParkingFacility
        fields = [
            'id', 'name', 'address', 'latitude', 'longitude', 'facility_type',
            'default_hourly_rate', 'has_cctv', 'has_ev_charging', 'has_valet_service',
            'is_24_hours', 'rating', 'review_count', 'owner_name', 'total_slots',
            'available_slots', 'distance'
        ]


class PrivateParkingSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrivateParkingSlot
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']


class PrivateParkingListingSerializer(serializers.ModelSerializer):
    owner_name = serializers.CharField(source='owner.name', read_only=True)
    slots = PrivateParkingSlotSerializer(many=True, read_only=True)
    available_slots = serializers.IntegerField(read_only=True)
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True, required=False)
    
    class Meta:
        model = PrivateParkingListing
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at', 'rating', 'review_count']


class PrivateParkingListingListSerializer(serializers.ModelSerializer):
    """Simplified serializer for list view"""
    owner_name = serializers.CharField(source='owner.name', read_only=True)
    available_slots = serializers.IntegerField(read_only=True)
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True, required=False)
    
    class Meta:
        model = PrivateParkingListing
        fields = [
            'id', 'title', 'address', 'latitude', 'longitude', 'hourly_rate',
            'daily_rate', 'monthly_rate', 'has_cctv', 'is_covered', 'has_ev_charging',
            'is_24_hours', 'rating', 'review_count', 'owner_name', 'total_slots',
            'available_slots', 'distance'
        ]
