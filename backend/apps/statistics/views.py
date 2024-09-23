from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required
from apps.statistics.models import Statistics
from .forms import StatisticsForm, MonthSelectionForm
from django.db import models
import joblib
import numpy as np
import pandas as pd
from pandas.tseries.offsets import DateOffset

# Ładowanie modelu i skalera
model = joblib.load('ai/model_regresji_liniowej.pkl')
scaler = joblib.load('ai/scaler.pkl')


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


def przewiduj_oszczednosci(przychody_uzytkownika, wydatki_uzytkownika):
    """
    Funkcja prognozująca oszczędności na podstawie przychodów i wydatków użytkownika.
    Dane są najpierw standaryzowane, a następnie używane do przewidywania oszczędności.
    """
    # Standaryzacja danych wejściowych użytkownika
    dane_uzytkownika = np.array([[przychody_uzytkownika, wydatki_uzytkownika]])
    dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

    # Prognozowanie oszczędności na podstawie danych użytkownika
    prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)

    return round(prognozowane_oszczednosci[0], 2)


@login_required
def przewidywanie_oszczednosci_view(request):
    if request.method == 'POST':
        form = MonthSelectionForm(request.POST)
        if form.is_valid():
            selected_month = form.cleaned_data['month']
            selected_year = form.cleaned_data['year']

            # Pobranie danych historycznych użytkownika
            przychody = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_income',
                created_at__year=selected_year,
                created_at__month=selected_month
            ).aggregate(total_income=models.Sum('value'))['total_income']

            wydatki = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_expense',
                created_at__year=selected_year,
                created_at__month=selected_month
            ).aggregate(total_expense=models.Sum('value'))['total_expense']

            # DEBUG: Wyświetlenie danych w konsoli
            print(f"Przychody: {przychody}, Wydatki: {wydatki}")

            # Sprawdzamy, czy mamy dane dla wybranego miesiąca
            if przychody is None or wydatki is None:
                return render(request, 'predict_savings.html', {
                    'message': 'Brak danych dla wybranego miesiąca.'
                })

            # Przewidujemy oszczędności na podstawie wybranych danych
            prognozowane_oszczednosci = przewiduj_oszczednosci(przychody, wydatki)

            # Generowanie przyszłych miesięcy
            future_months = pd.DataFrame({
                'YearMonth': pd.date_range(f"{selected_year}-{selected_month}-01", periods=12, freq='M').to_period('M')
            })

            # Zakładamy, że na początku przychody i wydatki są podobne do ostatnich
            future_months['Przychody'] = przychody
            future_months['Wydatki'] = wydatki

            # DEBUG: Wyświetlenie danych dla przyszłych miesięcy
            print(f"Future Months:\n{future_months}")

            # Standaryzacja przyszłych danych
            future_X = future_months[['Przychody', 'Wydatki']]
            future_X_scaled = scaler.transform(future_X)

            # Prognozowanie przyszłych oszczędności na podstawie wytrenowanego modelu
            future_months['Prognozowane_Oszczędności'] = model.predict(future_X_scaled)

            # DEBUG: Wyświetlenie prognozowanych oszczędności
            print(f"Future Predictions:\n{future_months}")

            # Wyświetlenie przewidywań na przyszłe miesiące w szablonie
            context = {
                'przychody': przychody,
                'wydatki': wydatki,
                'prognozowane_oszczednosci': prognozowane_oszczednosci,
                'selected_month': selected_month,
                'future_months': future_months.to_dict(orient='records')  # Konwertowanie do listy słowników dla szablonu
            }

            return render(request, 'predict_savings.html', context)
    else:
        form = MonthSelectionForm()

    return render(request, 'predict_savings.html', {'form': form})