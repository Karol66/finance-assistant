from rest_framework import serializers
from .models import Notification
import re
from django.utils.timezone import make_aware, is_naive
from datetime import datetime, date


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
        read_only_fields = ['user']

    def validate_message(self, value):
        if not value.strip():
            raise serializers.ValidationError("Message cannot be empty.")
        if len(value) > 255:
            raise serializers.ValidationError("Message cannot exceed 255 characters.")
        return value

    def validate_send_at(self, value):
        if isinstance(value, datetime):
            if is_naive(value):
                value = make_aware(value)
        elif isinstance(value, date):
            value = make_aware(datetime.combine(value, datetime.min.time()))
        else:
            raise serializers.ValidationError("Invalid date format. Please provide a valid date or datetime.")

        now = datetime.now(value.tzinfo)
        if value < now.replace(hour=0, minute=0, second=0, microsecond=0):
            raise serializers.ValidationError("Send At date cannot be in the past.")

        return value

    def validate_notification_color(self, value):
        if not re.match(r"^#[A-Fa-f0-9]{6}$", value):
            raise serializers.ValidationError("Invalid color format. Use a hex color code like #FFFFFF.")
        return value

    def validate_notification_icon(self, value):
        if not value.isdigit():
            raise serializers.ValidationError("Invalid icon format. Icon should be a valid Unicode code point.")
        return value

    def validate(self, data):
        if not data.get('notification_color'):
            raise serializers.ValidationError({"notification_color": "Color must be selected."})
        if not data.get('notification_icon'):
            raise serializers.ValidationError({"notification_icon": "Icon must be selected."})
        return data
