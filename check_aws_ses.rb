#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'
require 'optparse'

EXIT_CODES = {
  :unknown => 3,
  :critical => 2,
  :warning => 1,
  :ok => 0
}

options =
{
  :debug => false,
  :minimum => 1000000
}

config = { :region => 'us-east-1' }

opt_parser = OptionParser.new do |opt|

  opt.on("-k","--key key","specify your AWS key ID") do |key|
    (config[:access_key_id] = key) unless key.empty?
  end

  opt.on("-s","--secret secret","specify your AWS secret") do |secret|
    (config[:secret_access_key] = secret) unless secret.empty?
  end

  opt.on("-m","--minimum minimum","specify the minimum remaining amount") do |minimum|
    config[:minimum] = Integer(minimum)
  end
  
  opt.on("-r","--region region","which region do you wish to report on?") do |region|
    config[:region] = region
  end

  opt.on("-d","--debug","enable debug mode") do
    options[:debug] = true
  end

  opt.on("-h","--help","help") do
    puts opt_parser
    exit
  end
end

opt_parser.parse!

if (options[:debug])
  puts 'Options: '+options.inspect
  puts 'Config: '+config.inspect
end

AWS.config(config)

ses = AWS::SimpleEmailService.new.client

remainder = 0

begin
  AWS.memoize do
    quota = ses.get_send_quota()
    remainder = (quota[:max_24_hour_send] - quota[:sent_last_24_hours])
    if (remainder < options[:minimum])
      puts 'CRIT: Less than #{options[:minimum]} messages from our quota (' + quota[:sent_last_24_hours].to_s + '/' + quota[:max_24_hour_send].to_s + ').'
      exit EXIT_CODES[:critical] unless options[:debug]
    end
  end
rescue SystemExit
  raise
rescue Exception => e
  puts 'CRIT: Unexpected error: ' + e.message + ' <' + e.backtrace[0] + '>'
  exit EXIT_CODES[:critical]
end

puts 'OK: Limit is sufficient (' + remainder.to_s + ' remaining).'
exit EXIT_CODES[:ok]

