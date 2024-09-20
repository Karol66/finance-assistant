import joblib
import numpy as np

# Ładowanie wytrenowanego modelu
model = joblib.load('model_regresji_liniowej.pkl')

# Ładowanie skalera
scaler = joblib.load('scaler.pkl')


def przewiduj_oszczednosci(przychody_uzytkownika, wydatki_uzytkownika):
    # Standaryzacja danych wejściowych użytkownika
    dane_uzytkownika = np.array([[przychody_uzytkownika, wydatki_uzytkownika]])
    dane_uzytkownika_scaled = scaler.transform(dane_uzytkownika)

    # Prognozowanie oszczędności na podstawie danych użytkownika
    prognozowane_oszczednosci = model.predict(dane_uzytkownika_scaled)

    return prognozowane_oszczednosci[0]


# Przykład: użytkownik wprowadza swoje dane
przychody = 5200  # np. 5200 zł przychodu
wydatki = 3500  # np. 3500 zł wydatków

prognozowane_oszczednosci = przewiduj_oszczednosci(przychody, wydatki)
print(f"Prognozowane oszczędności: {prognozowane_oszczednosci:.2f} zł")
