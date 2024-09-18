from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.
class User(AbstractUser):
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=255, unique=True)
    password = models.CharField(max_length=255)
    enabled = models.BooleanField(default=True)

    groups = models.ManyToManyField(
        'auth.Group',
        related_name='users_in_group',  # Użytkownicy w grupie
        blank=True
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='users_with_permission',  # Użytkownicy z danym uprawnieniem
        blank=True
    )

    class Meta:
        db_table = 'users'