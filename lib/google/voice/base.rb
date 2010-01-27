# coding: UTF-8
require 'rubygems'
require 'curb'
require 'nokogiri'

module Google
  module Voice    
    class Base
      def initialize(email, password)      
        @email = email
        @password = password
        login
        set_rnr_se_token
      end
      
      def finalize
        logout
      end
      
      def delete(ids)
        ids = Array(ids)
        fields = [ 
          Curl::PostField.content('_rnr_se', @_rnr_se),
          Curl::PostField.content('trash', '1')]
        ids.each{|id| fields << Curl::PostField.content('messages', id)}
        @curb.http_post(fields)
        @curb.url = "https://www.google.com/voice/inbox/deleteMessages/"        
        @curb.perform
        @curb.response_code
      end
                
      def mark(ids, read = true)
        ids = Array(ids)
        fields = [ 
          Curl::PostField.content('_rnr_se', @_rnr_se),
          Curl::PostField.content('read', read ? '1' : '0')]
        ids.each{|id| fields << Curl::PostField.content('messages', id)}
        @curb.http_post(fields)
        @curb.url = "https://www.google.com/voice/inbox/mark/"        
        @curb.perform
        @curb.response_code
      end

    private      
      def login
        @curb = Curl::Easy.new('https://www.google.com/accounts/ServiceLoginAuth') do |curl|
          curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2"
          # curl.verbose = true
          curl.follow_location = true
          curl.enable_cookies = true
          curl.perform

          # Defeat Google's XSRF protection
          doc = Nokogiri::HTML::DocumentFragment.parse(curl.body_str)
          doc.css('div.loginBox table#gaia_table input').each do |input|
            if input.to_s =~ /GALX/
              @galx = input.to_s.scan(/value\="(.+?)"/).flatten!.pop
            end
          end

          curl.http_post([ 
            Curl::PostField.content('continue', 'https://www.google.com/voice'),
            Curl::PostField.content('service', 'grandcentral'),
            Curl::PostField.content('GALX', @galx),
            Curl::PostField.content('Email', @email),
            Curl::PostField.content('Passwd', @password) 
          ])
        end
        
        unless @curb.instance_of?(Curl::Easy) && @curb.response_code == 200
          raise IOError, "Could not login to service" 
        end  
      end  

      def logout
        @curb.url = "https://www.google.com/voice/account/signout"
        @curb.perform
        @curb = nil
      end
   
      def set_rnr_se_token
        @curb.url = "http://www.google.com/voice"
        @curb.perform 
        @_rnr_se = Nokogiri::HTML::Document.parse(@curb.body_str).css('form#gc-search-form').inner_html
        /value="(.+)"/.match(@_rnr_se)
        @_rnr_se = $1
      end        
    end
  end
end