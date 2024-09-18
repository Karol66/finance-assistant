from django import forms
from .models import Category


class CategoryForm(forms.ModelForm):
    class Meta:
        model = Category
        fields = ['category_name', 'category_type', 'planned_expenses', 'category_color', 'category_icon']

        widgets = {
            'category_name': forms.TextInput(attrs={'class': 'form-control'}),
            'category_type': forms.Select(attrs={'class': 'form-control'}),
            'planned_expenses': forms.NumberInput(attrs={'class': 'form-control'}),
            'category_color': forms.TextInput(attrs={'class': 'form-control'}),
            'category_icon': forms.TextInput(attrs={'class': 'form-control'}),
        }
