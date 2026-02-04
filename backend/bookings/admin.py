from django.contrib import admin
from .models import BookingSession, DisputeReport


@admin.register(BookingSession)
class BookingSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'spot_type', 'status', 'scheduled_start_time', 'total_cost']
    list_filter = ['status', 'spot_type', 'booking_time']
    search_fields = ['user__email', 'user__name', 'spot_id']
    ordering = ['-booking_time']
    readonly_fields = ['booking_time', 'created_at', 'updated_at']


@admin.register(DisputeReport)
class DisputeReportAdmin(admin.ModelAdmin):
    list_display = ['id', 'booking', 'reason', 'status', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['booking__user__email', 'reason', 'description']
    ordering = ['-created_at']
    readonly_fields = ['created_at']

