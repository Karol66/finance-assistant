from django.shortcuts import render, redirect, get_object_or_404
from .models import Transfer
from .forms import TransferForm, AccountTransferForm
from django.contrib.auth.decorators import login_required
from apps.statistics.models import Statistics
from apps.accounts.models import Account


@login_required
def transfer_create(request):
    if request.method == 'POST':
        form = TransferForm(request.POST)
        if form.is_valid():
            transfer = form.save(commit=False)
            account = transfer.account

            # Rozróżnienie przychodu i wydatku na podstawie kategorii
            if transfer.category.category_type == 'income':
                # Jeśli kategoria to przychód, dodajemy kwotę do salda konta
                account.balance += transfer.amount
                statistic_type = 'monthly_income'
            else:
                # Jeśli kategoria to wydatek, odejmujemy kwotę z salda konta
                account.balance -= transfer.amount
                statistic_type = 'monthly_expense'

            account.save()
            transfer.save()

            # Dodanie statystyk po dokonaniu przelewu
            Statistics.objects.create(
                account=account,
                statistic_type=statistic_type,
                value=transfer.amount
            )

            return redirect('transfer_list')
    else:
        form = TransferForm()
    return render(request, 'transfer_form.html', {'form': form})

@login_required
def account_transfer(request):
    if request.method == 'POST':
        form = AccountTransferForm(request.POST)
        if form.is_valid():
            transfer = form.save(commit=False)
            source_account = transfer.account

            # Wyszukiwanie konta odbiorcy na podstawie numeru konta
            recipient_account_number = form.cleaned_data.get('recipient_account_number')
            try:
                recipient_account = Account.objects.get(account_number=recipient_account_number, is_deleted=False)
            except Account.DoesNotExist:
                form.add_error('recipient_account_number', 'Nie znaleziono konta o podanym numerze')
                return render(request, 'account_transfer_form.html', {'form': form})

            # Zmniejszamy saldo konta źródłowego
            source_account.balance -= transfer.amount
            source_account.save()

            # Zwiększamy saldo konta docelowego
            recipient_account.balance += transfer.amount
            recipient_account.save()

            # Zapisanie przelewu z kontem odbiorcy
            transfer.recipient_account = recipient_account
            transfer.save()

            # Statystyki dla konta źródłowego
            Statistics.objects.create(
                account=source_account,
                statistic_type='monthly_expense',
                value=transfer.amount
            )

            # Statystyki dla konta odbiorcy
            Statistics.objects.create(
                account=recipient_account,
                statistic_type='monthly_income',
                value=transfer.amount
            )

            return redirect('transfer_list')  # Przekierowanie po dodaniu przelewu
    else:
        form = AccountTransferForm()
    return render(request, 'account_transfer_form.html', {'form': form})

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
