from django import forms
from .models import Statistics

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
    month = forms.DateField(
        widget=forms.SelectDateWidget(empty_label=("Rok", "Miesiąc", "Dzień")),
        label="Wybierz miesiąc",
        input_formats=['%Y-%m-%d']
    )