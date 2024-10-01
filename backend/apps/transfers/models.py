from django.db import models
from apps.accounts.models import Account
from apps.categories.models import Category


class Transfer(models.Model):
    account = models.ForeignKey(Account, on_delete=models.CASCADE)  # Powiązanie z kontem
    # recipient_account = models.ForeignKey(Account, on_delete=models.CASCADE, related_name="recipient_account", null=True, blank=True)  # Konto docelowe, opcjonalne
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)  # Powiązanie z kategorią
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transfer_date = models.DateTimeField()
    description = models.TextField()
    is_deleted = models.BooleanField(default=False)  # Soft-delete

    def __str__(self):
        return f"Transfer of {self.amount} on {self.transfer_date}"

    class Meta:
        db_table = 'transfers'

    # Automatyczne sprawdzenie, czy to przychód, czy wydatek
    @property
    def is_income(self):
        return self.category.category_type == 'income'  # Sprawdzamy kategorię
