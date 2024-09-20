from django import forms
from .models import Account


class AccountForm(forms.ModelForm):
    class Meta:
        model = Account
        fields = ['account_name', 'account_type', 'balance', 'currency', 'account_color', 'account_icon',
                  'include_in_total', 'account_number']
        widgets = {
            'account_name': forms.TextInput(attrs={'class': 'form-control'}),
            'account_type': forms.Select(attrs={'class': 'form-control'}),
            'balance': forms.NumberInput(attrs={'class': 'form-control'}),
            'currency': forms.TextInput(attrs={'class': 'form-control'}),
            'account_color': forms.TextInput(attrs={'class': 'form-control'}),
            'account_icon': forms.TextInput(attrs={'class': 'form-control'}),
            'include_in_total': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
            'account_number': forms.TextInput(attrs={'class': 'form-control'}),
        }
