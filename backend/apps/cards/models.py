from django.db import models
from apps.accounts.models import Account

# Create your models here.
class Card(models.Model):
    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    card_number = models.CharField(max_length=16)
    card_type = models.CharField(max_length=255)
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    enabled = models.BooleanField(default=True)

    def __str__(self):
        return f"Card {self.card_number} for {self.account.account_name}"

    class Meta:
        db_table = 'cards'