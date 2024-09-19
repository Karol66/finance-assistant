from django.shortcuts import render, redirect, get_object_or_404
from .models import Payment
from .forms import PaymentForm
from django.contrib.auth.decorators import login_required

@login_required
def payment_list(request):
    payments = Payment.objects.filter(card__account__user=request.user, is_deleted=False)  # Wyświetlamy tylko aktywne płatności
    return render(request, 'payment_list.html', {'payments': payments})


@login_required
def payment_create(request):
    if request.method == 'POST':
        form = PaymentForm(request.POST)
        if form.is_valid():
            payment = form.save(commit=False)
            # Aktualizacja salda konta
            card = payment.card
            account = card.account
            account.balance -= payment.amount  # Odejmowanie kwoty płatności z salda konta
            account.save()

            payment.save()
            return redirect('payment_list')  # Przekierowanie po dodaniu płatności
    else:
        form = PaymentForm()
    return render(request, 'payment_form.html', {'form': form})


@login_required
def payment_update(request, pk):
    payment = get_object_or_404(Payment, pk=pk, card__account__user=request.user, is_deleted=False)
    if request.method == 'POST':
        form = PaymentForm(request.POST, instance=payment)
        if form.is_valid():
            old_amount = payment.amount  # Stara kwota
            payment = form.save(commit=False)
            card = payment.card
            account = card.account
            # Przywracanie starej kwoty do salda konta
            account.balance += old_amount
            # Odejmowanie nowej kwoty
            account.balance -= payment.amount
            account.save()

            payment.save()
            return redirect('payment_list')  # Przekierowanie po aktualizacji płatności
    else:
        form = PaymentForm(instance=payment)
    return render(request, 'payment_form.html', {'form': form})


@login_required
def payment_delete(request, pk):
    payment = get_object_or_404(Payment, pk=pk, card__account__user=request.user)
    if request.method == 'POST':
        card = payment.card
        account = card.account
        # Przywrócenie kwoty płatności do salda konta
        account.balance += payment.amount
        account.save()

        payment.is_deleted = True  # Soft-delete
        payment.save()
        return redirect('payment_list')  # Przekierowanie po usunięciu
    return render(request, 'payment_confirm_delete.html', {'payment': payment})

