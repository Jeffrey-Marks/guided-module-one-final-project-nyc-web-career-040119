class CLI

  attr_accessor :farmer, :todays_crops # Actually current_user_id

  def initialize
    self.todays_crops = Plant.all.sample(3)
  end

  ##### COLOR SCHEME: LIGHT_GREEN, LIGHT_YELLOW, RED FOR WARNS
    # Headers, Queries, and Prompts: light_yellow
    # Info: green
    # Options: light_green
    # Warnings: red.blink


  ##### LOGIN SCREEN

  def welcome
    puts "★ ".light_yellow.blink + "Welcome to SDVCLI! Please enter your name!".light_yellow + "★".light_yellow.blink

    puts "      ★ ".red.blink + "Type 'q' at any time to quit.".red.blink + "★".red.blink
    name = self.input.downcase
    self.farmer = Farmer.find_by(name: name)

    if self.farmer
      ### REMOVE DEAD CROPS FROM TABLE HERE
      self.farmer.farmer_plants.reload.each do |fp|
        if !fp.alive
          puts "Your #{fp.plant.name} died while you were away... :(".red
          FarmerPlant.delete(fp.id)
        end
      end

      puts "Welcome back, #{self.farmer.display_name}!".light_yellow
      self.main_screen
    else
      self.create_user(name)
    end
  end


  def create_user(name)
    puts "Can't find any farmers with that name. Would you like to make a new farmer? (y/n)".light_yellow

    ans = self.get_valid_input(['y','n'], "Not a valid input")

    case ans
    when "y"
      self.farmer = Farmer.create(name: name, crops_harvested: 0)
      puts "Welcome to Stardew Valley, #{self.farmer.display_name}!".light_yellow
      ###Change name of farm
      self.main_screen
    when "n"
      self.welcome
    end
  end



  ##### MAIN SCREEN

  def main_screen
    puts "Enter the option number you want to perform.".light_yellow
      puts "1. Check Crops".light_green
      puts "2. Plant New Crops".light_green
      puts "3. Sleep (Slightly Grows All Crops)".light_green #SLIGHTLY GROWS (IF WATERED)
      # puts "4. Check Stats"
      puts "4. Log Out".light_green
    input = get_valid_input((1..4).to_a, "Not a valid option.")
    # input = get_valid_input_with_default([1,2,3,4], "Not a valid option.", self.sleep_screen, "You were plagued by indecision today. You stayed in bed.")

    case input
    when 1
      self.check_crops_screen
    when 2
      self.plant_crops_screen
    when 3
      self.sleep_screen
    when 4
      puts "Logged Out #{self.farmer.display_name}".green
      self.welcome
    end
  end



  ###### CHECK CROPS

  def check_crops_screen
    puts "Here are your crops:".light_yellow

    (1..5).to_a.each do |plot_num|
      puts "Plot #{plot_num}: #{self.whats_growing(plot_num)}".green
    end

    puts "What would you like to do?".light_yellow
    puts "1. Harvest Crops".light_green
    puts "2. Go Back to Main Screen".light_green

    ans = self.get_valid_input([1,2], "Not a valid command.".red)

    case ans
    when 1
      if self.farmer.farmer_plants.reload.empty?
        puts "No crops ready to harvest.".green
      end

      was_a_crop_harvested = false

      self.farmer.farmer_plants.reload.each do |fp|
        pct = pct_grown(fp)
        if fp.reload.alive && (pct >= 1.0)
          puts "You harvested your #{fp.plant.name} from Plot #{fp.plot_number}!".green
          FarmerPlant.delete(fp.id)
          self.farmer.update(crops_harvested: self.farmer.crops_harvested + 1)
          was_a_crop_harvested = true
          ####################### ADD MONEY
        elsif (fp == self.farmer.farmer_plants.order(:plot_number).last) && !was_a_crop_harvested
          puts "No crops ready to harvest.".green
        end
      end
      self.check_crops_screen
    when  2
      self.main_screen
    end
  end

  def whats_growing(plot_num)
    growing_here = self.farmer.farmer_plants.find_by_plot_number(plot_num)

    if growing_here
      "#{growing_here.plant.name} #{display_growth(growing_here)}"
    else
      "Empty".green
    end
  end

  def display_growth(farmer_plant)
    if farmer_plant.days_since_planted == 0
      "(0% grown)".green
    else
      pct = pct_grown(farmer_plant)
      # pct = farmer_plant.days_since_planted.to_f/farmer_plant.plant.days_to_grow.to_f
      if pct > 0.0 && pct < 0.25
        "(0% grown)".green
      elsif pct >= 0.25 && pct < 0.5
        "(25% grown)".green
      elsif pct >= 0.5 && pct < 0.75
        "(50% grown)".green
      elsif pct >= 0.75 && pct < 1
        "(75% grown)".green
      elsif pct >= 1
        "(Ready to harvest)".green.blink
      end
    end
  end



  ##### PLANT CROPS

  def plant_crops_screen
    puts "These are the crops that are available today".light_yellow

    self.todays_crops.pluck(:name).each_with_index do |crop, index|
      puts "#{index + 1}. #{crop}".light_green
    end

    puts "4. (Go Back)".light_green

    puts "Which of these crops would you like to plant? [1,2,3,4]".light_yellow
    crop_num = get_valid_input([1,2,3,4], "Not a valid crop choice.")

    if crop_num == 4
      self.main_screen
    end

    crop_choice = self.todays_crops[crop_num - 1]

    available_plots = (1..5).to_a - self.farmer.reload.farmer_plants.pluck(:plot_number)

    if !available_plots.empty?
      plots_str = available_plots.map {|plot_num| "Plot #{plot_num}"}.join(", ")
      puts "Which plot do you want to plant that #{crop_choice.name} in?".light_yellow
      puts "(Pick the number of the plot)".light_yellow
      puts "Available Plots: ".light_yellow + "(#{plots_str})".light_green

      # plot_num = get_valid_input([1,2,3,4,5], "That's not a plot!")
      plot_num = get_valid_input(available_plots, "That plot is full or it's not a valid plot choice!")

      self.plant_crop(crop_choice, plot_num)
    else
      puts "Sorry! No plots are available. Would you like to plant over an existing plot? (y/n)".light_yellow
      puts "WARNING! This will uproot the existing plant in that plot!".red.blink

      ans = self.get_valid_input(['y','n'], "That's not (y/n)...")

      case ans
      when 'y'
        puts "Which plot would you like to plant over?".light_yellow

        (1..5).to_a.each do |plot_num|
          puts "Plot #{plot_num}: #{self.whats_growing(plot_num)}".green
        end

        plot_num = self.get_valid_input((1..5).to_a, "That's not a plot!")

        fp = FarmerPlant.find_by(farmer: self.farmer, plot_number: plot_num)
        FarmerPlant.destroy(fp.id)

        self.plant_crop(crop_choice, plot_num)
      when 'n'
        self.main_screen
      end
    end

    puts "Planted #{crop_choice.name}! Would you like to plant more crops? (y/n)".light_yellow

    ans = self.get_valid_input(['y','n'], "Not a valid option.")

    case ans
    when "y"
      self.plant_crops_screen
    when "n"
      self.main_screen
    end
  end


  def plant_crop(crop_choice, plot_num)
    fp = FarmerPlant.create(farmer: self.farmer, plant: crop_choice, plot_number: plot_num, days_since_planted: 0, alive: 1)
    self.farmer.farmer_plants << fp
  end



  ### SLEEP SCREEN

  def sleep_screen  # Sleep , increment day of all farmer_plants
                    # Kills overgrown crops but only removes self.farmer's overgrown crops from DB
    FarmerPlant.update_all("days_since_planted = days_since_planted + 1")

    FarmerPlant.all.each do |fp|
      # pct = fp.reload.days_since_planted.to_f / fp.plant.days_to_grow.to_f
        pct = pct_grown(fp)
      if fp.reload.alive && (pct >= 1.0) && (pct < 3.0) && (fp.farmer == self.farmer)
        puts "Your #{fp.plant.name} in Plot #{fp.plot_number} is ready to harvest!".red
      elsif fp.reload.alive && (pct > 3.0)
        puts "#{fp.farmer.display_name}'s #{fp.plant.name} died!".red
        fp.update(alive: false)
        # fp.alive = false ### ONLY AFFECTS CLASS INSTANCE, DOESN'T PUSH CHANGES TO DB
        # fp.save
        if fp.farmer == self.farmer
          FarmerPlant.delete(fp.id)
        end
      end
    end

    self.todays_crops = Plant.all.sample(3)

    puts "You slept ".green + self.how_well_did_you_sleep

    self.main_screen
  end


  def how_well_did_you_sleep
    how_well = [
      "well!".green,
      "not well.".light_red,
      "ok...".light_yellow,
      "terribly. :(".red,
      "great!".light_green,
      "very well!".light_green,
      "like a baby!".light_green,
      "in today.".light_red,
      "too late last night. You're tired today...".red,
      "like an angel!".white.blink
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
    #insert 's' , show stats at any time
  end


  def get_valid_input(options, err_msg)
    ans = self.input
    until options.include?(ans)
      puts "#{err_msg} Please choose an option in #{options}.".red
      ans = self.input
    end
    ans
  end

  # def get_valid_input_with_default(options, err_msg, default_action, default_msg)
  #   ans = self.input
  #   i = 0
  #   until options.include?(ans)
  #     puts "#{err_msg} Please choose an option in #{options}.".red
  #     ans = self.input
  #     i += 1
  #     if i >= 5
  #       puts default_msg.red
  #       default_action
  #       # break
  #     end
  #   end
  # end

  #   end
  #   input
  # end

# helper method for pct
  def pct_grown(farmer_plant)
    farmer_plant.reload.days_since_planted.to_f / farmer_plant.plant.days_to_grow.to_f
  end

  def quit
    puts "★ ".light_yellow.blink + "Goodbye and thanks for visiting Stardew Valley!".light_yellow + "★".light_yellow.blink
    exit
  end

end
