from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .serializers import StatisticsSerializer
from .models import Statistics
import joblib
import numpy as np
import pandas as pd
from pandas.tseries.offsets import DateOffset
from django.db import models

# Ładowanie modelu i skalera
model = joblib.load('ai/model_regresji_liniowej.pkl')
scaler = joblib.load('ai/scaler.pkl')


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_statistics(request):
    serializer = StatisticsSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def statistics_list(request):
    statistics = Statistics.objects.filter(account__user=request.user)
    serializer = StatisticsSerializer(statistics, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


def przewiduj_oszczednosci(przychody_uzytkownika, wydatki_uzytkownika):
    """
    Funkcja prognozująca oszczędności na podstawie przychodów i wydatków użytkownika.
    """
    przychody_uzytkownika = float(przychody_uzytkownika)
    wydatki_uzytkownika = float(wydatki_uzytkownika)

    dane_uzytkownika = np.array([[przychody_uzytkownika, wydatki_uzytkownika]])
    dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

    prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)
    return round(prognozowane_oszczednosci[0], 2)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def przewidywanie_oszczednosci_view(request):
    selected_month = request.data.get('month')
    selected_year = request.data.get('year')

    if not selected_month or not selected_year:
        return Response({'error': 'Month and year are required.'}, status=status.HTTP_400_BAD_REQUEST)

    selected_date = pd.Timestamp(f'{selected_year}-{selected_month}-01')
    start_date = selected_date - DateOffset(months=6)

    przychody_ostatnie_6m = Statistics.objects.filter(
        account__user=request.user,
        statistic_type='monthly_income',
        created_at__gte=start_date,
        created_at__lte=selected_date
    ).order_by('created_at').values_list('value', flat=True)

    wydatki_ostatnie_6m = Statistics.objects.filter(
        account__user=request.user,
        statistic_type='monthly_expense',
        created_at__gte=start_date,
        created_at__lte=selected_date
    ).order_by('created_at').values_list('value', flat=True)

    przychody_ostatnie_6m = list(map(float, przychody_ostatnie_6m))
    wydatki_ostatnie_6m = list(map(float, wydatki_ostatnie_6m))

    if len(przychody_ostatnie_6m) < 6 or len(wydatki_ostatnie_6m) < 6:
        return Response({'error': 'Insufficient data for the last 6 months.'}, status=status.HTTP_400_BAD_REQUEST)

    przychody_miesiac = Statistics.objects.filter(
        account__user=request.user,
        statistic_type='monthly_income',
        created_at__year=selected_year,
        created_at__month=selected_month
    ).aggregate(total_income=models.Sum('value'))['total_income'] or 0

    wydatki_miesiac = Statistics.objects.filter(
        account__user=request.user,
        statistic_type='monthly_expense',
        created_at__year=selected_year,
        created_at__month=selected_month
    ).aggregate(total_expense=models.Sum('value'))['total_expense'] or 0

    prognozowane_oszczednosci_miesiac = przewiduj_oszczednosci(przychody_miesiac, wydatki_miesiac)

    future_months = pd.DataFrame({
        'YearMonth': pd.date_range(f"{selected_year}-{selected_month}-01", periods=12, freq='M').to_period('M')
    })

    history_przychody = przychody_ostatnie_6m[-6:]
    history_wydatki = wydatki_ostatnie_6m[-6:]

    for i in range(len(future_months)):
        przychody_6m = history_przychody[-6:]
        wydatki_6m = history_wydatki[-6:]

        dane_uzytkownika = np.array([[przychody_6m[-1], wydatki_6m[-1]]])
        dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

        prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)[0]

        new_przychody = przychody_6m[-1] + np.random.normal(0, 50)
        new_wydatki = max(0, wydatki_6m[-1] + np.random.normal(0, 50))

        history_przychody.append(new_przychody)
        history_wydatki.append(new_wydatki)

        future_months.loc[i, 'Przychody'] = new_przychody
        future_months.loc[i, 'Wydatki'] = new_wydatki
        future_months.loc[i, 'Prognozowane_Oszczędności'] = prognozowane_oszczednosci

    return Response({
        'przychody_miesiac': przychody_miesiac,
        'wydatki_miesiac': wydatki_miesiac,
        'prognozowane_oszczednosci': prognozowane_oszczednosci_miesiac,
        'future_months': future_months.to_dict(orient='records')
    }, status=status.HTTP_200_OK)
