from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BookingSessionViewSet, DisputeReportViewSet

router = DefaultRouter()
router.register('sessions', BookingSessionViewSet, basename='booking-session')
router.register('disputes', DisputeReportViewSet, basename='dispute')

urlpatterns = [
    path('', include(router.urls)),
]
