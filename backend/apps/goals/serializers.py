from rest_framework import serializers
from .models import Goal
import re


class GoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Goal
        fields = '__all__'
        read_only_fields = ['user']

    def validate_goal_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Goal name cannot be empty.")
        if len(value) > 255:
            raise serializers.ValidationError("Goal name cannot exceed 255 characters.")
        return value

    def validate_target_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Target amount must be greater than zero.")
        return value

    def validate_current_amount(self, value):
        if value < 0:
            raise serializers.ValidationError("Current amount cannot be negative.")
        return value

    def validate_priority(self, value):
        if not (1 <= value <= 5):
            raise serializers.ValidationError("Priority must be between 1 and 5.")
        return value

    def validate_goal_color(self, value):
        if not re.match(r"^#[A-Fa-f0-9]{6}$", value):
            raise serializers.ValidationError("Invalid color format. Use a hex color code like #FFFFFF.")
        return value

    def validate_goal_icon(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Invalid icon format. Icon should be a valid Unicode code point.")
        return value

    def validate(self, data):
        if not data.get('goal_color'):
            raise serializers.ValidationError({"goal_color": "Color must be selected."})
        if not data.get('goal_icon'):
            raise serializers.ValidationError({"goal_icon": "Icon must be selected."})
        if data.get('current_amount', 0) > data.get('target_amount', 0):
            raise serializers.ValidationError("Current amount cannot exceed target amount.")
        return data
