from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Account
from .serializers import AccountSerializer
from django.shortcuts import get_object_or_404


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def account_list(request):
    accounts = Account.objects.filter(user=request.user, is_deleted=False)
    serializer = AccountSerializer(accounts, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def account_detail(request, pk):
    print(f"Użytkownik: {request.user}, Konto ID: {pk}")
    account = get_object_or_404(Account, pk=pk, user=request.user, is_deleted=False)
    serializer = AccountSerializer(account)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def account_create(request):
    print("Dane POST:", request.data)

    serializer = AccountSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def account_update(request, pk):
    account = get_object_or_404(Account, pk=pk, user=request.user)
    serializer = AccountSerializer(account, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def account_delete(request, pk):
    account = get_object_or_404(Account, pk=pk, user=request.user)
    account.is_deleted = True
    account.save()
    return Response({'message': 'Account soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
