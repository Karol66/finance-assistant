from django.shortcuts import render, redirect, get_object_or_404
from .models import Card
from .forms import CardForm
from django.contrib.auth.decorators import login_required

@login_required
def card_list(request):
    # Wyświetlamy tylko nieusunięte karty (is_deleted=False)
    cards = Card.objects.filter(account__user=request.user, is_deleted=False)
    return render(request, 'card_list.html', {'cards': cards})

@login_required
def card_create(request):
    if request.method == 'POST':
        form = CardForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('card_list')  # Przekierowanie po dodaniu karty
    else:
        form = CardForm()
    return render(request, 'card_form.html', {'form': form})

@login_required
def card_update(request, pk):
    # Pobieramy kartę, ale ignorujemy te, które są oznaczone jako usunięte
    card = get_object_or_404(Card, pk=pk, account__user=request.user, is_deleted=False)
    if request.method == 'POST':
        form = CardForm(request.POST, instance=card)
        if form.is_valid():
            form.save()
            return redirect('card_list')  # Przekierowanie po aktualizacji karty
    else:
        form = CardForm(instance=card)
    return render(request, 'card_form.html', {'form': form})

@login_required
def card_delete(request, pk):
    # Soft-delete: zamiast usuwania karty, oznaczamy ją jako usuniętą
    card = get_object_or_404(Card, pk=pk, account__user=request.user)
    if request.method == 'POST':
        card.is_deleted = True  # Oznaczenie karty jako usuniętej (soft-delete)
        card.save()
        return redirect('card_list')  # Przekierowanie po soft-delecie
    return render(request, 'card_confirm_delete.html', {'card': card})
