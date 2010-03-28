# coding: UTF-8
require File.join(File.expand_path(File.dirname(__FILE__)), 'base')

GOOGLE_VOICE_SMS_TYPE = 11

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
      
      def recent
        @curb.url = "https://www.google.com/voice/inbox/recent/"        
        @curb.http_get
        sms = []
        doc = Nokogiri::XML::Document.parse(@curb.body_str)
        data = doc.xpath('/response/json').first.text
        html = Nokogiri::HTML::DocumentFragment.parse(doc.to_html)
        json = JSON.parse(data)        
        # Format for messages is [id, {attributes}]
        json['messages'].each do |message|
          if message[1]['type'].to_i != GOOGLE_VOICE_SMS_TYPE
            next
          else
            messages = []            
            html.css('div.gc-message-sms-row').each do |row|
              if row.css('span.gc-message-sms-from').inner_html.strip! =~ /Me:/
                next
              elsif row.css('span.gc-message-sms-time').inner_html =~ Regexp.new(txt_obj.display_start_time)
                messages << {
                  :to => 'Me',
                  :from => row.css('span.gc-message-sms-from').inner_html.strip!.gsub!(':', ''),
                  :text => row.css('span.gc-message-sms-text').inner_html,
                  :time => row.css('span.gc-message-sms-time').inner_html
                }
              end
            end
            # Google is using milliseconds since epoch for time
            sms << {
              :id => message[0],
              :phone_number => message[1]['phoneNumber'],
              :start_time => Time.at(message[1]['startTime'].to_i / 1000),
              :messages => messages} 
          end
        end      
        sms
      end      
      
    end
  end
end