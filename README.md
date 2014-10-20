nagios-check-aws-ses
====================

A Nagios check for monitoring the remaining SES quota on an AWS account

    Usage: check_aws_ses [options]
        -k, --key key                    specify your AWS key ID
        -s, --secret secret              specify your AWS secret
        -m, --minimum minimum            specify the minimum remaining amount
        -r, --region region              which region do you wish to report on?
        -d, --debug                      enable debug mode
        -h, --help                       help    

Configuration
-------------

    define command{
      command_name  check_aws_ses
      command_line  $USER1$/check_aws_ses.rb --key '$ARG1$' --secret '$ARG2$' 
      }
    
    define service{
      use                             generic-service 
      host_name                       aws
      service_description             Amazon SES Monitor
      check_command                   check_aws_ses!<%= @aws_nagios_key %>!<%= @aws_nagios_secret %>
      check_interval                  60
    }    

Notes:
* Default region is us-east-1 (N. Virginia)