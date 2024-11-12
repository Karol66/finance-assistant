import csv

def remove_polish_chars(text):
    replacements = {
        'ą': 'a', 'ć': 'c', 'ę': 'e', 'ł': 'l', 'ń': 'n', 'ó': 'o', 'ś': 's', 'ż': 'z', 'ź': 'z',
        'Ą': 'A', 'Ć': 'C', 'Ę': 'E', 'Ł': 'L', 'Ń': 'N', 'Ó': 'O', 'Ś': 'S', 'Ż': 'Z', 'Ź': 'Z'
    }
    for polish_char, replacement_char in replacements.items():
        text = text.replace(polish_char, replacement_char)
    return text

input_file = 'source_data.csv'
output_file = 'data.csv'

with open(input_file, 'r', newline='') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    headers = next(reader)
    writer.writerow([remove_polish_chars(headers[0]), remove_polish_chars(headers[2]), remove_polish_chars(headers[3]), remove_polish_chars(headers[5])])

    for row in reader:
        writer.writerow([remove_polish_chars(row[0]), remove_polish_chars(row[2]), remove_polish_chars(row[3]), remove_polish_chars(row[5])])