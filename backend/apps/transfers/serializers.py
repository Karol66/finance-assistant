from decimal import Decimal
from rest_framework import serializers
from .models import Transfer
from django.utils.timezone import make_aware, is_naive
from datetime import date, datetime


class TransferSerializer(serializers.ModelSerializer):
    account_name = serializers.SerializerMethodField()
    category_type = serializers.SerializerMethodField()
    category_name = serializers.SerializerMethodField()
    category_icon = serializers.SerializerMethodField()
    category_color = serializers.SerializerMethodField()

    class Meta:
        model = Transfer
        fields = '__all__'
        read_only_fields = ['user']

    def validate_transfer_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Transfer name cannot be empty.")
        if len(value) > 255:
            raise serializers.ValidationError("Transfer name cannot exceed 255 characters.")
        return value

    def validate_amount(self, value):
        try:
            value = Decimal(value)
        except (ValueError, TypeError):
            raise serializers.ValidationError("Amount must be a valid number.")
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than zero.")
        return value

    def validate_date(self, value):
        if isinstance(value, datetime):
            if is_naive(value):
                value = make_aware(value)
        elif isinstance(value, date):
            value = make_aware(datetime.combine(value, datetime.min.time()))
        else:
            raise serializers.ValidationError("Invalid date format. Please provide a valid date.")

        if value > datetime.now(value.tzinfo):
            raise serializers.ValidationError("Date cannot be in the future.")

        return value

    def validate_description(self, value):
        if value and len(value) > 500:
            raise serializers.ValidationError("Description cannot exceed 500 characters.")
        return value

    def validate(self, data):
        if not data.get('account'):
            raise serializers.ValidationError({"account": "Account must be selected."})
        if not data.get('category'):
            raise serializers.ValidationError({"category": "Category must be selected."})
        return data

    def get_category_type(self, obj):
        if obj.category:
            return obj.category.category_type
        return None

    def get_category_name(self, obj):
        if obj.category:
            return obj.category.category_name
        return None

    def get_category_icon(self, obj):
        if obj.category:
            return obj.category.category_icon
        return None

    def get_category_color(self, obj):
        if obj.category:
            return obj.category.category_color
        return None

    def get_account_name(self, obj):
        if obj.account:
            return obj.account.account_name
        return None
