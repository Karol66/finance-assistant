from django import forms
from .models import Notification
from django.utils import timezone

class NotificationForm(forms.ModelForm):
    class Meta:
        model = Notification
        fields = ['message', 'send_at']
        widgets = {
            'message': forms.Textarea(attrs={'class': 'form-control'}),
            'send_at': forms.DateTimeInput(attrs={'class': 'form-control', 'type': 'datetime-local'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not self.instance.pk:
            self.fields['send_at'].initial = timezone.now().strftime('%Y-%m-%dT%H:%M')


