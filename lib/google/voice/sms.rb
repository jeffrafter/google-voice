# coding: UTF-8
require File.join(File.expand_path(File.dirname(__FILE__)), 'base')

module Google
  module Voice    
    class Sms < Base
      def sms(number, text)
        @curb.http_post([ 
          Curl::PostField.content('phoneNumber', number),
          Curl::PostField.content('text', text),
          Curl::PostField.content('_rnr_se', @_rnr_se) 
        ])
        @curb.url = "https://www.google.com/voice/sms/send"        
        @curb.perform
        @curb.response_code
      end
    end
  end
end