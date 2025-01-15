from datetime import datetime, timedelta
from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Notification
from django.shortcuts import get_object_or_404
from .serializers import NotificationSerializer


class NotificationPagination(PageNumberPagination):
    page_size = 5


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notification_list(request):
    date_param = request.query_params.get('date')
    period = request.query_params.get('period', 'day')
    notifications = Notification.objects.filter(user=request.user, is_deleted=False)

    if date_param:
        date = datetime.strptime(date_param, '%Y-%m-%d')
        if period == 'year':
            notifications = notifications.filter(created_at__year=date.year)
        elif period == 'month':
            notifications = notifications.filter(created_at__year=date.year, created_at__month=date.month)
        elif period == 'week':
            start_of_week = date - timedelta(days=date.weekday())
            end_of_week = start_of_week + timedelta(days=6)

            start_of_week = timezone.make_aware(start_of_week)
            end_of_week = timezone.make_aware(end_of_week)

            notifications = notifications.filter(created_at__range=(start_of_week, end_of_week))
        elif period == 'day':
            notifications = notifications.filter(created_at__year=date.year, created_at__month=date.month,
                                                 created_at__day=date.day)

    notifications = notifications.order_by('-created_at')

    paginator = NotificationPagination()
    paginated_notifications = paginator.paginate_queryset(notifications, request)

    serializer = NotificationSerializer(paginated_notifications, many=True)
    response = paginator.get_paginated_response(serializer.data)

    response.data['total_pages'] = paginator.page.paginator.num_pages
    return response


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notification_detail(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user, is_deleted=False)
    serializer = NotificationSerializer(notification)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def notification_create(request):
    serializer = NotificationSerializer(data=request.data)
    if serializer.is_valid(raise_exception=True):
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def notification_update(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user)
    serializer = NotificationSerializer(notification, data=request.data, partial=True)
    if serializer.is_valid(raise_exception=True):
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def notification_delete(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user)
    notification.is_deleted = True
    notification.save()
    return Response({'message': 'Notification soft-deleted'}, status=status.HTTP_204_NO_CONTENT)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def today_notifications_count(request):
    today = timezone.now().date()
    count = Notification.objects.filter(
        user=request.user,
        is_deleted=False,
        created_at__year=today.year,
        created_at__month=today.month,
        created_at__day=today.day
    ).count()

    return Response({'count': count}, status=status.HTTP_200_OK)
