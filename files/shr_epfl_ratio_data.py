from faker import Faker
import csv
import random
import datetime

def generate_epfl_data_local(output_filename="epfl_employee_student_data.csv"):
    """Generates dummy data for EPFL employee and student numbers locally."""

    fake = Faker()

    fieldnames = ['year', 'student_count', 'employee_count']

    with open(output_filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        start_year = 1975
        end_year = 2025  # Explicitly set the end year

        for year in range(start_year, end_year + 1):
            # Simulate student count evolution (replace with a better model if available)
            base_students = 1000
            student_count = int(base_students + (year - start_year) * 150 + random.randint(-200, 200))
            student_count = max(0, student_count)

            # Simulate employee count evolution (replace with a better model if available)
            base_employees = 200  # Example base, adjust as needed
            employee_count = int(base_employees + (year - start_year) * 30 + random.randint(-50, 50))
            employee_count = max(0, employee_count)  # Ensure it is not negative

            row = {
                'year': year,
                'student_count': student_count,
                'employee_count': employee_count
            }
            writer.writerow(row)

    print(f"CSV file generated at {output_filename}")


if __name__ == "__main__":
    generate_epfl_data_local()  # You can specify the filename if needed.