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
