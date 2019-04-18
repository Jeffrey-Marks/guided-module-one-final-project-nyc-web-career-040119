FarmerPlant.destroy_all
Plant.destroy_all


potato = Plant.find_or_create_by(name: "Potato", days_to_grow: 6, price: 50, sells_for: rand(60..105))
garlic = Plant.find_or_create_by(name: "Garlic", days_to_grow: 4, price: 40, sells_for: rand(50..90))
green_bean = Plant.find_or_create_by(name: "Green Bean", days_to_grow: 10, price: 60, sells_for: rand(100..135))
kale = Plant.find_or_create_by(name: "Kale", days_to_grow: 6, price: 70, sells_for: rand(100..155))
parsnip = Plant.find_or_create_by(name: "Parsnip", days_to_grow: 4, price: 20, sells_for: rand(25..35))
strawberry = Plant.find_or_create_by(name: "Strawberry", days_to_grow: 8, price: 50, sells_for: rand(50..150))
hot_pepper = Plant.find_or_create_by(name: "Hot Pepper", days_to_grow: 5, price: 40, sells_for: rand(60..95))
melon = Plant.find_or_create_by(name: "Melon", days_to_grow: 12, price: 110, sells_for: rand(150..300))
red_cabbage = Plant.find_or_create_by(name: "Red Cabbage", days_to_grow: 9, price: 90, sells_for: rand(150..210))
starfruit = Plant.find_or_create_by(name: "Starfruit", days_to_grow: 13, price: 450, sells_for: rand(850..1050))
wheat = Plant.find_or_create_by(name: "Wheat", days_to_grow: 2, price: 10, sells_for: 20)
yam = Plant.find_or_create_by(name: "Yam", days_to_grow: 3, price: 30, sells_for: rand(40..50))
pumpkin = Plant.find_or_create_by(name: "Pumpkin", days_to_grow: 12, price: 100, sells_for: rand(150..190))
egg_plant = Plant.find_or_create_by(name: "Egg Plant", days_to_grow: 5, price: 20, sells_for: rand(1..30))
bok_choy = Plant.find_or_create_by(name: "Bok Choy", days_to_grow: 3, price: 50, sells_for: rand(70..100))
beet = Plant.find_or_create_by(name: "Beet", days_to_grow: 7, price: 60, sells_for: rand(80..100))
ancient_fruit = Plant.find_or_create_by(name: "Ancient Fruit", days_to_grow: 15, price: 550, sells_for: rand(1000..1300))


jeff = Farmer.find_or_create_by(name: "jeff", abducted: true)
jacob = Farmer.find_or_create_by(name: "jacob")
hobo = Farmer.find_or_create_by(name: "hobo", money: 0)

FarmerPlant.find_or_create_by(farmer: hobo, plant: wheat, plot_number: 1, days_since_planted: 50, alive: false)
