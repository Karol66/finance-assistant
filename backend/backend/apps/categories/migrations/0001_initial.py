# Generated by Django 5.1.1 on 2024-09-17 18:20

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('category_name', models.CharField(max_length=255)),
                ('category_type', models.CharField(max_length=255)),
                ('category_color', models.CharField(max_length=7)),
            ],
        ),
    ]
