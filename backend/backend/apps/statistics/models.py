from django.db import models
from apps.accounts.models import Account

# Create your models here.
class Statistic(models.Model):
    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    statistic_type = models.CharField(max_length=255)
    value = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.statistic_type} for {self.account.account_name}"

    class Meta:
        db_table = 'statistics'