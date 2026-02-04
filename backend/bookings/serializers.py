from rest_framework import serializers
from .models import BookingSession, DisputeReport


class BookingSessionSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.name', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    
    class Meta:
        model = BookingSession
        fields = '__all__'
        read_only_fields = ['id', 'booking_time', 'created_at', 'updated_at']


class BookingSessionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = BookingSession
        fields = [
            'spot_id', 'spot_type', 'scheduled_start_time', 'scheduled_end_time',
            'duration', 'total_cost', 'access_code'
        ]
    
    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        validated_data['status'] = 'confirmed'
        return super().create(validated_data)


class BookingSessionUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = BookingSession
        fields = [
            'actual_start_time', 'actual_end_time', 'status', 'overstay_fee', 'total_cost'
        ]


class DisputeReportSerializer(serializers.ModelSerializer):
    booking_user_name = serializers.CharField(source='booking.user.name', read_only=True)
    
    class Meta:
        model = DisputeReport
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'resolved_at']


class DisputeReportCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = DisputeReport
        fields = ['booking', 'reason', 'description', 'photo_urls']
