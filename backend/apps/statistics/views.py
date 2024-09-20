from django.shortcuts import redirect
from .forms import StatisticsForm
from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from apps.statistics.models import Statistics
from .forms import MonthSelectionForm
from django.db import models
import joblib
import numpy as np


@login_required
def create_statistics(request):
    if request.method == 'POST':
        form = StatisticsForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('statistics_list')  # Przekierowanie po zapisaniu danych
    else:
        form = StatisticsForm()
    return render(request, 'statistics_form.html', {'form': form})


@login_required
def statistics_list(request):
    # Pobieramy dane dla wszystkich kont użytkownika
    statistics = Statistics.objects.filter(account__user=request.user)
    return render(request, 'statistics_list.html', {'statistics': statistics})

# Ładowanie modelu i skalera
model = joblib.load('ai/model_regresji_liniowej.pkl')
scaler = joblib.load('ai/scaler.pkl')


def przewiduj_oszczednosci(przychody_uzytkownika, wydatki_uzytkownika):
    # Standaryzacja danych wejściowych użytkownika
    dane_uzytkownika = np.array([[przychody_uzytkownika, wydatki_uzytkownika]])
    dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

    # Prognozowanie oszczędności na podstawie danych użytkownika
    prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)

    return prognozowane_oszczednosci[0]


@login_required
def przewidywanie_oszczednosci_view(request):
    if request.method == 'POST':
        form = MonthSelectionForm(request.POST)
        if form.is_valid():
            selected_month = form.cleaned_data['month']

            # Pobieramy dane historyczne użytkownika z wybranego miesiąca
            przychody = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_income',
                created_at__year=selected_month.year,
                created_at__month=selected_month.month
            ).aggregate(total_income=models.Sum('value'))['total_income']

            wydatki = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_expense',
                created_at__year=selected_month.year,
                created_at__month=selected_month.month
            ).aggregate(total_expense=models.Sum('value'))['total_expense']

            # Sprawdzamy, czy mamy dane dla wybranego miesiąca
            if not przychody or not wydatki:
                return render(request, 'predict_savings.html', {
                    'message': 'Brak danych dla wybranego miesiąca.'
                })

            # Przewidujemy oszczędności na podstawie wybranych danych
            prognozowane_oszczednosci = przewiduj_oszczednosci(przychody, wydatki)

            context = {
                'przychody': przychody,
                'wydatki': wydatki,
                'prognozowane_oszczednosci': prognozowane_oszczednosci,
                'selected_month': selected_month
            }

            return render(request, 'predict_savings.html', context)
    else:
        form = MonthSelectionForm()

    return render(request, 'predict_savings.html', {'form': form})