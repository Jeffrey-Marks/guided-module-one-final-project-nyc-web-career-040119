class CLI

  attr_accessor :farmer, :todays_crops # Actually current_user_id

  def initialize
    self.todays_crops = Plant.all.sample(3)
  end



  ##### LOGIN SCREEN

  def welcome
    puts "Welcome to SDVCLI! Please enter your name! Type 'q' at any time to quit."
    name = self.input
    self.farmer = Farmer.find_by(name: name)

    if self.farmer
      ### REMOVE DEAD CROPS FROM TABLE HERE
      self.farmer.farmer_plants.reload.each do |fp|
        if !fp.alive
          puts "Your #{fp.plant.name} died while you were away... :("
          FarmerPlant.delete(fp.id)
        end
      end

      self.main_screen
    else
      self.create_user(name)
    end
  end


  def create_user(name)
    puts "Can't find any farmers with that name. Would you like to make a new farmer? (y/n)"
    ans = self.input
    if ans == "y"
      self.farmer = Farmer.create(name: name, crops_harvested: 0)
      self.main_screen
    elsif ans == "n"
      self.welcome
    else
      puts "Not a valid option."
      self.create_user(name)
    end
  end



  ##### MAIN SCREEN

  def main_screen
    puts "Hello #{self.farmer.name}! Enter the option number you want to perform."
      puts "1.Check Crops"
      puts "2.Plant New Crops"
      puts "3.Sleep"
      puts "4.Log Out"
    input = self.input
    #list main_screen
    case input
    when 1
      #checks crops
      self.check_crops_screen
    when 2
      #plant new crop
      self.plant_crops_screen
    when 3
      #sleep , increment day of all farmer_plants, reset #todays_crops
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



  ###### CHECK CROPS

  def check_crops_screen
    puts "Here are your crops:"

    (1..5).to_a.each do |plot_num|
      puts "Plot #{plot_num}: #{self.whats_growing(plot_num)}"
    end

    puts "What would you like to do?"
    puts "1. Harvest Crops"
    puts "2. Go Back to Main Screen"

    ans = self.input

    self.input_valid?([1,2], ans, "Not a valid command.")
    # until [1,2].include?(ans)
    #   puts "Not a valid command. Please choose a number in [1,2]."
    #   ans = self.input
    # end

    if ans == 1
        #harvest crops
    elsif ans == 2
      self.main_screen
    end
  end

  def whats_growing(plot_num)
    growing_here = self.farmer.farmer_plants.find_by_plot_number(plot_num)

    if growing_here
      "#{growing_here.plant.name} #{percent_grown(growing_here)}"
    else
      "Empty"
    end
  end

  def percent_grown(farmer_plant)
    if farmer_plant.days_since_planted == 0
      "(0% grown)"
    else
      pct = farmer_plant.days_since_planted.to_f/farmer_plant.plant.days_to_grow.to_f
      if pct > 0.0 && pct < 0.25
        "(0% grown)"
      elsif pct >= 0.25 && pct < 0.5
        "(25% grown)"
      elsif pct >= 0.5 && pct < 0.75
        "(50% grown)"
      elsif pct >= 0.75 && pct < 1
        "(75% grown)"
      elsif pct >= 1
        "(Ready to harvest)"
      end
    end
  end



  ##### PLANT CROPS

  def plant_crops_screen
    puts "These are the crops that are available today"

    self.todays_crops.pluck(:name).each_with_index do |crop, index|
      puts "#{index + 1}. #{crop}"
    end

    puts "Which of these crops would you like to plant? [1,2,3]"
    crop_num = self.input

    until [1,2,3].include?(crop_num)
      puts "Not a valid crop choice. Please choose a number in [1,2,3]."
      crop_num = self.input
    end

    crop_choice = self.todays_crops[crop_num - 1]

    available_plots = [1,2,3,4,5] - self.farmer.reload.farmer_plants.pluck(:plot_number)
    puts "where do you want to plant it? #{available_plots}"

    plot_num = self.input

    until available_plots.include?(plot_num.to_i)
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



  ### SLEEP SCREEN

  def sleep_screen
    FarmerPlant.update_all("days_since_planted = days_since_planted + 1")

    FarmerPlant.all.each do |fp|
      pct = fp.reload.days_since_planted.to_f / fp.plant.days_to_grow.to_f
      if (fp.reload.alive == true) && (pct > 3.0)
        puts "#{fp.farmer.name}'s #{fp.plant.name} died!"
        fp.update(alive: false)
        # fp.alive = false ### ONLY AFFECTS CLASS INSTANCE, DOESN'T PUSH CHANGES TO DB
        # fp.save
        if fp.farmer == self.farmer
          FarmerPlant.delete(fp.id)
        end
      end
    end

    self.todays_crops = Plant.all.sample(3)

    puts "You slept #{self.how_well_did_you_sleep}"

    self.main_screen
    #sleep , increment day of all farmer_plants, kill overgrown crops
  end


  def how_well_did_you_sleep
    how_well = [
      "well!",
      "not well.",
      "ok...",
      "terribly. :(",
      "great!",
      "very well!",
      "like a baby.",
      "in today.",
      "too late last night. You're tired today..."
    ]
    how_well.sample
  end


  ### GLOBAL METHODS


  def input
    input = gets.chomp
    if input == 'q'
      self.quit
    else
      ('0'..'9').to_a.include?(input) ? input.to_i : input
    end
  end


  def input_valid?(arr, input, err_msg)
    until arr.include?(input)
      puts "#{err_msg} Please choose a number in #{arr}."
      input = self.input
    end
    input
  end


  def quit
    puts "Goodbye and thanks for visiting Stardew Valley!"
    exit
  end

end
