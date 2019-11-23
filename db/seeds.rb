# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

booth1 = Booth.create(name: 'Booth #1')
booth2 = Booth.create(name: 'Booth #2')

scale1 = Scale.create(name: 'winesphereScale01', booth: booth1)
scale2 = Scale.create(name: 'winesphereScale02', booth: booth2)

thermo1 = Thermometer.create(name: 'winesphereTemp01', booth: booth1)
thermo2 = Thermometer.create(name: 'winesphereTemp02', booth: booth2)
