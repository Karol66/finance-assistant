from rest_framework import serializers
from .models import Transfer


class TransferSerializer(serializers.ModelSerializer):
    # Pola dla danych konta
    account_name = serializers.SerializerMethodField()
    account_type = serializers.SerializerMethodField()

    # Pola dla danych kategorii
    category_type = serializers.SerializerMethodField()
    category_name = serializers.SerializerMethodField()
    category_icon = serializers.SerializerMethodField()
    category_color = serializers.SerializerMethodField()

    # Nowe pola do obsługi regularnych transferów
    is_regular = serializers.BooleanField(required=False, default=False)
    interval = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = Transfer
        fields = '__all__'  # Zawiera wszystkie pola transferu oraz dodane pola konta i kategorii
        read_only_fields = ['user']

    # Metoda do pobierania 'category_type' z powiązanej kategorii
    def get_category_type(self, obj):
        if obj.category:
            return obj.category.category_type  # Zwracamy typ kategorii
        return None

    # Metoda do pobierania 'category_name' z powiązanej kategorii
    def get_category_name(self, obj):
        if obj.category:
            return obj.category.category_name  # Zwracamy nazwę kategorii
        return None

    # Metoda do pobierania 'category_icon' z powiązanej kategorii
    def get_category_icon(self, obj):
        if obj.category:
            return obj.category.category_icon  # Zwracamy ikonę kategorii
        return None

    # Metoda do pobierania 'category_color' z powiązanej kategorii
    def get_category_color(self, obj):
        if obj.category:
            return obj.category.category_color  # Zwracamy kolor kategorii
        return None

    # Metoda do pobierania 'account_name' z powiązanego konta
    def get_account_name(self, obj):
        if obj.account:
            return obj.account.account_name  # Zwracamy nazwę konta
        return None

    # Metoda do pobierania 'account_type' z powiązanego konta
    def get_account_type(self, obj):
        if obj.account:
            return obj.account.account_type  # Zwracamy typ konta (np. oszczędnościowe, bieżące)
        return None
