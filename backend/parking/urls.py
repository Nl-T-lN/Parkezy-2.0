from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ParkingSpotViewSet, CommercialParkingFacilityViewSet,
    CommercialParkingSlotViewSet, PrivateParkingListingViewSet
)

router = DefaultRouter()
router.register('spots', ParkingSpotViewSet, basename='parking-spot')
router.register('commercial-facilities', CommercialParkingFacilityViewSet, basename='commercial-facility')
router.register('commercial-slots', CommercialParkingSlotViewSet, basename='commercial-slot')
router.register('private-listings', PrivateParkingListingViewSet, basename='private-listing')

urlpatterns = [
    path('', include(router.urls)),
]
