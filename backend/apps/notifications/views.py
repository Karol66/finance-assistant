from django.shortcuts import render, redirect, get_object_or_404
from .models import Notification
from .forms import NotificationForm
from django.contrib.auth.decorators import login_required
from django.utils import timezone  # Do obsługi czasu

@login_required
def notification_create(request):
    if request.method == 'POST':
        form = NotificationForm(request.POST)
        if form.is_valid():
            notification = form.save(commit=False)
            notification.user = request.user  # Ustawienie użytkownika jako właściciela powiadomienia
            notification.save()
            return redirect('notification_list')  # Przekierowanie po dodaniu powiadomienia
    else:
        form = NotificationForm()
    return render(request, 'notification_form.html', {'form': form})

@login_required
def notification_update(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user, is_deleted=False)
    if request.method == 'POST':
        form = NotificationForm(request.POST, instance=notification)
        if form.is_valid():
            form.save()
            return redirect('notification_list')  # Przekierowanie po aktualizacji powiadomienia
    else:
        form = NotificationForm(instance=notification)
    return render(request, 'notification_form.html', {'form': form})

@login_required
def notification_delete(request, pk):
    notification = get_object_or_404(Notification, pk=pk, user=request.user)
    if request.method == 'POST':
        notification.is_deleted = True  # Soft-delete
        notification.save()
        return redirect('notification_list')  # Przekierowanie po usunięciu powiadomienia
    return render(request, 'notification_confirm_delete.html', {'notification': notification})

@login_required
def notification_list(request):
    # Wyświetlamy tylko aktywne powiadomienia, które mają datę wysłania wcześniejszą lub równą bieżącej
    notifications = Notification.objects.filter(user=request.user, is_deleted=False)
    return render(request, 'notification_list.html', {'notifications': notifications})