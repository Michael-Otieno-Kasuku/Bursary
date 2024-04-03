# Generated by Django 5.0.2 on 2024-04-03 10:40

from django.db import migrations
import openpyxl
from django.core.exceptions import ObjectDoesNotExist

def insert_account_data(apps, schema_editor):
    Account = apps.get_model('mashinani', 'Account')
    Institution = apps.get_model('mashinani', 'Institution')
    Bank = apps.get_model('mashinani', 'Bank')

    try:
        # Load data from Excel workbook
        wb = openpyxl.load_workbook('mashinani/data/data.xlsx')
        sheet = wb['Account']

        # Iterate over rows in the Excel sheet and extract account information
        accounts_data = []
        for row in sheet.iter_rows(min_row=2, values_only=True):  # Assuming data starts from second row
            institution_name = row[0]  # Assuming institution name is in the first column
            bank_name = row[1]  # Assuming bank name is in the second column
            account_number = row[2]  # Assuming account number is in the third column
            
            # Fetch institution and bank objects from database
            try:
                institution = Institution.objects.get(institution_name=institution_name)
                bank = Bank.objects.get(bank_name=bank_name)
            except ObjectDoesNotExist as e:
                print(f"Error: {e}")
                continue  # Skip this row if institution or bank doesn't exist
            
            # Create dictionary for account data
            account_data = {
                'institution_id': institution,
                'bank_id': bank,
                'account_number': account_number
            }
            
            # Append account data to list
            accounts_data.append(account_data)

        # Insert data into the model
        for data in accounts_data:
            Account.objects.create(**data)
    except FileNotFoundError:
        print("File not found. Please check the path to the Excel file.")
    except Exception as e:
        print(f"An error occurred: {e}")

class Migration(migrations.Migration):

    dependencies = [
        ('mashinani', '0003_auto_20240403_1338'),
    ]

    operations = [
        migrations.RunPython(insert_account_data)
    ]
