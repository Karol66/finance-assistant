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

            # Pobieranie indywidualnych danych z ostatnich 6 miesięcy
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

            # Konwersja na listy floatów, aby mieć pełne dane
            przychody_ostatnie_6m = list(map(float, przychody_ostatnie_6m))
            wydatki_ostatnie_6m = list(map(float, wydatki_ostatnie_6m))

            # Sprawdzamy, czy mamy wystarczające dane dla ostatnich 6 miesięcy
            if len(przychody_ostatnie_6m) < 6 or len(wydatki_ostatnie_6m) < 6:
                return render(request, 'predict_savings.html', {
                    'message': 'Brak pełnych danych dla ostatnich 6 miesięcy.'
                })

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
            przychody_miesiac = float(przychody_miesiac) if przychody_miesiac else 0
            wydatki_miesiac = float(wydatki_miesiac) if wydatki_miesiac else 0

            # Obliczanie oszczędności dla wybranego miesiąca
            prognozowane_oszczednosci_miesiac = przewiduj_oszczednosci(przychody_miesiac, wydatki_miesiac)

            # DEBUG: Wyświetlenie danych w konsoli
            print(f"Przychody wybranego miesiąca: {przychody_miesiac}, Wydatki wybranego miesiąca: {wydatki_miesiac}")
            print(f"Ostatnie 6 miesięcy - Przychody: {przychody_ostatnie_6m}, Wydatki: {wydatki_ostatnie_6m}")

            # Sprawdzamy, czy mamy dane dla wybranych miesięcy
            if not przychody_ostatnie_6m or not wydatki_ostatnie_6m:
                return render(request, 'predict_savings.html', {
                    'message': 'Brak danych dla wybranego miesiąca.'
                })

            # Generowanie przyszłych miesięcy (iteracyjna predykcja)
            future_months = pd.DataFrame({
                'YearMonth': pd.date_range(f"{selected_year}-{selected_month}-01", periods=12, freq='M').to_period('M')
            })

            # Ustawiamy początkowe wartości przychodów i wydatków na podstawie ostatnich 6 miesięcy
            history_przychody = przychody_ostatnie_6m[-6:]
            history_wydatki = wydatki_ostatnie_6m[-6:]

            # Iteracyjne przewidywanie na podstawie danych z 6 miesięcy
            for i in range(len(future_months)):
                # Obliczamy przychody i wydatki na podstawie dokładnych danych z ostatnich 6 miesięcy
                przychody_6m = history_przychody[-6:]
                wydatki_6m = history_wydatki[-6:]

                # Tworzymy macierz danych do skalowania
                dane_uzytkownika = np.array([[przychody_6m[-1], wydatki_6m[-1]]])
                dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

                # Prognozujemy oszczędności na podstawie tych danych (oszczędności to tylko różnica, nie wpływa na przychody ani wydatki)
                prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)[0]

                # Zamiast zmieniać przychody lub wydatki na podstawie oszczędności, prognozujemy je samodzielnie
                # Dodajemy realistyczny, umiarkowany wzrost przychodów i wydatków bazując na historycznych danych
                new_przychody = przychody_6m[-1] + np.random.normal(0, 50)  # Możesz dostosować rozkład zmian przychodów
                new_wydatki = wydatki_6m[-1] + np.random.normal(0, 50)  # Możesz dostosować rozkład zmian wydatków

                # Zapobiegamy ujemnym wydatkom
                new_wydatki = max(0, new_wydatki)

                # Aktualizujemy historię
                history_przychody.append(new_przychody)
                history_wydatki.append(new_wydatki)

                # Dodaj prognozowane wartości do DataFrame
                future_months.loc[i, 'Przychody'] = new_przychody
                future_months.loc[i, 'Wydatki'] = new_wydatki
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
