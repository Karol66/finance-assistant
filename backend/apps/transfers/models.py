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

    def __str__(self):
        return f"Transfer of {self.amount} on {self.date}"

    class Meta:
        db_table = 'transfers'
