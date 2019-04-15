class CLI

  attr_accessor :farmer, :todays_crops # Actually current_user_id

  def initialize
    self.todays_crops = Plant.all.sample(3)
  end


  def welcome
    puts "Welcome to SDVCLI! Please enter your name! Type 'q' at any time to quit."
    name = self.input
    self.farmer = Farmer.find_by(name: name)

    if self.farmer
      self.main_screen
    else
      self.create_user(name)
    end
  end


  def create_user(name)
    puts "Can't find any farmers with that name. Would you like to make a new farmer? (y/n)"
    ans = self.input
    if ans == "y"
      self.farmer = Farmer.create(name: name)
      self.main_screen
    elsif ans == "n"
      self.welcome
    else
      puts "Not a valid option."
      self.create_user(name)
    end
  end


  def main_screen
    puts "Hello #{self.farmer.name}! Enter the option number you want to perform."
      puts "1.Check Crops"
      puts "2.Plant New Crops"
      puts "3.Sleep"
      puts "4.Log Out"
    input = self.input.to_i
    #list main_screen
    case input
    when 1
      puts "checked crops"  #checks crops
      self.check_crops_screen
    when 2
      puts "planted crops"  #plant new crop
      self.plant_crops_screen
    when 3
      puts "sleeping"  #sleep , increment day of all farmer_plants, reset #todays_crops
      self.sleep_screen
      # RESET todays_crops
    when 4
      puts "Logged Out #{self.farmer.name}"  #logout , sends back to homepage
      self.welcome
    else
      puts "Not a valid answer"
      self.main_screen
      #after x amount of times, put user to sleep
    end

  end


  def plant_crops_screen
    puts "These are the crops that are available today"

    self.todays_crops.pluck(:name).each_with_index do |crop, index|
      puts "#{index + 1}. #{crop}"
    end

    puts "Which of these crops would you like to plant? [1,2,3]"
    crop_choice = self.input.to_i

    until [1,2,3].include?(crop_choice)
      puts "Not a valid crop choice. Please choose a number in [1,2,3]"
      crop_choice = self.input.to_i
    end

    puts "where do you want to plant it? #{self.farmer.farmer_plants.pluck(:plot_number)}"
    plot_choice = self.input

    self.plant_crop(crop_choice, plot_choice)
    # FarmerPlant.new()
  end


  def plant_crop(crop_choice, plot_choice)

  end


  def input
    input = gets.chomp
    if input == 'q'
      self.quit
    else
      input
    end
  end


  def quit
    puts "Goodbye and thanks for visiting Stardew Valley!"
    exit
  end

end
