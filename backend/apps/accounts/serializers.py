from rest_framework import serializers
from .models import Account
import re


class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = '__all__'
        read_only_fields = ['user']

    def validate_account_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Account name cannot be empty.")
        if len(value) > 255:
            raise serializers.ValidationError("Account name cannot exceed 255 characters.")
        return value

    def validate_balance(self, value):
        try:
            if isinstance(value, str):
                value = float(value.replace(',', '.'))
            else:
                float(value)
        except (ValueError, TypeError):
            raise serializers.ValidationError("Balance must be a valid number.")

        if value < 0:
            raise serializers.ValidationError("Balance cannot be negative.")

        return value

    def validate_account_color(self, value):
        if not re.match(r"^#[A-Fa-f0-9]{6}$", value):
            raise serializers.ValidationError("Invalid color format. Use a hex color code like #FFFFFF.")
        return value

    def validate_account_icon(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Invalid icon format. Icon should be a valid Unicode code point.")
        return value

    def validate(self, data):
        if not data.get('account_color'):
            raise serializers.ValidationError({"account_color": "Color must be selected."})
        if not data.get('account_icon'):
            raise serializers.ValidationError({"account_icon": "Icon must be selected."})
        return data
