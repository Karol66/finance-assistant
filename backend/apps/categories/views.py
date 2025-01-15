from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Category
from django.shortcuts import get_object_or_404

from .serializers import CategorySerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def category_list(request):
    categories = Category.objects.filter(user=request.user, is_deleted=False)
    serializer = CategorySerializer(categories, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def category_detail(request, pk):
    category = get_object_or_404(Category, pk=pk, user=request.user, is_deleted=False)
    serializer = CategorySerializer(category)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def category_create(request):
    serializer = CategorySerializer(data=request.data)
    if serializer.is_valid(raise_exception=True):
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def category_update(request, pk):
    category = get_object_or_404(Category, pk=pk, user=request.user)
    serializer = CategorySerializer(category, data=request.data, partial=True)
    if serializer.is_valid(raise_exception=True):
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def category_delete(request, pk):
    category = get_object_or_404(Category, pk=pk, user=request.user)
    category.is_deleted = True
    category.save()
    return Response({'message': 'Category soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
