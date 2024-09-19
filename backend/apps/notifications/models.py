from django.db import models
from django.conf import settings  # Używamy dla modelu użytkownika (User)
from django.utils import timezone

class Notification(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    send_at = models.DateTimeField()  # Ustaw domyślną wartość
    is_deleted = models.BooleanField(default=False)

    def __str__(self):
        return f"Notification for {self.user.username} - {self.message[:30]}"

    class Meta:
        db_table = 'notifications'
