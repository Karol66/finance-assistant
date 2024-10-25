from django.db import models
from django.contrib.auth import get_user_model
from apps.accounts.models import Account

User = get_user_model()


class Goal(models.Model):
    GOAL_STATUS_CHOICES = [
        ('active', 'Active'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    goal_name = models.CharField(max_length=255)  # Nazwa celu
    target_amount = models.DecimalField(max_digits=10, decimal_places=2)  # Docelowa kwota
    current_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)  # Aktualnie zebrana kwota
    end_date = models.DateTimeField()  # Termin realizacji celu
    status = models.CharField(max_length=50, choices=GOAL_STATUS_CHOICES, default='active')  # Status celu
    priority = models.IntegerField(default=1)  # Priorytet celu (np. od 1 do 5)

    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Użytkownik, który stworzył cel
    account = models.ForeignKey(Account, on_delete=models.CASCADE)  # Konto, z którego będą pochodzić środki

    is_deleted = models.BooleanField(default=False)  # Flaga logicznego usunięcia (soft delete)

    def __str__(self):
        return f"Goal: {self.goal_name} (Target: {self.target_amount})"

    class Meta:
        db_table = 'goals'
        ordering = ['-priority', 'end_date']  # Sortowanie wg priorytetu i terminu
