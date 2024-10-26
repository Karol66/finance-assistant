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

    goal_name = models.CharField(max_length=255)
    target_amount = models.DecimalField(max_digits=10, decimal_places=2)
    current_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    end_date = models.DateTimeField()
    status = models.CharField(max_length=50, choices=GOAL_STATUS_CHOICES, default='active')
    priority = models.IntegerField(default=1)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    goal_color = models.CharField(max_length=7, default='#FFFFFF')
    goal_icon = models.CharField(max_length=255, default='default_icon')
    is_deleted = models.BooleanField(default=False)

    def __str__(self):
        return f"Goal: {self.goal_name} (Target: {self.target_amount})"

    class Meta:
        db_table = 'goals'
        ordering = ['-priority', 'end_date']
