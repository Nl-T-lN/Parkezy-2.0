from django.db import models
from django.conf import settings
import uuid


class BookingSession(models.Model):
    """Booking session for parking spots"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('active', 'Active'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
        ('disputed', 'Disputed'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='bookings')
    
    # Spot reference (generic to support both private and commercial)
    spot_id = models.UUIDField()  # Can reference ParkingSpot, CommercialParkingSlot, or PrivateParkingSlot
    spot_type = models.CharField(max_length=50)  # 'parking_spot', 'commercial_slot', 'private_slot'
    
    # Timing
    booking_time = models.DateTimeField(auto_now_add=True)
    scheduled_start_time = models.DateTimeField()
    actual_start_time = models.DateTimeField(null=True, blank=True)
    scheduled_end_time = models.DateTimeField()
    actual_end_time = models.DateTimeField(null=True, blank=True)
    
    # Duration & Cost
    duration = models.DecimalField(max_digits=6, decimal_places=2)  # in hours
    total_cost = models.DecimalField(max_digits=10, decimal_places=2)
    overstay_fee = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    # Status
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    # Access
    access_code = models.CharField(max_length=10, null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'booking_sessions'
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['spot_id']),
            models.Index(fields=['scheduled_start_time', 'scheduled_end_time']),
        ]
    
    def __str__(self):
        return f"Booking {self.id} - {self.user.name} - {self.status}"


class DisputeReport(models.Model):
    """Dispute/issue report for bookings"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('under_review', 'Under Review'),
        ('resolved', 'Resolved'),
        ('rejected', 'Rejected'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking = models.ForeignKey(BookingSession, on_delete=models.CASCADE, related_name='disputes')
    
    reason = models.CharField(max_length=255)
    description = models.TextField()
    photo_urls = models.JSONField(default=list)  # Array of photo URLs
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    resolution = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'dispute_reports'
        indexes = [
            models.Index(fields=['booking']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"Dispute {self.id} - {self.reason}"

