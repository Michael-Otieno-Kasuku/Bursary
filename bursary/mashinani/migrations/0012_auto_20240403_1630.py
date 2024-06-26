# Generated by Django 5.0.2 on 2024-04-03 13:30

from django.db import migrations
import openpyxl
from django.core.exceptions import ObjectDoesNotExist

def insert_students(apps, schema_editor):
    Student = apps.get_model('mashinani', 'Student')
    Institution = apps.get_model('mashinani', 'Institution')
    try:
        # Load data from Excel workbook
        wb = openpyxl.load_workbook('mashinani/data/data.xlsx')
        sheet = wb['Student']

        # Iterate over rows in the Excel sheet and extract students information
        students_data = []
        for row in sheet.iter_rows(min_row=2, values_only=True):  # Assuming data starts from second row
            national_id_no = row[0]  # Assuming National ID Number is in the first column
            institution_name= row[1]
            registration_number = row[2]
            first_name = row[3]
            last_name = row[4]

            # Fetch institutions objects from database
            try:
                institution = Institution.objects.get(institution_name=institution_name)
            except ObjectDoesNotExist as e:
                print(f"Error: {e}")
                continue  # Skip this row if institution or bank doesn't exist

            # Create dictionary for financial year data
            student_data = {
                'national_id_no': national_id_no,
                'institution_id': institution,
                'registration_number': registration_number,
                'first_name': first_name,
                'last_name': last_name,
            }
            
            # Append student data to list
            students_data.append(student_data)

        # Insert data into the model
        for data in students_data:
            Student.objects.create(**data)
    except FileNotFoundError:
        print("File not found. Please check the path to the Excel file.")
    except Exception as e:
        print(f"An error occurred: {e}")

class Migration(migrations.Migration):

    dependencies = [
        ('mashinani', '0011_auto_20240403_1618'),
    ]

    operations = [
        migrations.RunPython(insert_students)
    ]
