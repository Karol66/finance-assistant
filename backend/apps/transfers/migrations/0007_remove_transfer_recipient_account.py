# Generated by Django 5.1.1 on 2024-10-01 15:48

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('transfers', '0006_alter_transfer_recipient_account'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='transfer',
            name='recipient_account',
        ),
    ]