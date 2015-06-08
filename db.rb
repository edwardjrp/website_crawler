require "rubygems"
require "active_record"
require 'yaml'
require 'fileutils'
require 'logger'

class Dbutils

  def initialize()
    @configpathlog = File.expand_path('../config/logs.txt', __FILE__)
    @configpathdb = File.expand_path('../config/database.yml', __FILE__)
  end

  def connect()
    dbconfig = YAML::load(File.open(@configpathdb))
    ActiveRecord::Base.pluralize_table_names = false
    ActiveRecord::Base.establish_connection(dbconfig)
  end

  def logdebugmessage(message)
    file = @configpathlog
    log = Logger.new(file,"weekly")
    log.level = Logger::DEBUG
    log.debug message
  end

  def logfatalmessage(message)
    file = @configpathlog
    log = Logger.new(file,"weekly")
    log.level = Logger::FATAL
    log.fatal message
  end

  def loginfomessage(message)
    file = @configpathlog
    log = Logger.new(file,"weekly")
    log.level = Logger::INFO
    log.info message
  end


  def logerrormessage(message)
    file = @configpathlog
    log = Logger.new(file,"weekly")
    log.level = Logger::ERROR
    log.error message
  end

end