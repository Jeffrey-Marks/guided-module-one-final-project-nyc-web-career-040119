class CLI
  attr_accessor :farmer, :todays_crops, :todays_luck  # Actually current_user_id

  def initialize
    self.todays_crops = Plant.all.sample(3)
    self.todays_luck = 1.0
  end

  ##### COLOR SCHEME: LIGHT_GREEN, LIGHT_YELLOW, RED FOR WARNS
    # Headers, Queries, and Prompts: light_yellow
    # Info: green
    # Options: light_green
    # Warnings: red.blink



  ##### LOGIN SCREEN

  def welcome
    Catpix::print_image "lib/stardew_valley.png", limit_x: 0.5

    prompt = TTY::Prompt.new
    ans = prompt.select("", ["Login", "Quit"])

    if ans == "Login"
      puts "Please enter your name!".light_yellow
      name = self.input
      name.is_a?(String) ? name = name.downcase : name
      self.farmer = Farmer.find_by(name: name)

      if self.farmer && self.farmer.abducted
        self.abduction_screen
      elsif self.farmer
        self.login
      else
        self.create_user(name)
      end
    elsif ans == "Quit"
      self.quit
    end
  end


  def login
    self.farmer.farmer_plants.reload.each do |fp|
      if !fp.alive
        puts "Your #{fp.plant.name} died while you were away... :(".red
        FarmerPlant.delete(fp.id)
      end
    end

    if self.farmer.farmer_plants.reload.empty? && self.farmer.reload.money <= 20
      sleep(3)
      puts "Your dream of becoming a farmer has failed. You move back in with your parents."
      self.farmer.delete
      self.quit
    end


    puts "Welcome back, #{self.farmer.display_name}!".light_yellow
    self.main_screen
  end


  def abduction_screen
    sleep(3)
    self.abducted_animation(self.farmer.display_name)

    puts "\nMissing people:".red
    Farmer.abducted.each_with_index do |farmer|
      puts " - #{farmer.display_name}".red
    end

    sleep(7.5)

    system('clear')
  end


  def create_user(name)
    prompt = TTY::Prompt.new
    puts "Can't find any farmers with that name.".light_yellow

    ans = prompt.select("Make a new farmer with that name?".light_yellow,['Yes','No'])

    case ans
    when "Yes"

      self.farmer = Farmer.create(name: name)
      puts "Welcome to Stardew Valley, #{self.farmer.display_name}!".light_yellow
      ###Change name of farm
      self.main_screen
    when "No"
      self.welcome
    end
  end



  ##### MAIN SCREEN

  def main_screen
    self.divider
    prompt = TTY::Prompt.new
    # puts "Enter the option number you want to perform.".light_yellow
    ans = prompt.select("What would you like to do today?".light_yellow, [
      "Check Crops", "Plant New Crops", "Sleep (Slightly Grows All Crops)", "Check Stats", "Log Out"
    ])
    # puts "1. Check Crops".light_green
    # puts "2. Plant New Crops".light_green
    # puts "3. Sleep (Slightly Grows All Crops)".light_green #SLIGHTLY GROWS (IF WATERED)
    # puts "4. Check Stats".light_green
    # puts "5. Log Out".light_green
    # input = get_valid_input((1..5).to_a, "Not a valid option.")
    # input = get_valid_input_with_default([1,2,3,4], "Not a valid option.", self.sleep_screen, "You were plagued by indecision today. You stayed in bed.")

    case ans
    when "Check Crops"
      self.check_crops_screen
    when "Plant New Crops"
      self.plant_crops_screen
    when "Sleep (Slightly Grows All Crops)"
      self.sleep_screen
    when "Check Stats"
      self.stats_screen
    when "Log Out"
      puts "Logged Out #{self.farmer.display_name}".green
      self.welcome
    end
  end



  ###### CHECK CROPS

  def check_crops_screen
    self.divider
    puts "Here are your crops:".light_yellow

    (1..5).to_a.each do |plot_num|
      puts "Plot #{plot_num}: #{self.whats_growing(plot_num)}".green
    end

    prompt = TTY::Prompt.new
    ans = prompt.select("What would you like to do?".light_yellow, ["Harvest Crops", "Go Back to Main Screen"])
    # puts "What would you like to do?".light_yellow
    # puts "1. Harvest Crops".light_green
    # puts "2. Go Back to Main Screen".light_green

    # ans = self.get_valid_input([1,2], "Not a valid command.".red)

    case ans
    when "Harvest Crops"
      if self.farmer.farmer_plants.reload.empty?

        puts "No crops ready to harvest.".green
      end

      was_a_crop_harvested = false

      self.farmer.farmer_plants.reload.each do |fp|
        pct = pct_grown(fp)
        if fp.reload.alive && (pct >= 1.0)
          ### ADD LUCK MULTIPLIER TO SELL PRICE
          sold_for = (fp.plant.sells_for * self.todays_luck).floor
          puts "You harvested your #{fp.plant.name} from Plot #{fp.plot_number} for $#{sold_for}!".green
          self.farmer.update(crops_harvested: self.farmer.crops_harvested + 1, money: self.farmer.money + sold_for, total_money_earned: self.farmer.total_money_earned + sold_for)
          FarmerPlant.delete(fp.id)
          was_a_crop_harvested = true
          ####################### ADD MONEY
        elsif (fp == self.farmer.farmer_plants.last) && !was_a_crop_harvested
          puts "No crops ready to harvest.".green
        end
      end
      self.check_crops_screen
    when "Go Back to Main Screen"

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
    self.divider
    prompt = TTY::Prompt.new

    puts "These are the crops that are available today".light_yellow
    puts "You have".green + " $#{self.farmer.money}.".white


    self.todays_crops.each do |crop|
      puts "#{crop.name} ($#{crop.price})".light_green
    end
    # self.todays_crops.each_with_index do |crop, index|
    #   puts "#{index + 1}. #{crop.name} ($#{crop.price})".light_green
    # end

    # puts "4. (Go Back)".light_green

    # puts "Which crop would you like to plant?".light_yellow
    # crop_num = get_valid_input([1,2,3,4], "Not a valid crop choice.")
    crop_names = self.todays_crops.pluck(:name)
    # crop_names = crop_names.map{|name| name.light_green}

    crop_choice = prompt.select("Which crop would you like to plant?".light_yellow, [crop_names, "(Go Back)"].flatten)
    # get_valid_input([1,2,3,4], "Not a valid crop choice.")



    if crop_choice == "(Go Back)"
      self.main_screen
    end

    # crop_choice = self.todays_crops[crop_num - 1]
    #Strip colorize formatting with [10..-1][0..-5]
    if self.farmer.money < Plant.find_by_name(crop_choice).price
      puts "You don't have enough money to buy #{crop_choice} right now...".red
      self.plant_crops_screen
    end

    available_plots = ((1..5).to_a - self.farmer.reload.farmer_plants.pluck(:plot_number)).map{|num| "Plot #{num}"}

    if !available_plots.empty?
      # plots_str = available_plots.map {|plot_num| "Plot #{plot_num}"}.join(", ")
      # puts "Which plot do you want to plant that #{crop_choice} in?".light_yellow

      plot_choice = prompt.select("Which plot do you want to plant that #{crop_choice} in?".light_yellow, [available_plots])
      plot_num = plot_choice[5]
      # puts "(Pick the number of the plot)".light_yellow
      # puts "Available Plots: ".light_yellow + "(#{plots_str})".light_green
      #
      # plot_num = get_valid_input(available_plots, "That plot is full or it's not a valid plot choice!")

      self.plant_crop(Plant.find_by_name(crop_choice), plot_num)
    else
      puts "Sorry! No plots are available. Would you like to plant over an existing plot?".light_yellow
      puts "WARNING! This will uproot the existing plant in that plot!".red.blink

      yesno = prompt.select("a".hide,['Yes','No'])
      # ans = self.get_valid_input(['y','n'], "That's not (y/n)...")

      case yesno
      when "Yes"
        puts "Which plot would you like to plant over?".light_yellow

        (1..5).to_a.each do |plot_num|
          puts "Plot #{plot_num}: #{self.whats_growing(plot_num)}".green
        end

        ans = prompt.select("", ('1'..'5').to_a).to_i
        # plot_num = self.get_valid_input((1..5).to_a, "That's not a plot!")

        fp = FarmerPlant.find_by(farmer: self.farmer, plot_number: ans)
        FarmerPlant.destroy(fp.id)
        self.plant_crop(Plant.find_by_name(crop_choice), ans)

      when "No"
        self.main_screen
      end
    end

    # puts "Planted #{crop_choice}! You have $#{self.farmer.money}. Would you like to plant more crops? (y/n)".light_yellow

    ans = prompt.select("Planted #{crop_choice}! You have $#{self.farmer.money}. Would you like to plant more crops?".light_yellow, ["Yes", "No"])

    case ans
    when "Yes"
      self.plant_crops_screen
    when "No"
      self.main_screen
    end
  end


  def plant_crop(crop_choice, plot_num)
    fp = FarmerPlant.create(farmer: self.farmer, plant: crop_choice, plot_number: plot_num)
    self.farmer.farmer_plants << fp
    self.farmer.update(money: self.farmer.money - crop_choice.price)
  end



  ### SLEEP SCREEN

  def sleep_screen  # Sleep , increment day of all farmer_plants
                    # Kills overgrown crops but only removes self.farmer's overgrown crops from DB
    # self.divider
    FarmerPlant.update_all("days_since_planted = days_since_planted + 1")
    self.random_event
    FarmerPlant.all.each do |fp|
      # pct = fp.reload.days_since_planted.to_f / fp.plant.days_to_grow.to_f
        pct = pct_grown(fp)
      if fp.reload.alive && (pct >= 1.0) && (pct < 3.0) && (fp.farmer == self.farmer)
        puts "Your #{fp.plant.name} in Plot #{fp.plot_number} is ready to harvest!".green.blink
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

    # puts "You slept ".green +
    self.how_well_did_you_sleep
    #random event
    self.main_screen
  end


  def random_event
    num = rand(1..100)
    lightning = (1..20).to_a
    aliens = [42,43,44]
    mother_nature = (50..55).to_a
    morpheus = [99,100]

    if lightning.include?(num)
      self.lightning
    elsif aliens.include?(num)
      self.aliens
    elsif mother_nature.include?(num)
      self.mother_nature
    elsif morpheus.include?(num)
      self.morpheus
      exit
    end
  end


  def lightning
    num = rand(1..5)
    plot_hit = self.farmer.farmer_plants.find_by(plot_number: num)

    if plot_hit
      puts  "Lightning struck last night! It vaporized your #{plot_hit.plant.name} in Plot #{num} :C ".red.blink
      FarmerPlant.delete(plot_hit.id)
    else
      puts "Lightning struck last night!".red + " Luckily nothing was planted in Plot #{num}".green
    end

  end


  def aliens
     alien_test_subject = Farmer.where(abducted: false).where.not(id: self.farmer.id).sample
     if alien_test_subject
       alien_test_subject.update(abducted: true)
       puts  "#{alien_test_subject.display_name} disappeared in the middle of the night.".red.blink
       # alien_test_subject.farmer_plants.destroy_all
     end
   end


  def abducted_animation(name)
    str = "\"Hello I'm from another planet. Please come with me.\"" #.red
    alien_str = (1..53).to_a.map{(32..126).to_a.sample.chr}.join
    abducted = "\n.........#{name} disappeared in the middle of the night." #.red

    (0..str.length).to_a.each do |loc|
      system('clear')
      puts alien_str[0..loc].light_magenta
      sleep(0.05)
    end

    sleep(2)

    (0..str.length-1).to_a.each do |loc|
      system('clear')
      puts str[0..loc].red + alien_str[loc+1..str.length].light_magenta
      sleep(0.05)
    end

    sleep(2)

    (str.length..str.length+abducted.length).to_a.each do |loc|
      system('clear')
      puts (str + abducted)[0..loc].red
      sleep(0.05)
    end
  end


  def mother_nature
    farmer.farmer_plants.each do |fp|
      fp.update(days_since_planted: fp.plant.days_to_grow )
    end
    puts "Mother Nature paid you a visit last night".green.blink
  end


  def morpheus
    3.times do
      puts "*knock*".red
      sleep(1)
    end

    puts "A strange man is at your door...".green
    sleep(2)
    # puts  "Do you choose to open the door? (y/n)".light_yellow
    # ans = get_valid_input(['y','n'], "Not (y/n).")
    # until ans == 'y'
    #   puts  "Do you choose to open the door? (y)".light_yellow
    #   ans = self.input
    # end
    prompt = TTY::Prompt.new
    first_ans = prompt.select("Do you choose to open the door?".light_yellow, ["Yes", "No"])

    if first_ans == "No"
      sleep(2)
      3.times do
        puts "*KNOCK*".red
        sleep(0.75)
      end

      second_ans = prompt.select("Are you sure you don't want to answer that? It seems important.".light_yellow, ['Yes','No'])

      if second_ans == "No"
        sleep(2)
        3.times do
          puts "*BANG*".white.on_red
          sleep(0.50)
        end

        third_ans = prompt.select("Your door nearly comes off of its hinges. You should that probably.".light_yellow, ["Answer your door."])
      end
    end
    Catpix::print_image "lib/morpheus.jpg", limit_x: 0.25

    puts "\"You take the ".green + "blue pill".light_cyan + " - the story ends, you wake up in your bed and ".green
    puts "believe whatever you want to believe. You take the".green + " red pill".red + " - you stay".green
    puts "in Wonderland, and I show you how ".green + "deep".white.on_black + " the rabbit hole goes.".green
    puts "Remember: all I'm offering is ".green + "the truth".light_yellow + ". Nothing more.\"".green

    # ans = get_valid_input(["blue","red"],"blue or red")
    prompt = TTY::Prompt.new
    ans = prompt.select(">",["Blue pill".light_cyan, "Red pill".red])

    if ans == "Blue pill".light_cyan
      puts "You had a strange dream last night, but you can't quite remember...".green
      self.todays_luck = 2.2
      self.main_screen
    elsif ans == "Red pill".red
      self.down_the_rabbit_hole
    end
  end


  def down_the_rabbit_hole
    colors = ["red", "yellow", "light_yellow", "green", "light_blue", "blue", "magenta"]
    letters = (32..126).map{ |x| x.chr}
    pause = 1
    distort = 1

    sleep(3)
    str = "......The rabbit hole goes"
    sleep(1)

    (0..str.length).to_a.each do |loc|
      print "\b"*loc
      print str[0..loc].red
      sleep(0.05)
    end

    sleep(1)
    puts "\nd".red
    sleep(1)

    (1.. 25000).to_a.each do |i|
      if rand < distort
        puts "e".send(colors[i % 7])
      else
        puts letters.sample.send(colors[i % 7])
      end
      sleep(pause)
      pause *= 0.95
      distort *= 0.99
    end

    system('clear')
  end


  def how_well_did_you_sleep
    how_well = [
      [" well!".green, 1.05],
      [" not well.".light_red, 0.80],
      [" ok...".light_yellow, 0.90],
      [" terribly. :(".red, 0.50],
      [" great!".light_green, 1.2],
      [" very well!".light_green,1.10 ],
      [" like a baby!".light_green, 1.15],
      [" in today.".light_red, 0.80],
      [" too late last night. You're tired today...".red, 0.60],
      [" like an angel!".white.blink, 1.25],
      [". ", 1.0]
    ]
    sleep_quality = how_well.sample

    puts "You slept".green + sleep_quality[0]
    self.todays_luck = sleep_quality[1]
  end


  ### STATS SCREEN

  def stats_screen
    puts "\nYour Total Money Earned: $#{self.farmer.total_money_earned}\nYour Total Crops Harvested: #{self.farmer.crops_harvested}".green

    puts "\nAll-Time Richest Farmers:".green
    Farmer.richest_farmers.each_with_index do |farmer, index|
      puts "    #{index + 1}. #{farmer.display_name} - $#{farmer.total_money_earned}".green
    end

    puts "\nAll-Time Greenest Farmers:".green
    Farmer.greenest_farmers.each_with_index do |farmer, index|
      puts "    #{index + 1}. #{farmer.display_name} - #{farmer.crops_harvested} Crops Harvested".green
    end

    puts "\n"

    prompt = TTY::Prompt.new
    prompt.select("Press Enter to go back to the Main Screen".light_yellow,[""])
    # puts "\nType '1' to go back to the Main Screen.".light_yellow
    # ans = get_valid_input([1], "Type '1' to go back.")
    self.main_screen
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

  def divider
    puts "\n========================================================================\n".light_white
  end

end
