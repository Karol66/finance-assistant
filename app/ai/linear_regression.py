import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# Generowanie danych dla 2000 miesięcy (dla przykładu)
np.random.seed(42)  # Dla powtarzalności wyników

record_number = 2000

months = np.arange(1, record_number + 1)
przychody = np.random.normal(5000, 500, record_number)
wydatki = np.random.normal(3500, 400, record_number)
oszczednosci = przychody - wydatki + np.random.normal(100, 50, record_number)

data = {
    'Miesiąc': months,
    'Przychody': przychody,
    'Wydatki': wydatki,
    'Oszczędności': oszczednosci
}

df = pd.DataFrame(data)

# Zmienne niezależne: Przychody i Wydatki
X = df[['Przychody', 'Wydatki']]

# Zmienna zależna: Oszczędności
y = df['Oszczędności']

# Podział danych na treningowe i testowe
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Standaryzacja danych
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Tworzenie modelu regresji liniowej
model = LinearRegression()

# Trenowanie modelu na danych treningowych
model.fit(X_train_scaled, y_train)

# Prognozy na danych testowych
y_pred = model.predict(X_test_scaled)

# Ocena modelu - obliczamy błąd średniokwadratowy (MSE)
mse = mean_squared_error(y_test, y_pred)
print(f'Błąd średniokwadratowy (Regresja Liniowa): {mse}')

# Wyniki dla regresji liniowej
predykcje = pd.DataFrame({'Rzeczywiste oszczędności': y_test, 'Prognozowane oszczędności': y_pred})
print(predykcje)

# Wykres rzeczywistych vs prognozowanych oszczędności
plt.scatter(y_test, y_pred)
plt.xlabel("Rzeczywiste oszczędności")
plt.ylabel("Prognozowane oszczędności")
plt.title("Rzeczywiste vs Prognozowane oszczędności (Regresja Liniowa)")
plt.show()

# Oblicz residuale
residuals = y_test - y_pred

# Wykres residuali
plt.scatter(y_pred, residuals)
plt.axhline(0, color='red', linestyle='--')
plt.xlabel('Prognozowane wartości')
plt.ylabel('Residuals')
plt.title('Wykres residuali (Regresja Liniowa)')
plt.show()

# Zapis modelu do pliku
joblib.dump(model, 'model_regresji_liniowej.pkl')

# Zapis skalera do pliku (aby później można było standaryzować dane użytkowników)
joblib.dump(scaler, 'scaler.pkl')

print("Model i scaler zostały zapisane!")