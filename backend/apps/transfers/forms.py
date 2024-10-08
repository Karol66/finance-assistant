from django import forms
from .models import Transfer
from django.utils import timezone

class TransferForm(forms.ModelForm):
    class Meta:
        model = Transfer
        fields = ['account', 'category', 'amount', 'description', 'transfer_date']
        widgets = {
            'account': forms.Select(attrs={'class': 'form-control'}),
            'category': forms.Select(attrs={'class': 'form-control'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'class': 'form-control'}),
            'transfer_date': forms.DateTimeInput(attrs={'class': 'form-control', 'type': 'datetime-local'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.instance.pk:  # Jeśli nie edytujemy istniejącego przelewu
            self.fields['transfer_date'].initial = timezone.now().strftime('%Y-%m-%dT%H:%M')


class AccountTransferForm(forms.ModelForm):
    recipient_account_number = forms.CharField(max_length=26, label="Numer konta odbiorcy", required=False)  # Pole na numer konta odbiorcy

    class Meta:
        model = Transfer
        fields = ['account', 'amount', 'description', 'transfer_date']  # Pola formularza
        widgets = {
            'account': forms.Select(attrs={'class': 'form-control'}),  # Konto źródłowe
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'class': 'form-control'}),
            'transfer_date': forms.DateTimeInput(attrs={'class': 'form-control', 'type': 'datetime-local'}),  # Data transferu
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.instance.pk:  # Jeśli nie edytujemy istniejącego przelewu
            self.fields['transfer_date'].initial = timezone.now().strftime('%Y-%m-%dT%H:%M')