from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Goal
from django.shortcuts import get_object_or_404

from .serializers import GoalSerializer

from rest_framework.pagination import PageNumberPagination


class GoalPagination(PageNumberPagination):
    page_size = 5


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def goal_list(request):
    status = request.query_params.get('status', None)

    if status not in ['active', 'completed']:
        return Response({"error": "Invalid status parameter"}, status=400)

    if status == "active":
        goals = Goal.objects.filter(user=request.user, is_deleted=False, status="active").order_by('-priority', '-id')
    else:
        goals = Goal.objects.filter(user=request.user, is_deleted=False, status="completed").order_by('-priority', '-id')

    paginator = GoalPagination()
    paginated_goals = paginator.paginate_queryset(goals, request)

    serializer = GoalSerializer(paginated_goals, many=True)
    response = paginator.get_paginated_response(serializer.data)

    response.data['total_pages'] = paginator.page.paginator.num_pages
    return response



@api_view(['GET'])
@permission_classes([IsAuthenticated])
def goal_detail(request, pk):
    goal = get_object_or_404(Goal, pk=pk, user=request.user, is_deleted=False)
    serializer = GoalSerializer(goal)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def goal_create(request):
    serializer = GoalSerializer(data=request.data)
    if serializer.is_valid():
        goal = serializer.save(user=request.user)
        if goal.current_amount == goal.target_amount:
            goal.status = "completed"
            goal.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def goal_update(request, pk):
    goal = get_object_or_404(Goal, pk=pk, user=request.user)
    serializer = GoalSerializer(goal, data=request.data)
    if serializer.is_valid():
        goal = serializer.save()
        if goal.current_amount == goal.target_amount:
            goal.status = "completed"
            goal.save()
        elif goal.current_amount < goal.target_amount and goal.status == "completed":
            goal.status = "active"
            goal.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def goal_delete(request, pk):
    goal = get_object_or_404(Goal, pk=pk, user=request.user)
    goal.is_deleted = True
    goal.save()
    return Response({'message': 'Goal soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
