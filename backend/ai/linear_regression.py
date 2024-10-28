import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# Wczytanie danych z pliku CSV
df = pd.read_csv('aug_personal_transactions_with_UserId.csv')

# Przekształcenie kwoty na typ liczbowy
df['Amount'] = df['Amount'].replace('[\$,]', '', regex=True).astype(float)

# Przypisanie wartości 'debit' (wydatki) jako ujemne, a 'credit' (przychody) jako dodatnie
df['Transaction Type'] = df['Transaction Type'].map({'debit': -1, 'credit': 1})

# Konwersja daty na format daty i wyciągnięcie roku oraz miesiąca
df['Date'] = pd.to_datetime(df['Date'])
df['YearMonth'] = df['Date'].dt.to_period('M')  # Utworzenie kolumny z miesiącem i rokiem

# Obliczamy osobno sumę przychodów i wydatków dla każdego miesiąca

# Filtrujemy transakcje typu 'credit' jako przychody
income = df[df['Transaction Type'] == 1].groupby('YearMonth')['Amount'].sum().reset_index()

# Filtrujemy transakcje typu 'debit' jako wydatki
expenses = df[df['Transaction Type'] == -1].groupby('YearMonth')['Amount'].sum().reset_index()

# Łączymy przychody i wydatki w jeden dataframe na podstawie 'YearMonth'
monthly_data = pd.merge(income, expenses, on='YearMonth', how='outer', suffixes=('_income', '_expenses'))

# Zmieniamy nazwy kolumn
monthly_data.rename(columns={'Amount_income': 'income', 'Amount_expenses': 'expenses'}, inplace=True)

# Uzupełniamy ewentualne wartości NaN zerami (jeśli w danym miesiącu były tylko przychody lub tylko wydatki)
monthly_data.fillna(0, inplace=True)

# Obliczamy oszczędności jako różnicę między przychodami a wydatkami
monthly_data['savings'] = monthly_data['income'] - monthly_data['expenses']

# Wyświetlenie danych miesięcznych
print(monthly_data)

print("------------------------------")

# Zmienne niezależne: income i expenses z historycznych danych
X = monthly_data[['income', 'expenses']]

# Zmienna zależna: savings
y = monthly_data['savings']

# Podział danych na zbiór treningowy i testowy
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
predictions = pd.DataFrame({'Rzeczywiste oszczędności': y_test, 'Prognozowane oszczędności': y_pred})
print(predictions)

# Wykres rzeczywistych vs prognozowanych oszczędności
plt.scatter(y_test, y_pred)
plt.xlabel("Rzeczywiste oszczędności")
plt.ylabel("Prognozowane oszczędności")
plt.title("Rzeczywiste vs Prognozowane oszczędności (Regresja Liniowa)")
plt.show()

# Zapis modelu do pliku
joblib.dump(model, 'model_regresji_liniowej.pkl')

# Zapis skalera do pliku (aby później można było standaryzować dane użytkowników)
joblib.dump(scaler, 'scaler.pkl')

print("Model i scaler zostały zapisane!")
