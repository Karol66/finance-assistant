from rest_framework import serializers
from .models import Transfer


class TransferSerializer(serializers.ModelSerializer):
    account_name = serializers.SerializerMethodField()
    account_type = serializers.SerializerMethodField()

    category_type = serializers.SerializerMethodField()
    category_name = serializers.SerializerMethodField()
    category_icon = serializers.SerializerMethodField()
    category_color = serializers.SerializerMethodField()

    is_regular = serializers.BooleanField(required=False, default=False)
    interval = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = Transfer
        fields = '__all__'
        read_only_fields = ['user']

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

    def get_account_type(self, obj):
        if obj.account:
            return obj.account.account_type
        return None
