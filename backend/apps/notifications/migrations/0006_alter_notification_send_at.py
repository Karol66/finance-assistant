# Generated by Django 5.1.1 on 2024-09-19 20:36

import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notifications', '0005_notification_send_at'),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='send_at',
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
    ]
