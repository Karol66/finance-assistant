from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import Goal
from django.shortcuts import get_object_or_404

from .serializers import GoalSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def goal_list(request):
    goals = Goal.objects.filter(user=request.user, is_deleted=False)
    serializer = GoalSerializer(goals, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def goal_detail(request, pk):
    goal = get_object_or_404(Goal, pk=pk, user=request.user, is_deleted=False)
    serializer = GoalSerializer(goal)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def goal_create(request):
    print("Dane POST:", request.data)  # Wyświetlenie przesyłanych danych
    print(f"Zalogowany użytkownik: {request.user}")  # Wyświetlenie aktualnie zalogowanego użytkownika

    serializer = GoalSerializer(data=request.data)

    if serializer.is_valid():
        print("Dane są poprawne, zapisujemy...")
        serializer.save(user=request.user)  # Przypisanie zalogowanego użytkownika do celu
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    print("Błąd walidacji danych:", serializer.errors)  # Wyświetlenie błędów walidacji
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def goal_update(request, pk):
    goal = get_object_or_404(Goal, pk=pk, user=request.user)
    serializer = GoalSerializer(goal, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def goal_delete(request, pk):
    goal = get_object_or_404(Goal, pk=pk, user=request.user)
    goal.is_deleted = True
    goal.save()
    return Response({'message': 'Goal soft-deleted'}, status=status.HTTP_204_NO_CONTENT)
