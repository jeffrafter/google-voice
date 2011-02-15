# coding: UTF-8
require File.join(File.expand_path(File.dirname(__FILE__)), 'base')
require 'json'

module Google
  module Voice    
    class Forwarding < Base

      def set_forwarding(phoneId, enabled)
        @curb.url = 'https://www.google.com/voice/b/0/settings/editDefaultForwarding/'
        fields = [
          Curl::PostField.content('_rnr_se', @_rnr_se),
          Curl::PostField.content('phoneId', phoneId),
          Curl::PostField.content('enabled', enabled)]
        @curb.http_post(fields)
	@curb.response_code
      end

      def phones
        @curb.url = "https://www.google.com/voice/b/0/settings/tab/phones"        
        @curb.http_get
        doc = Nokogiri::XML::Document.parse(@curb.body_str)
        box = doc.xpath('/response/json').first.text
        json = JSON.parse(box)
        phone_list = []
        json['phones'].each_pair do |phone_id, phone|
          phone_list << {
            :id          => phone_id,
            :phoneNumber => phone['phoneNumber'],
            :name        => phone['name'],
            :formattedNumber => phone['formattedNumber']
          }
        end      
        return phone_list
      end      

    end
  end
end
