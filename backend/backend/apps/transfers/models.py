from django.db import models
from apps.accounts.models import Account
from apps.categories.models import Category

# Create your models here.
class Transfer(models.Model):
    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transfer_date = models.DateTimeField(auto_now_add=True)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return f"Transfer of {self.amount} on {self.transfer_date} to {self.account.account_name}"

    class Meta:
        db_table = 'transfers'