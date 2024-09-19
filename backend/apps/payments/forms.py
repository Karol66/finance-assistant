from django import forms
from .models import Payment
from django.utils import timezone

class PaymentForm(forms.ModelForm):
    class Meta:
        model = Payment
        fields = ['card', 'category', 'amount', 'description', 'payment_date']
        widgets = {
            'card': forms.Select(attrs={'class': 'form-control'}),
            'category': forms.Select(attrs={'class': 'form-control'}),
            'amount': forms.NumberInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'class': 'form-control'}),
            'payment_date': forms.DateTimeInput(attrs={'class': 'form-control', 'type': 'datetime-local'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.instance.pk:  # Jeśli nie edytujemy istniejącej płatności
            self.fields['payment_date'].initial = timezone.now().strftime('%Y-%m-%dT%H:%M')
