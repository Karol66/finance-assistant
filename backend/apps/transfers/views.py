from django.shortcuts import render, redirect, get_object_or_404
from .models import Transfer
from .forms import TransferForm
from django.contrib.auth.decorators import login_required

@login_required
def transfer_create(request):
    if request.method == 'POST':
        form = TransferForm(request.POST)
        if form.is_valid():
            transfer = form.save(commit=False)
            account = transfer.account
            # Aktualizacja salda konta (odejmowanie kwoty przelewu)
            account.balance -= transfer.amount
            account.save()

            transfer.save()
            return redirect('transfer_list')  # Przekierowanie po dodaniu przelewu
    else:
        form = TransferForm()
    return render(request, 'transfer_form.html', {'form': form})

@login_required
def transfer_update(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user, is_deleted=False)
    if request.method == 'POST':
        form = TransferForm(request.POST, instance=transfer)
        if form.is_valid():
            old_amount = transfer.amount  # Przechowujemy starą kwotę
            transfer = form.save(commit=False)
            account = transfer.account
            # Przywrócenie starej kwoty do salda konta
            account.balance += old_amount
            # Odejmowanie nowej kwoty
            account.balance -= transfer.amount
            account.save()

            transfer.save()
            return redirect('transfer_list')  # Przekierowanie po aktualizacji przelewu
    else:
        form = TransferForm(instance=transfer)
    return render(request, 'transfer_form.html', {'form': form})

@login_required
def transfer_delete(request, pk):
    transfer = get_object_or_404(Transfer, pk=pk, account__user=request.user)
    if request.method == 'POST':
        account = transfer.account
        # Przywrócenie kwoty przelewu do salda konta
        account.balance += transfer.amount
        account.save()

        transfer.is_deleted = True  # Oznaczenie przelewu jako usuniętego (soft-delete)
        transfer.save()
        return redirect('transfer_list')  # Przekierowanie po usunięciu przelewu
    return render(request, 'transfer_confirm_delete.html', {'transfer': transfer})

@login_required
def transfer_list(request):
    transfers = Transfer.objects.filter(account__user=request.user, is_deleted=False)  # Wyświetlamy tylko aktywne przelewy
    return render(request, 'transfer_list.html', {'transfers': transfers})
