from django import forms
from .models import Statistics
from datetime import datetime

class StatisticsForm(forms.ModelForm):
    class Meta:
        model = Statistics
        fields = ['account', 'statistic_type', 'value']  # Wybieramy konto, typ statystyki i wartość
        widgets = {
            'account': forms.Select(attrs={'class': 'form-control'}),
            'statistic_type': forms.Select(attrs={'class': 'form-control'}),
            'value': forms.NumberInput(attrs={'class': 'form-control'}),
        }

class MonthSelectionForm(forms.Form):
    MONTH_CHOICES = [(i, datetime(2024, i, 1).strftime('%B')) for i in range(1, 13)]
    YEAR_CHOICES = [(y, y) for y in range(2020, 2025)]  # Zakres lat, które chcesz wyświetlać

    month = forms.ChoiceField(choices=MONTH_CHOICES, label="Wybierz miesiąc")
    year = forms.ChoiceField(choices=YEAR_CHOICES, label="Wybierz rok")