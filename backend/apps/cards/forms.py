from django import forms
from .models import Card

class CardForm(forms.ModelForm):
    class Meta:
        model = Card
        fields = ['account', 'card_number', 'card_type', 'balance', 'enabled', 'bank_name', 'cvv']  # Dodane pola
        widgets = {
            'account': forms.Select(attrs={'class': 'form-control'}),
            'card_number': forms.TextInput(attrs={'class': 'form-control'}),
            'card_type': forms.Select(attrs={'class': 'form-control'}),
            'balance': forms.NumberInput(attrs={'class': 'form-control'}),
            'enabled': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'bank_name': forms.TextInput(attrs={'class': 'form-control'}),  # Pole dla nazwy banku
            'cvv': forms.PasswordInput(attrs={'class': 'form-control'}),  # Pole dla CVV (ukryte)
        }
