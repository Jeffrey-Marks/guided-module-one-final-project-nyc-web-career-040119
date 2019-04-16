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
    crop_num = self.input.to_i

    until [1,2,3].include?(crop_num)
      puts "Not a valid crop choice. Please choose a number in [1,2,3]."
      crop_num = self.input.to_i
    end

    crop_choice = self.todays_crops[crop_num - 1]

    available_plots = [1,2,3,4,5] - self.farmer.farmer_plants.pluck(:plot_number)
    puts "where do you want to plant it? #{available_plots}"

    plot_num = self.input

    until available_plots.include?(plot_num.to_i)
      binding.pry
      puts "That plot is full! Please choose a number in #{available_plots}."
      plot_num = self.input

      ### ADD FUNCTIONALITY TO PLANT OVER
    end

    self.plant_crop(crop_choice, plot_num)

    puts "Planted #{crop_choice.name}! Would you like to plant more crops? (y/n)"
    ans = self.input

    if ans == "y"
      self.plant_crops_screen
    elsif ans == "n"
      self.main_screen
    else
      puts "Not a valid answer, returning to main screen..."
      self.main_screen
    end
  end


  def plant_crop(crop_choice, plot_num)
    fp = FarmerPlant.create(farmer: self.farmer, plant: crop_choice, plot_number: plot_num, days_since_planted: 0, alive: 1)
    self.farmer.farmer_plants << fp
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
