from django.shortcuts import render, redirect, get_object_or_404
from .models import Account
from .forms import AccountForm
from django.contrib.auth.decorators import login_required

@login_required
def account_list(request):
    accounts = Account.objects.filter(user=request.user, is_deleted=False)  # Pomiń soft-deleted konta
    return render(request, 'account_list.html', {'accounts': accounts})

@login_required
def account_create(request):
    if request.method == 'POST':
        form = AccountForm(request.POST)
        if form.is_valid():
            account = form.save(commit=False)
            account.user = request.user  # Przypisanie konta do zalogowanego użytkownika
            account.save()
            return redirect('account_list')  # Przekierowanie po dodaniu konta
    else:
        form = AccountForm()
    return render(request, 'account_form.html', {'form': form})

@login_required
def account_update(request, pk):
    account = get_object_or_404(Account, pk=pk, user=request.user)
    if request.method == 'POST':
        form = AccountForm(request.POST, instance=account)
        if form.is_valid():
            form.save()
            return redirect('account_list')  # Przekierowanie po aktualizacji konta
    else:
        form = AccountForm(instance=account)
    return render(request, 'account_form.html', {'form': form})

@login_required
def account_delete(request, pk):
    account = get_object_or_404(Account, pk=pk, user=request.user)
    if request.method == 'POST':
        account.is_deleted = True  # Soft-delete zamiast usuwania z bazy danych
        account.save()
        return redirect('account_list')  # Przekierowanie po soft-delecie
    return render(request, 'account_confirm_delete.html', {'account': account})
