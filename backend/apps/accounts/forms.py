from django import forms
from .models import Account

class AccountForm(forms.ModelForm):
    class Meta:
        model = Account
        fields = ['account_name', 'account_type', 'balance', 'currency', 'account_color', 'account_icon', 'include_in_total']  # Zaktualizowane pola
        widgets = {
            'account_name': forms.TextInput(attrs={'class': 'form-control'}),
            'account_type': forms.Select(attrs={'class': 'form-control'}),
            'balance': forms.NumberInput(attrs={'class': 'form-control'}),
            'currency': forms.TextInput(attrs={'class': 'form-control'}),
            'account_color': forms.TextInput(attrs={'class': 'form-control'}),  # Pole dla koloru konta
            'account_icon': forms.TextInput(attrs={'class': 'form-control'}),  # Pole dla ikony konta
            'include_in_total': forms.CheckboxInput(attrs={'class': 'form-check-input'}),  # Pole logiczne
        }
