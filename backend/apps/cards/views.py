from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Card
from django.shortcuts import get_object_or_404

from .serializers import CardSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def card_list(request):
    cards = Card.objects.filter(user=request.user, is_deleted=False)
    serializer = CardSerializer(cards, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def card_detail(request, pk):
    card = get_object_or_404(Card, pk=pk, user=request.user, is_deleted=False)
    serializer = CardSerializer(card)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def card_create(request):
    print("Dane POST:", request.data)  # Wyświetlenie przesyłanych danych
    print(f"Zalogowany użytkownik: {request.user}")  # Wyświetlenie aktualnie zalogowanego użytkownika

    serializer = CardSerializer(data=request.data)

    if serializer.is_valid():
        print("Dane są poprawne, zapisujemy...")
        # Sprawdzamy, czy użytkownik jest poprawnie przypisany
        serializer.save(user=request.user)  # Przypisanie zalogowanego użytkownika do kategorii
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    print("Błąd walidacji danych:", serializer.errors)  # Wyświetlenie błędów walidacji
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def card_update(request, pk):
    card = get_object_or_404(Card, pk=pk, user=request.user)
    serializer = CardSerializer(card, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def card_delete(request, pk):
    card = get_object_or_404(Card, pk=pk, user=request.user)
    card.is_deleted = True
    card.save()
    return Response({'message': 'Card soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
