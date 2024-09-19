from django import forms
from .models import Transfer

class TransferForm(forms.ModelForm):
    class Meta:
        model = Transfer
        fields = ['account', 'category', 'amount', 'description']  # Pola formularza
        widgets = {
            'account': forms.Select(attrs={'class': 'form-control'}),
            'category': forms.Select(attrs={'class': 'form-control'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'class': 'form-control'}),
        }
