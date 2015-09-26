class LdapHelper

  require 'net/ldap'
  require 'yaml'

  def initialize(provider)
    @config = load_config(provider)
  end

  def load_config(provider)
    config_file = YAML.load(File.read('config/ldap.yml'))[provider]
    return { host: config_file['server'],
             port: config_file['port'],
             base: config_file['basedn'],
             encryption: config_file['encryption'].to_sym,
             auth: { 
               method: :simple,
               username: config_file['username'],
               password: config_file['password']
             }
           }
  end

  def search(attribute, value)
    Net::LDAP.open(@config) do |ldap|
      unless ldap.bind
        raise "Unable to authenticate with LDAP server #{@config[:server]}"
      end
      return ldap.search(filter: Net::LDAP::Filter.eq(attribute, value))
    end
  end
  
  def parse_date(date)
    unless date =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})Z/
      raise "Invalid date string format: #{date}"
    end
    return Time.mktime(year: $1, month: $2, day: $3, hour: $4, min: $5, sec: $6)
  end
end
