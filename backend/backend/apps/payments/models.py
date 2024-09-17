from django.db import models
from apps.cards.models import Card
from apps.categories.models import Category


# Create your models here.
class Payment(models.Model):
    card = models.ForeignKey(Card, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    payment_date = models.DateTimeField(auto_now_add=True)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return f"Payment of {self.amount} on {self.payment_date} for {self.card.card_number}"

    class Meta:
        db_table = 'payments'