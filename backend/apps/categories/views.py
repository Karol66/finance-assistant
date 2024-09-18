from django.shortcuts import render, redirect, get_object_or_404
from .models import Category
from .forms import CategoryForm
from django.contrib.auth.decorators import login_required

# Widok do wyświetlania wszystkich kategorii użytkownika
@login_required
def category_list(request):
    categories = Category.objects.filter(user=request.user, is_deleted=False)
    return render(request, 'category_list.html', {'categories': categories})

# Widok do tworzenia nowej kategorii
@login_required
def category_create(request):
    if request.method == 'POST':
        form = CategoryForm(request.POST)
        if form.is_valid():
            category = form.save(commit=False)
            category.user = request.user
            category.save()
            return redirect('category_list')  # Przekierowanie do listy kategorii po dodaniu
    else:
        form = CategoryForm()
    return render(request, 'category_form.html', {'form': form})

# Widok do edytowania istniejącej kategorii
@login_required
def category_update(request, pk):
    category = get_object_or_404(Category, pk=pk, user=request.user)
    if request.method == 'POST':
        form = CategoryForm(request.POST, instance=category)
        if form.is_valid():
            form.save()
            return redirect('category_list')  # Przekierowanie do listy kategorii po edycji
    else:
        form = CategoryForm(instance=category)
    return render(request, 'category_form.html', {'form': form})

# Widok do usuwania kategorii (oznaczenie jako usuniętej)
@login_required
def category_delete(request, pk):
    category = get_object_or_404(Category, pk=pk, user=request.user)
    if request.method == 'POST':
        category.is_deleted = True
        category.save()
        return redirect('category_list')  # Przekierowanie do listy kategorii po usunięciu
    return render(request, 'category_confirm_delete.html', {'category': category})
