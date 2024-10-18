from django.db import models
from apps.users.models import User

# Create your models here.
class Category(models.Model):
    CATEGORY_TYPES = [
        ('expense', 'Expense'),
        ('income', 'Income'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    category_name = models.CharField(max_length=255)
    category_type = models.CharField(max_length=50, choices=CATEGORY_TYPES)  # Użycie 'choices' dla ograniczenia wartości
    category_color = models.CharField(max_length=7)  # Kolor kategorii (hex, np. #FF5733)
    category_icon = models.CharField(max_length=50)  # Ikona kategorii
    is_deleted = models.BooleanField(default=False)  # Pole do oznaczania kategorii jako usuniętej

    def __str__(self):
        return f"{self.category_name} ({self.category_type})"

    class Meta:
        db_table = 'categories'