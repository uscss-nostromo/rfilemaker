module RFilemaker
  class ResultSet < Array
    # Parse a Filemaker date format to something strptime understands
    def self.parse_date_format(string)
      string = string.gsub(/yyyy|yy/, '%y').gsub(/mm|m|MM|M/, '%m').gsub(/dd|d|DD|D/, '%d')
      string.gsub(/hh|h/, '%I').gsub(/kk|k/, '%H').gsub(/mm/, '%M').gsub(/ss/, '%S').gsub(/a/, '%p')
    end

    attr_reader :fields, :rows, :number_of_rows
    attr_reader :date_format, :time_format
    
    # Generates a new ResultSet (or plain Ruby Array) for the given XML document
    # Items in the ResultSet are Hashes, representing rows in the Filemaker export
    def initialize(doc)
      @fields = extract_fields(doc)
      @rows   = extract_rows(doc)
      @number_of_rows = @rows.length

      d = doc.css('DATABASE')
      @date_format = ResultSet.parse_date_format(d.attribute('DATEFORMAT').to_s)
      @time_format = ResultSet.parse_date_format(d.attribute('TIMEFORMAT').to_s)
            
      @rows.each do |row|
        self << Record.new(row, fields)
      end
    end

    # Return headers(Array) in the <METADATA>..</METADATA>
    def headers
      self.fields.map{|i| i.name}
    end

    # Return attribute TYPE in the <FIELD />
    def type(name)
      self.fields.find{|i| i.name == name}.type
    end

    # Return attribute MAXREPEAT in the <FIELD />
    def maxrepeat(name)
      self.fields.find{|i| i.name == name}.maxrepeat
    end
        
    # Get A Row or A Column
    def [](arg)
      if arg.is_a? Numeric
        super
      else
        self.map{|i| i[arg]}
      end
    end

    private # :nodoc: all
      def extract_fields(doc)
        doc.css('METADATA FIELD').collect do |xml|
          Field.new(xml, self)
        end
      end
      
      def extract_rows(doc)
        doc.css('RESULTSET ROW').collect do |xml|
          Row.new(xml)
        end
      end
  end
end
