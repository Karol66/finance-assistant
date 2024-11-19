from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password

User = get_user_model()


class UserRegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password')
        extra_kwargs = {
            'password': {'write_only': True, 'allow_blank': True}
        }

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super(UserRegisterSerializer, self).create(validated_data)

    def update(self, instance, validated_data):
        password = validated_data.get('password', None)
        if password:
            validated_data['password'] = make_password(password)
        else:
            validated_data.pop('password', None)

        return super(UserRegisterSerializer, self).update(instance, validated_data)


class UserLoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)


class ChangePasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    new_password = serializers.CharField(write_only=True)

    def validate_new_password(self, value):
        # Można dodać dowolną walidację hasła
        if len(value) < 8:
            raise serializers.ValidationError("Hasło musi mieć co najmniej 8 znaków.")
        return value

    def update_password(self, user, new_password):
        user.password = make_password(new_password)
        user.save()
        return user
