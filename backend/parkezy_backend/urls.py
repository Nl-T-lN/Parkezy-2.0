"""
URL configuration for parkezy_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from users.views import UserViewSet
from parking.views import (
    ParkingSpotViewSet, CommercialParkingFacilityViewSet, 
    CommercialParkingSlotViewSet, PrivateParkingListingViewSet,
    PrivateParkingSlotViewSet
)
from bookings.views import BookingSessionViewSet, DisputeReportViewSet

# Create router
router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'parking-spots', ParkingSpotViewSet, basename='parking-spot')
router.register(r'commercial-facilities', CommercialParkingFacilityViewSet, basename='commercial-facility')
router.register(r'commercial-slots', CommercialParkingSlotViewSet, basename='commercial-slot')
router.register(r'private-listings', PrivateParkingListingViewSet, basename='private-listing')
router.register(r'private-slots', PrivateParkingSlotViewSet, basename='private-slot')
router.register(r'bookings', BookingSessionViewSet, basename='booking')
router.register(r'disputes', DisputeReportViewSet, basename='dispute')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
