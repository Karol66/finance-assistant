from rest_framework import serializers
from .models import Statistics


class StatisticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Statistics
        fields = '__all__'
        read_only_fields = ['user']
