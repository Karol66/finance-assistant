from django.db import models
from apps.accounts.models import Account
from django.utils import timezone


class Statistics(models.Model):
    STATISTIC_TYPES = [
        ('monthly_expense', 'Monthly Expense'),
        ('monthly_income', 'Monthly Income'),
        ('monthly_savings', 'Monthly Savings'),
    ]

    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    statistic_type = models.CharField(max_length=255, choices=STATISTIC_TYPES)
    value = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.statistic_type} - {self.value} for account {self.account.account_name}"

    class Meta:
        db_table = 'statistics'