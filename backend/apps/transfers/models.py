from django.db import models
from apps.accounts.models import Account
from apps.categories.models import Category

class Transfer(models.Model):
    transfer_name = models.CharField(max_length=255)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.TextField()
    date = models.DateTimeField()
    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    is_deleted = models.BooleanField(default=False)

    is_regular = models.BooleanField(default=False)
    interval = models.CharField(
        max_length=50,
        choices=[
            ('daily', 'Daily'),
            ('weekly', 'Weekly'),
            ('monthly', 'Monthly'),
            ('yearly', 'Yearly'),
        ],
        null=True,
        blank=True
    )

    def __str__(self):
        if self.is_regular:
            return f"Regular Transfer of {self.amount} ({self.interval})"
        return f"Transfer of {self.amount} on {self.date}"

    class Meta:
        db_table = 'transfers'
