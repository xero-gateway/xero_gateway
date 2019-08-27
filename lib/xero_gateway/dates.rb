module XeroGateway
  module Dates
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def format_date(time)
        return time.strftime("%Y-%m-%d")
      end
      
      def format_date_time(time)
        return time.strftime("%Y%m%d%H%M%S")
      end
      
      def parse_date(time)
        Date.civil(time[0..3].to_i, time[5..6].to_i, time[8..9].to_i)
      end
      
      def parse_date_time(time)
        Time.local(time[0..3].to_i, time[5..6].to_i, time[8..9].to_i, time[11..12].to_i, time[14..15].to_i, time[17..18].to_i)
      end

      def parse_date_time_utc(time)
        Time.utc(time[0..3].to_i, time[5..6].to_i, time[8..9].to_i, time[11..12].to_i, time[14..15].to_i, time[17..18].to_i)
      end
    end

    module Helpers
      extend ClassMethods
    end
  end
end
