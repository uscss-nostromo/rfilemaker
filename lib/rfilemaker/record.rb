module RFilemaker
  class Record < SpecialHash
    attr_reader :record_id, :mod_id
    
    def initialize(row, fields)
      @record_id = row.record_id
      @mod_id    = row.mod_id
      
      fields.each_with_index do |field, index|
        data = row.columns[index]

        if data.is_a?(Array)
          self[field.name] = []
          data.each { |d| self[field.name] << field.coerce(d) }
        else
          self[field.name] = field.coerce(data)
        end
      end
      
      freeze
    end
  end
end