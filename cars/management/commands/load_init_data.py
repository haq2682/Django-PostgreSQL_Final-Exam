from django.core.management.base import BaseCommand
from cars.models import Driver, Car


class Command(BaseCommand):
    help = "Load initial drivers and cars"

    def handle(self, *args, **kwargs):
        Driver.objects.get_or_create(name="John Doe", license="Z1234567")
        Driver.objects.get_or_create(name="Jane Doe", license="Z9876543")
        Car.objects.get_or_create(
            make="Ford",
            model="F-150",
            year=2004,
            vin="01083da2df15d6ebfe62186418a76863",
            owner_id=1,
        )
        Car.objects.get_or_create(
            make="Toyota",
            model="Sienna",
            year=2014,
            vin="53092a17afa460689ca931f0d459e399",
            owner_id=1,
        )
        Car.objects.get_or_create(
            make="Honda",
            model="Civic",
            year=2018,
            vin="844c56840b5fc26d414cf238381a5f1a",
            owner_id=2,
        )
        Car.objects.get_or_create(
            make="GMC",
            model="Sierra",
            year=2012,
            vin="29aeffa4d5aa21d25d7196db3728f72c",
            owner_id=2,
        )
