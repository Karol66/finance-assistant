from django.db import models
from apps.accounts.models import Account  # Zakładamy, że masz już model Account

class Card(models.Model):
    CARD_TYPES = [
        ('visa', 'Visa'),
        ('mastercard', 'MasterCard'),
    ]

    account = models.ForeignKey(Account, on_delete=models.CASCADE)  # Powiązanie z kontem
    card_number = models.CharField(max_length=16)
    card_type = models.CharField(max_length=255, choices=CARD_TYPES)
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    enabled = models.BooleanField(default=True)
    bank_name = models.CharField(max_length=255)  # Nazwa banku
    cvv = models.CharField(max_length=3)  # CVV karty
    is_deleted = models.BooleanField(default=False)  # Soft-delete

    def __str__(self):
        return f"{self.card_number} ({self.card_type})"

    class Meta:
        db_table = 'cards'
