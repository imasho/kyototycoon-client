module Kyototycoon
  class Record
    attr_accessor :key, :value, :db_id, :expire

    def initialize(key, value, db_id = 0, expire=0)
      @key    = key
      @value  = value
      @db_id  = db_id
      @expire = expire
    end
  end
end
