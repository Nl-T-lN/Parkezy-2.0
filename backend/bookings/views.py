from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from .models import BookingSession, DisputeReport
from .serializers import (
    BookingSessionSerializer, BookingSessionCreateSerializer, BookingSessionUpdateSerializer,
    DisputeReportSerializer, DisputeReportCreateSerializer
)


class BookingSessionViewSet(viewsets.ModelViewSet):
    queryset = BookingSession.objects.all()
    serializer_class = BookingSessionSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'spot_id', 'spot_type']
    ordering_fields = ['booking_time', 'scheduled_start_time', 'scheduled_end_time']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return BookingSessionCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return BookingSessionUpdateSerializer
        return BookingSessionSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        user = self.request.user
        
        # Non-staff users can only see their own bookings
        if not user.is_staff:
            queryset = queryset.filter(user=user)
        
        # Filter by host's spots
        host_spots = self.request.query_params.get('host_spots')
        if host_spots == 'true' and user.is_host:
            # Get bookings for spots owned by this host
            from parking.models import ParkingSpot, CommercialParkingFacility, PrivateParkingListing
            owned_spot_ids = list(ParkingSpot.objects.filter(owner=user).values_list('id', flat=True))
            owned_facility_slot_ids = []
            for facility in CommercialParkingFacility.objects.filter(owner=user):
                owned_facility_slot_ids.extend(facility.slots.values_list('id', flat=True))
            owned_listing_slot_ids = []
            for listing in PrivateParkingListing.objects.filter(owner=user):
                owned_listing_slot_ids.extend(listing.slots.values_list('id', flat=True))
            
            all_owned_ids = owned_spot_ids + owned_facility_slot_ids + owned_listing_slot_ids
            queryset = queryset.filter(spot_id__in=all_owned_ids)
        
        return queryset
    
    @action(detail=False, methods=['get'])
    def active(self, request):
        """Get active bookings for current user"""
        bookings = self.get_queryset().filter(
            status='active',
            actual_end_time__isnull=True
        )
        serializer = BookingSessionSerializer(bookings, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def history(self, request):
        """Get booking history for current user"""
        bookings = self.get_queryset().filter(
            status__in=['completed', 'cancelled']
        ).order_by('-booking_time')
        serializer = BookingSessionSerializer(bookings, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def start(self, request, pk=None):
        """Start a booking session"""
        booking = self.get_object()
        
        if booking.status != 'confirmed':
            return Response({
                'error': 'Only confirmed bookings can be started'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        booking.actual_start_time = timezone.now()
        booking.status = 'active'
        booking.save()
        
        serializer = BookingSessionSerializer(booking)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def end(self, request, pk=None):
        """End a booking session"""
        booking = self.get_object()
        
        if booking.status != 'active':
            return Response({
                'error': 'Only active bookings can be ended'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        booking.actual_end_time = timezone.now()
        booking.status = 'completed'
        
        # Calculate overstay fee if applicable
        if booking.actual_end_time > booking.scheduled_end_time:
            overstay_duration = (booking.actual_end_time - booking.scheduled_end_time).total_seconds() / 60
            overstay_fee = (overstay_duration // 15) * 20  # ₹20 per 15 minutes
            booking.overstay_fee = overstay_fee
            booking.total_cost += overstay_fee
        
        booking.save()
        
        serializer = BookingSessionSerializer(booking)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Cancel a booking"""
        booking = self.get_object()
        
        if booking.status in ['completed', 'cancelled']:
            return Response({
                'error': 'Cannot cancel completed or already cancelled bookings'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        booking.status = 'cancelled'
        booking.save()
        
        serializer = BookingSessionSerializer(booking)
        return Response(serializer.data)


class DisputeReportViewSet(viewsets.ModelViewSet):
    queryset = DisputeReport.objects.all()
    serializer_class = DisputeReportSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'booking']
    ordering_fields = ['created_at']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return DisputeReportCreateSerializer
        return DisputeReportSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        user = self.request.user
        
        # Non-staff users can only see disputes for their bookings
        if not user.is_staff:
            queryset = queryset.filter(booking__user=user)
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        """Resolve a dispute (admin only)"""
        if not request.user.is_staff:
            return Response({
                'error': 'Only staff can resolve disputes'
            }, status=status.HTTP_403_FORBIDDEN)
        
        dispute = self.get_object()
        resolution = request.data.get('resolution')
        
        if not resolution:
            return Response({
                'error': 'Resolution text required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        dispute.status = 'resolved'
        dispute.resolution = resolution
        dispute.resolved_at = timezone.now()
        dispute.save()
        
        serializer = DisputeReportSerializer(dispute)
        return Response(serializer.data)

