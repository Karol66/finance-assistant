from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Transfer
from .serializers import TransferSerializer
from django.shortcuts import get_object_or_404

from .models import Account
from ..accounts.serializers import AccountSerializer
from ..categories.serializers import CategorySerializer


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
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_deleted=False)
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
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user)
    serializer = TransferSerializer(transfer, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def transfer_delete(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user)
    transfer.is_deleted = True
    transfer.save()
    return Response({'message': 'Transfer soft-deleted'}, status=status.HTTP_204_NO_CONTENT)


# Endpoint do pobierania kategorii powiązanej z danym transferem
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_category_from_transfer(request, transfer_id):
    transfer = get_object_or_404(Transfer, id=transfer_id, account__user=request.user, is_deleted=False)
    if transfer.category:
        serializer = CategorySerializer(transfer.category)
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response({'error': 'No category associated with this transfer'}, status=status.HTTP_404_NOT_FOUND)


# Endpoint do pobierania konta powiązanego z danym transferem
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_account_from_transfer(request, transfer_id):
    transfer = get_object_or_404(Transfer, id=transfer_id, account__user=request.user, is_deleted=False)
    serializer = AccountSerializer(transfer.account)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def regular_transfer_list(request):
    transfers = Transfer.objects.filter(account__user=request.user, is_regular=True, is_deleted=False)
    serializer = TransferSerializer(transfers, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def regular_transfer_detail(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_regular=True, is_deleted=False)
    serializer = TransferSerializer(transfer)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def regular_transfer_create(request):
    account = get_object_or_404(Account, id=request.data.get('account'), user=request.user)
    serializer = TransferSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(account=account, is_regular=True, interval=request.data.get('interval'))
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def regular_transfer_update(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_regular=True)
    serializer = TransferSerializer(transfer, data=request.data)
    if serializer.is_valid():
        serializer.save(interval=request.data.get('interval'))
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def regular_transfer_delete(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_regular=True)
    transfer.is_deleted = True
    transfer.save()
    return Response({'message': 'Regular transfer soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
