from faker import Faker
import csv
import random
import datetime
import io
from google.cloud import storage

def generate_epfl_student_data(request):
    """Generates dummy data and saves it to Cloud Storage."""

    fake = Faker()

    # Field names (important: define these *outside* the loop)
    fieldnames = ['year', 'student_count', 'department', 'phd_student_count',
                  'average_age', 'international_percentage', 'country', 'continent']

    output = io.StringIO()  # String buffer
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    writer.writeheader()

    start_year = 1975
    current_year = datetime.datetime.now().year

    for year in range(start_year, current_year + 1):
        base_students = 1000
        student_count = int(base_students + (year - start_year) * 150 + random.randint(-200, 200))
        student_count = max(0, student_count)

        phd_student_count = int(student_count * random.uniform(0.15, 0.25))

        departments = ['STI', 'SB', 'IC', 'ENAC', 'FBM', 'SHS']
        average_age = round(22 + (year - start_year) * 0.1 + random.uniform(-1, 1), 1)
        average_age = max(18, min(30, average_age))

        swiss_percentage = 0.85 - (year - start_year) * (0.85 - 0.58) / (current_year - start_year)
        swiss_percentage = max(0.58, swiss_percentage)

        for _ in range(student_count):
            department = random.choice(departments)
            international_percentage = round(random.uniform(0.2, 0.6), 2)

            if random.random() < swiss_percentage:
                country = "Switzerland"
                continent = "Europe"
            else:
                country = fake.country()
                continent = fake.continent()

            row = {
                'year': year,
                'student_count': 1,
                'department': department,
                'phd_student_count': 1 if random.random() < (phd_student_count / student_count) else 0,
                'average_age': average_age + random.uniform(-2, 2),
                'international_percentage': international_percentage,
                'country': country,
                'continent': continent
            }
            writer.writerow(row)  # Write to the string buffer

    # Upload to Cloud Storage
    client = storage.Client()
    bucket_name = "inputs-pub-data"
    blob_name = "inputs/epfl_student_data.csv"
    blob = bucket.blob(blob_name)

    output.seek(0)  # Reset the buffer's position
    blob.upload_from_file(output, content_type='text/csv')

    return "Data generated and saved to gs://{}/{}".format(bucket_name, blob_name)