require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__)+'/main.rb'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

run UpdateRnc.new
