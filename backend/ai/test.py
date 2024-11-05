import pandas as pd
import numpy as np

# Wczytaj plik CSV
file_path = 'aug_personal_transactions_with_UserId.csv'  # Zmień tę ścieżkę na odpowiednią dla Twojego pliku
df = pd.read_csv(file_path)

# Usuwanie wierszy, gdzie 'Category' jest różne od 'Paycheck' i 'Transaction Type' jest 'credit'
df = df[~((df['Category'] != 'Paycheck') & (df['Transaction Type'] == 'credit'))].reset_index(drop=True)

# Funkcja do przypisywania brakujących ID na podstawie sąsiednich wartości
def fill_user_ids(row, last_id):
    if pd.isnull(row['User ID']):
        # Losowy wybór, jeśli brak poprzedniego ID lub jeśli last_id jest ustawione, ale chcemy losować co każde puste ID
        return np.random.choice([1, 2, 3])
    return row['User ID']

# Przechodzimy przez każdy wiersz, uzupełniając ID tylko od wiersza 807
for i, row in df.iterrows():
    if i >= 806:  # zaczynamy od wiersza 807 (indeks 806)
        df.at[i, 'User ID'] = fill_user_ids(row, df.at[i-1, 'User ID'] if i > 806 else None)

# Zapisz zmieniony plik
output_path = 'plik_z_uzupelnionym_id.csv'
df.to_csv(output_path, index=False)

print(f"Plik z uzupełnionymi wartościami User ID zapisano jako {output_path}.")
