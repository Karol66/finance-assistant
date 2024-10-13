from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Notification
from django.shortcuts import get_object_or_404

from .serializers import NotificationSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notification_list(request):
    notifications = Notification.objects.filter(user=request.user, is_deleted=False)
    serializer = NotificationSerializer(notifications, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def notification_detail(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user, is_deleted=False)
    serializer = NotificationSerializer(notification)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def notification_create(request):
    print("Dane POST:", request.data)  # Wyświetlenie przesyłanych danych
    print(f"Zalogowany użytkownik: {request.user}")  # Wyświetlenie aktualnie zalogowanego użytkownika

    serializer = NotificationSerializer(data=request.data)

    if serializer.is_valid():
        print("Dane są poprawne, zapisujemy...")
        # Sprawdzamy, czy użytkownik jest poprawnie przypisany
        serializer.save(user=request.user)  # Przypisanie zalogowanego użytkownika do kategorii
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    print("Błąd walidacji danych:", serializer.errors)  # Wyświetlenie błędów walidacji
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def notification_update(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user)
    serializer = NotificationSerializer(notification, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def notification_delete(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user)
    notification.is_deleted = True
    notification.save()
    return Response({'message': 'Notification soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
