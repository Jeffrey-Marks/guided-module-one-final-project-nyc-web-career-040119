require_relative '../config/environment'


test = CLI.new
test.farmer = Farmer.find_by_name("Jeff")
test.plant_crop_screen
CLI.new.welcome


# binding.pry

# CLI.new.start

# OR

# CLI.start
