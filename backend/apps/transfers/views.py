from collections import defaultdict
from datetime import datetime, timedelta
from decimal import Decimal
from dateutil.relativedelta import relativedelta
from django.utils import timezone
from django.db.models import Sum
from rest_framework.decorators import api_view, permission_classes
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Transfer
from .serializers import TransferSerializer
from django.shortcuts import get_object_or_404
from .models import Account
from ..accounts.serializers import AccountSerializer
from ..categories.serializers import CategorySerializer
from django.db import transaction


class TransferPagination(PageNumberPagination):
    page_size = 10


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_list(request):
    date_param = request.query_params.get('date')
    period = request.query_params.get('period', 'day')
    transfer_type = request.query_params.get('type')

    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)

    if transfer_type == 'income':
        transfers = transfers.filter(category__category_type='income')
    elif transfer_type == 'expense':
        transfers = transfers.filter(category__category_type='expense')

    if date_param:
        try:
            date = datetime.strptime(date_param, "%Y-%m-%d")
            if period == "year":
                transfers = transfers.filter(date__year=date.year)
            elif period == "month":
                transfers = transfers.filter(date__year=date.year, date__month=date.month)
            elif period == "week":
                start_of_week = date - timedelta(days=date.weekday())
                end_of_week = start_of_week + timedelta(days=6)

                start_of_week = timezone.make_aware(start_of_week)
                end_of_week = timezone.make_aware(end_of_week)

                transfers = transfers.filter(date__range=(start_of_week, end_of_week))
            elif period == "day":
                transfers = transfers.filter(date__year=date.year, date__month=date.month, date__day=date.day)
        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=400)

    transfers = transfers.order_by('-date')

    paginator = TransferPagination()
    paginated_transfers = paginator.paginate_queryset(transfers, request)

    serializer = TransferSerializer(paginated_transfers, many=True)
    response = paginator.get_paginated_response(serializer.data)

    response.data['total_pages'] = paginator.page.paginator.num_pages
    return response


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def all_transfers(request):
    date_param = request.query_params.get('date')
    period = request.query_params.get('period', 'day')
    transfer_type = request.query_params.get('type')

    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)

    if transfer_type == 'income':
        transfers = transfers.filter(category__category_type='income')
    elif transfer_type == 'expense':
        transfers = transfers.filter(category__category_type='expense')

    if date_param:
        try:
            date = datetime.strptime(date_param, "%Y-%m-%d")

            if period == "year":
                start_year = date.year - 4
                end_year = date.year
                transfers = transfers.filter(date__year__range=(start_year, end_year))

            elif period == "month":
                start_date = date - relativedelta(months=11)
                transfers = transfers.filter(date__gte=start_date, date__lte=date)

            elif period == "week":
                start_date = date - timedelta(weeks=4)
                transfers = transfers.filter(date__gte=start_date, date__lte=date)

            elif period == "day":
                start_date = date - timedelta(days=4)
                transfers = transfers.filter(date__gte=start_date, date__lte=date)

        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=400)

    serializer = TransferSerializer(transfers, many=True)
    return Response(serializer.data, status=200)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_list_grouped_by_category(request):
    date_param = request.query_params.get('date')
    period = request.query_params.get('period', 'day')
    transfer_type = request.query_params.get('type')

    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)

    if transfer_type == 'income':
        transfers = transfers.filter(category__category_type='income')
    elif transfer_type == 'expense':
        transfers = transfers.filter(category__category_type='expense')

    if date_param:
        try:
            date = datetime.strptime(date_param, "%Y-%m-%d")
            if period == "year":
                transfers = transfers.filter(date__year=date.year)
            elif period == "month":
                transfers = transfers.filter(date__year=date.year, date__month=date.month)
            elif period == "week":
                start_of_week = date - timedelta(days=date.weekday())
                end_of_week = start_of_week + timedelta(days=6)

                start_of_week = timezone.make_aware(start_of_week)
                end_of_week = timezone.make_aware(end_of_week)

                transfers = transfers.filter(date__range=(start_of_week, end_of_week))
            elif period == "day":
                transfers = transfers.filter(date__year=date.year, date__month=date.month, date__day=date.day)
        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=400)

    grouped_transfers = defaultdict(lambda: {'total_amount': Decimal(0), 'category': None})

    for transfer in transfers:
        category = transfer.category
        if category:
            category_id = category.id
            grouped_transfers[category_id]['total_amount'] += transfer.amount
            grouped_transfers[category_id]['category'] = {
                'id': category.id,
                'name': category.category_name,
                'color': category.category_color,
                'icon': category.category_icon,
                'type': category.category_type,
            }

    result = [
        {
            'category': data['category'],
            'total_amount': float(data['total_amount'])
        }
        for data in grouped_transfers.values()
    ]

    result.sort(key=lambda x: x['category']['name'])

    return Response(result, status=200)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def calculate_profit_loss(request):
    date_param = request.query_params.get('date')
    period = request.query_params.get('period', 'day')
    transfer_type = request.query_params.get('type')

    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)

    if transfer_type == 'income':
        transfers = transfers.filter(category__category_type='income')
    elif transfer_type == 'expense':
        transfers = transfers.filter(category__category_type='expense')

    if date_param:
        try:
            date = datetime.strptime(date_param, "%Y-%m-%d")
            if period == "year":
                transfers = transfers.filter(date__year=date.year)
            elif period == "month":
                transfers = transfers.filter(date__year=date.year, date__month=date.month)
            elif period == "week":
                start_of_week = date - timedelta(days=date.weekday())
                end_of_week = start_of_week + timedelta(days=6)

                start_of_week = timezone.make_aware(start_of_week)
                end_of_week = timezone.make_aware(end_of_week)

                transfers = transfers.filter(date__range=(start_of_week, end_of_week))
            elif period == "day":
                transfers = transfers.filter(date__year=date.year, date__month=date.month, date__day=date.day)
        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=400)

    income_sum = transfers.filter(category__category_type='income').aggregate(total=Sum('amount'))['total'] or 0
    expense_sum = transfers.filter(category__category_type='expense').aggregate(total=Sum('amount'))['total'] or 0
    profit_loss = income_sum - expense_sum

    result = {
        'total_income': float(income_sum),
        'total_expense': float(expense_sum),
        'profit_loss': float(profit_loss)
    }

    return Response(result, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def transfer_detail(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_deleted=False)
    serializer = TransferSerializer(transfer)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def transfer_create(request):
    account = get_object_or_404(Account, id=request.data.get('account'), user=request.user)

    account.refresh_from_db()

    serializer = TransferSerializer(data=request.data)
    if serializer.is_valid():
        transfer = serializer.save(account=account)

        category = transfer.category
        if category and category.category_type == 'income':
            account.balance += transfer.amount
        else:
            account.balance -= transfer.amount

        try:
            account.save()
            print("Saldo konta po aktualizacji:", account.balance)
        except Exception as e:
            print("Błąd przy zapisie konta:", e)
            return Response({'error': 'Problem z zapisem konta'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response(serializer.data, status=status.HTTP_201_CREATED)

    print("Błąd walidacji danych:", serializer.errors)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def transfer_update(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user)
    account = transfer.account
    account.refresh_from_db()

    initial_amount = transfer.amount
    initial_category_type = transfer.category.category_type if transfer.category else None

    serializer = TransferSerializer(transfer, data=request.data)
    if serializer.is_valid():
        updated_transfer = serializer.save()
        new_amount = updated_transfer.amount
        new_category_type = updated_transfer.category.category_type if updated_transfer.category else None

        if initial_category_type == 'income':
            account.balance -= initial_amount
        elif initial_category_type == 'expense':
            account.balance += initial_amount

        if new_category_type == 'income':
            account.balance += new_amount
        elif new_category_type == 'expense':
            account.balance -= new_amount

        try:
            account.save()
            print("Saldo konta po aktualizacji:", account.balance)
        except Exception as e:
            print("Błąd przy zapisie konta:", e)
            return Response({'error': 'Problem z zapisem konta'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response(serializer.data, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def transfer_delete(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user)
    account = transfer.account
    account.refresh_from_db()

    if transfer.category.category_type == 'income':
        account.balance -= transfer.amount
    elif transfer.category.category_type == 'expense':
        account.balance += transfer.amount

    try:
        account.save()
        transfer.is_deleted = True
        transfer.save()
        print("Saldo konta po usunięciu transferu:", account.balance)
        return Response({'message': 'Transfer soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
    except Exception as e:
        print("Błąd przy zapisie konta:", e)
        return Response({'error': 'Problem z zapisem konta'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_category_from_transfer(request, transfer_id):
    transfer = get_object_or_404(Transfer, id=transfer_id, account__user=request.user, is_deleted=False)
    if transfer.category:
        serializer = CategorySerializer(transfer.category)
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response({'error': 'No category associated with this transfer'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_account_from_transfer(request, transfer_id):
    transfer = get_object_or_404(Transfer, id=transfer_id, account__user=request.user, is_deleted=False)
    serializer = AccountSerializer(transfer.account)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def regular_transfer_list(request):
    date_param = request.query_params.get('date')
    period = request.query_params.get('period', 'day')
    transfer_type = request.query_params.get('type')

    transfers = Transfer.objects.filter(
        account__user=request.user,
        is_regular=True,
        is_deleted=False
    )

    if transfer_type == 'income':
        transfers = transfers.filter(category__category_type='income')
    elif transfer_type == 'expense':
        transfers = transfers.filter(category__category_type='expense')

    if date_param:
        try:
            date = datetime.strptime(date_param, "%Y-%m-%d")
            if period == "year":
                transfers = transfers.filter(date__year=date.year)
            elif period == "month":
                transfers = transfers.filter(date__year=date.year, date__month=date.month)
            elif period == "week":
                start_of_week = date - timedelta(days=date.weekday())
                end_of_week = start_of_week + timedelta(days=6)

                start_of_week = timezone.make_aware(start_of_week)
                end_of_week = timezone.make_aware(end_of_week)

                transfers = transfers.filter(date__range=(start_of_week, end_of_week))
            elif period == "day":
                transfers = transfers.filter(date__year=date.year, date__month=date.month, date__day=date.day)
        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=400)

    transfers = transfers.order_by('-id')

    paginator = TransferPagination()
    paginated_transfers = paginator.paginate_queryset(transfers, request)

    serializer = TransferSerializer(paginated_transfers, many=True)
    response = paginator.get_paginated_response(serializer.data)

    response.data['total_pages'] = paginator.page.paginator.num_pages
    return response


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


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_regular_transfers(request):
    regular_transfers = Transfer.objects.filter(
        account__user=request.user,
        is_regular=True,
        is_deleted=False
    )

    created_transfers = []

    for regular_transfer in regular_transfers:
        last_transfer_date = regular_transfer.date

        while last_transfer_date <= timezone.now():
            if regular_transfer.interval == 'daily':
                next_transfer_date = last_transfer_date + timedelta(days=1)
            elif regular_transfer.interval == 'weekly':
                next_transfer_date = last_transfer_date + timedelta(weeks=1)
            elif regular_transfer.interval == 'monthly':
                next_transfer_date = last_transfer_date + timedelta(days=30)
            elif regular_transfer.interval == 'yearly':
                next_transfer_date = last_transfer_date + timedelta(days=365)
            else:
                break

            with transaction.atomic():
                new_transfer = Transfer.objects.create(
                    transfer_name=regular_transfer.transfer_name,
                    amount=regular_transfer.amount,
                    description=regular_transfer.description,
                    date=next_transfer_date,
                    account=regular_transfer.account,
                    category=regular_transfer.category,
                    is_regular=False,
                )

                if new_transfer.category and new_transfer.category.category_type == 'income':
                    new_transfer.account.balance += new_transfer.amount
                else:
                    new_transfer.account.balance -= new_transfer.amount

                new_transfer.account.save()

                created_transfers.append(new_transfer)

            last_transfer_date = next_transfer_date
            regular_transfer.date = next_transfer_date

        regular_transfer.save()

    serializer = TransferSerializer(created_transfers, many=True)
    return Response(serializer.data, status=status.HTTP_201_CREATED)
