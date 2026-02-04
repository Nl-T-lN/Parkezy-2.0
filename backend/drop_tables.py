import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'parkezy_backend.settings')
django.setup()

from django.db import connection

cursor = connection.cursor()
cursor.execute('''
    DROP TABLE IF EXISTS 
        parking_spots, 
        commercial_parking_facilities, 
        commercial_parking_slots, 
        private_parking_listings, 
        private_parking_slots 
    CASCADE
''')
print('Tables dropped successfully')
