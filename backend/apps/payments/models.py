from django.db import models
from apps.cards.models import Card
from apps.categories.models import Category

class Payment(models.Model):
    card = models.ForeignKey(Card, on_delete=models.CASCADE)  # Powiązanie z kartą
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)  # Powiązanie z kategorią
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_date = models.DateTimeField()
    description = models.TextField()
    is_deleted = models.BooleanField(default=False)  # Soft-delete

    def __str__(self):
        return f"Payment of {self.amount} on {self.payment_date}"

    class Meta:
        db_table = 'payments'
