require 'bundler'
require_relative '../config/environment'

prompt = TTY::Prompt.new


ans = prompt.select("Choose your destiny?", ["plant" ,  "crops check", "Stats" ])
binding.pry
