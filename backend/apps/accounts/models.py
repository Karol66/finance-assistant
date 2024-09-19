from django.db import models
from django.conf import settings  # Dla modelu User

class Account(models.Model):
    ACCOUNT_TYPES = [
        ('checking', 'Checking'),
        ('savings', 'Savings'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)  # Powiązanie z użytkownikiem
    account_name = models.CharField(max_length=255)
    account_type = models.CharField(max_length=255, choices=ACCOUNT_TYPES)
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    currency = models.CharField(max_length=10)
    account_color = models.CharField(max_length=7, default='#FFFFFF')  # Kolor przypisany do konta (np. '#FFFFFF')
    account_icon = models.CharField(max_length=255, default='default_icon')  # Ikona przypisana do konta
    is_deleted = models.BooleanField(default=False)  # Soft delete
    include_in_total = models.BooleanField(default=True)  # Czy uwzględnić w bilansie
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.account_name} ({self.account_type})"


    class Meta:
        db_table = 'accounts'