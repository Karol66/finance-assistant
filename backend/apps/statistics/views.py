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
    # Konwersja na float
    przychody_uzytkownika = float(przychody_uzytkownika)
    wydatki_uzytkownika = float(wydatki_uzytkownika)

    # Standaryzacja danych wejściowych użytkownika
    dane_uzytkownika = np.array([[przychody_uzytkownika, wydatki_uzytkownika]])
    dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

    prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)
    return round(prognozowane_oszczednosci[0], 2)


@login_required
def przewidywanie_oszczednosci_view(request):
    if request.method == 'POST':
        form = MonthSelectionForm(request.POST)
        if form.is_valid():
            selected_month = form.cleaned_data['month']
            selected_year = form.cleaned_data['year']

            # Ustalamy datę wybranego miesiąca
            selected_date = pd.Timestamp(f'{selected_year}-{selected_month}-01')

            # Obliczamy datę dla 6 poprzednich miesięcy
            start_date = selected_date - DateOffset(months=6)

            # Pobieranie danych z ostatnich 6 miesięcy do prognozy
            przychody_suma = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_income',
                created_at__gte=start_date,
                created_at__lte=selected_date
            ).aggregate(total_income=models.Sum('value'))['total_income']

            wydatki_suma = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_expense',
                created_at__gte=start_date,
                created_at__lte=selected_date
            ).aggregate(total_expense=models.Sum('value'))['total_expense']

            # Konwersja przychodów i wydatków na float
            if przychody_suma is not None:
                przychody_suma = float(przychody_suma)
            if wydatki_suma is not None:
                wydatki_suma = float(wydatki_suma)

            # Obliczanie średnich z 6 miesięcy do prognozowania
            przychody_srednie = przychody_suma / 6 if przychody_suma is not None else 0
            wydatki_srednie = wydatki_suma / 6 if wydatki_suma is not None else 0

            # Pobieranie danych dla wybranego miesiąca (do wyświetlenia)
            przychody_miesiac = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_income',
                created_at__year=selected_year,
                created_at__month=selected_month
            ).aggregate(total_income=models.Sum('value'))['total_income']

            wydatki_miesiac = Statistics.objects.filter(
                account__user=request.user,
                statistic_type='monthly_expense',
                created_at__year=selected_year,
                created_at__month=selected_month
            ).aggregate(total_expense=models.Sum('value'))['total_expense']

            # Konwersja przychodów i wydatków na float
            if przychody_miesiac is not None:
                przychody_miesiac = float(przychody_miesiac)
            if wydatki_miesiac is not None:
                wydatki_miesiac = float(wydatki_miesiac)

            # Obliczanie oszczędności dla wybranego miesiąca
            prognozowane_oszczednosci_miesiac = przewiduj_oszczednosci(przychody_miesiac, wydatki_miesiac)

            # DEBUG: Wyświetlenie danych w konsoli
            print(f"Przychody wybranego miesiąca: {przychody_miesiac}, Wydatki wybranego miesiąca: {wydatki_miesiac}")
            print(f"Średnie przychody z 6 miesięcy: {przychody_srednie}, Średnie wydatki z 6 miesięcy: {wydatki_srednie}")

            # Sprawdzamy, czy mamy dane dla wybranych miesięcy
            if przychody_suma is None or wydatki_suma is None:
                return render(request, 'predict_savings.html', {
                    'message': 'Brak danych dla wybranego miesiąca.'
                })

            # Przewidujemy oszczędności na podstawie średnich z 6 miesięcy (do przyszłych miesięcy)
            prognozowane_oszczednosci_srednie = przewiduj_oszczednosci(przychody_srednie, wydatki_srednie)

            # Generowanie przyszłych miesięcy (iteracyjna predykcja)
            future_months = pd.DataFrame({
                'YearMonth': pd.date_range(f"{selected_year}-{selected_month}-01", periods=12, freq='M').to_period('M')
            })

            # Ustawiamy pierwsze wartości przychodów i wydatków na podstawie średnich z poprzednich miesięcy
            future_przychody = przychody_srednie
            future_wydatki = wydatki_srednie

            # Iteracyjne przewidywanie dla przyszłych miesięcy
            for i in range(len(future_months)):
                # Przewidywanie przyszłych przychodów i wydatków na podstawie ostatnich wartości
                dane_uzytkownika = np.array([[future_przychody, future_wydatki]])
                dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)
                prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)[0]

                # Aktualizujemy przychody i wydatki, aby zasymulować zmiany w czasie
                future_przychody += np.random.normal(0, 150)  # Większe losowe zmiany w przychodach
                future_wydatki += np.random.normal(0, 150)  # Większe losowe zmiany w wydatkach

                # Dodaj prognozowane wartości do DataFrame
                future_months.loc[i, 'Przychody'] = future_przychody
                future_months.loc[i, 'Wydatki'] = future_wydatki
                future_months.loc[i, 'Prognozowane_Oszczędności'] = prognozowane_oszczednosci

            # DEBUG: Wyświetlenie prognozowanych oszczędności
            print(f"Future Predictions:\n{future_months}")

            # Wyświetlenie przewidywań na przyszłe miesiące w szablonie
            context = {
                'przychody': przychody_miesiac,
                'wydatki': wydatki_miesiac,
                'prognozowane_oszczednosci': prognozowane_oszczednosci_miesiac,  # Wyświetlamy oszczędności dla wybranego miesiąca
                'selected_month': selected_month,
                'future_months': future_months.to_dict(orient='records')  # Konwertowanie do listy słowników dla szablonu
            }

            return render(request, 'predict_savings.html', context)
    else:
        form = MonthSelectionForm()

    return render(request, 'predict_savings.html', {'form': form})
