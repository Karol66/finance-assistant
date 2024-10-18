from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Transfer
from .serializers import TransferSerializer
from django.shortcuts import get_object_or_404

from .models import Account


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_list(request):
    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)
    serializer = TransferSerializer(transfers, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_detail(request, pk):
    print(f"Użytkownik: {request.user}, Transfer ID: {pk}")
    transfer = get_object_or_404(Transfer, pk=pk, user=request.user, is_deleted=False)
    serializer = TransferSerializer(transfer)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def transfer_create(request):
    print("Dane POST:", request.data)  # Wyświetlenie przesyłanych danych
    print(f"Zalogowany użytkownik: {request.user}")  # Wyświetlenie aktualnie zalogowanego użytkownika

    account = get_object_or_404(Account, id=request.data.get('account'), user=request.user)

    serializer = TransferSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(account=account)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    print("Błąd walidacji danych:", serializer.errors)  # Wyświetlenie błędów walidacji
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def transfer_update(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, user=request.user)
    serializer = TransferSerializer(transfer, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def transfer_delete(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, user=request.user)
    transfer.is_deleted = True
    transfer.save()
    return Response({'message': 'Transfer soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
