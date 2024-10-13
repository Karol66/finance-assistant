from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import Transfer, Account
from .serializers import TransferSerializer
from apps.statistics.models import Statistics


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_list(request):
    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)
    serializer = TransferSerializer(transfers, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_detail(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_deleted=False)
    serializer = TransferSerializer(transfer)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def transfer_create(request):
    serializer = TransferSerializer(data=request.data)
    if serializer.is_valid():
        transfer = serializer.save(commit=False)
        transfer.user = request.user
        account = transfer.account

        if transfer.category.category_type == 'income':
            account.balance += transfer.amount
            statistic_type = 'monthly_income'
        else:
            account.balance -= transfer.amount
            statistic_type = 'monthly_expense'

        account.save()
        transfer.save()

        # Dodajemy statystyki
        Statistics.objects.create(
            account=account,
            statistic_type=statistic_type,
            value=transfer.amount
        )

        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def transfer_update(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_deleted=False)
    old_amount = transfer.amount  # Zapisujemy starą kwotę
    serializer = TransferSerializer(transfer, data=request.data)

    if serializer.is_valid():
        updated_transfer = serializer.save(commit=False)
        account = updated_transfer.account
        account.balance += old_amount  # Przywracamy starą kwotę
        account.balance -= updated_transfer.amount  # Odejmujemy nową kwotę
        account.save()
        updated_transfer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def transfer_delete(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user)
    account = transfer.account
    account.balance += transfer.amount  # Przywracamy kwotę przelewu do salda
    account.save()

    transfer.is_deleted = True
    transfer.save()
    return Response({'message': 'Transfer soft-deleted'}, status=status.HTTP_204_NO_CONTENT)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def account_transfer(request):
    data = request.data
    recipient_account_number = data.get('recipient_account_number')
    amount = data.get('amount')

    # Pobieramy źródłowe konto użytkownika
    source_account = Account.objects.get(user=request.user, is_deleted=False)

    # Znajdujemy konto odbiorcy
    try:
        recipient_account = Account.objects.get(account_number=recipient_account_number, is_deleted=False)
    except Account.DoesNotExist:
        return Response({'error': 'Recipient account not found'}, status=status.HTTP_404_NOT_FOUND)

    # Zmniejszamy saldo konta źródłowego
    if source_account.balance < amount:
        return Response({'error': 'Insufficient balance'}, status=status.HTTP_400_BAD_REQUEST)

    source_account.balance -= amount
    source_account.save()

    # Zwiększamy saldo konta odbiorcy
    recipient_account.balance += amount
    recipient_account.save()

    # Zapisujemy przelew
    transfer = Transfer.objects.create(
        account=source_account,
        recipient_account=recipient_account,
        amount=amount,
        user=request.user,
        category=None  # W zależności od modelu
    )

    # Statystyki dla obu kont
    Statistics.objects.create(account=source_account, statistic_type='monthly_expense', value=amount)
    Statistics.objects.create(account=recipient_account, statistic_type='monthly_income', value=amount)

    return Response({'message': 'Transfer completed'}, status=status.HTTP_201_CREATED)
