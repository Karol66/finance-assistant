from django.shortcuts import render, redirect
from .forms import StatisticsForm
from django.contrib.auth.decorators import login_required

@login_required
def create_statistics(request):
    if request.method == 'POST':
        form = StatisticsForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('statistics_list')  # Przekierowanie po zapisaniu danych
    else:
        form = StatisticsForm()
    return render(request, 'statistics_form.html', {'form': form})


from django.shortcuts import render
from .models import Statistics
from django.contrib.auth.decorators import login_required

@login_required
def statistics_list(request):
    # Pobieramy dane dla wszystkich kont użytkownika
    statistics = Statistics.objects.filter(account__user=request.user)
    return render(request, 'statistics_list.html', {'statistics': statistics})
