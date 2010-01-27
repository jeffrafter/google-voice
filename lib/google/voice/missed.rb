# coding: UTF-8
require File.join(File.expand_path(File.dirname(__FILE__)), 'base')
require 'json'

module Google
  module Voice    
    class Missed < Base
      def missed
        @curb.url = "https://www.google.com/voice/inbox/recent/missed/"        
        @curb.http_get
        calls = []
        doc = Nokogiri::XML::Document.parse(@curb.body_str)
        box = doc.xpath('/response/json').first.text
        json = JSON.parse(box)
        # Format for messages is [id, {attributes}]
        json['messages'].each do |message|
          if message[1]['type'].to_i == 2
            next
          else
            # Google is using milliseconds since epoch for time
            calls << {
              :id => message[0],
              :phone_number => message[1]['phoneNumber'],
              :start_time => Time.at(message[1]['startTime'].to_i / 1000)} 
          end
        end      
        calls
      end      
    end
  end
end