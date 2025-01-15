from rest_framework import serializers
from .models import Category
import re


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'
        read_only_fields = ['user']

    def validate_category_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Category name cannot be empty.")
        if len(value) > 255:
            raise serializers.ValidationError("Category name cannot exceed 255 characters.")
        return value

    def validate_category_type(self, value):
        if value not in ['income', 'expense']:
            raise serializers.ValidationError("Category type must be either 'income' or 'expense'.")
        return value

    def validate_category_color(self, value):
        if not re.match(r"^#[A-Fa-f0-9]{6}$", value):
            raise serializers.ValidationError("Invalid color format. Use a hex color code like #FFFFFF.")
        return value

    def validate_category_icon(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Invalid icon format. Icon should be a valid Unicode code point.")
        return value

    def validate(self, data):
        if not data.get('category_color'):
            raise serializers.ValidationError({"category_color": "Color must be selected."})
        if not data.get('category_icon'):
            raise serializers.ValidationError({"category_icon": "Icon must be selected."})
        return data
