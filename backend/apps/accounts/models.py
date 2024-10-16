from django.db import models
from django.conf import settings

class Account(models.Model):

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    account_name = models.CharField(max_length=255)
    account_type = models.CharField(max_length=255)
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    account_color = models.CharField(max_length=7, default='#FFFFFF')
    account_icon = models.CharField(max_length=255, default='default_icon')
    is_deleted = models.BooleanField(default=False)
    include_in_total = models.BooleanField(default=True)  
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.account_name} ({self.account_type})"

    class Meta:
        db_table = 'accounts'
