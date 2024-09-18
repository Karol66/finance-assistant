from django.shortcuts import render, redirect
from django.contrib.auth import login, logout
from django.contrib.auth.views import LoginView
from django.contrib.auth.decorators import login_required
from .forms import UserRegistrationForm, CustomAuthenticationForm

# Create your views here.

def home(request):
    return render(request, 'home.html')

def register(request):
    if request.method == 'POST':
        form = UserRegistrationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)  # Automatyczne logowanie po rejestracji
            return redirect('home')  # Przekierowanie na stronę główną
    else:
        form = UserRegistrationForm()
    return render(request, 'register.html', {'form': form})

class CustomLoginView(LoginView):
    authentication_form = CustomAuthenticationForm
    template_name = 'login.html'
    redirect_authenticated_user = True  # Przekierowanie, jeśli użytkownik jest zalogowany
    next_page = 'home'  # Przekierowanie na stronę główną po zalogowaniu

@login_required
def logout_view(request):
    logout(request)
    return redirect('login')