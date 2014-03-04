module Kyototycoon
  class Record
    MAX_EXPIRE_SECONDS = 0x7FFFFFFFFFFFFFFF

    attr_accessor :key, :value, :db_id, :expire

    def initialize(key, value, expire=MAX_EXPIRE_SECONDS, db_id=0)
      @key    = key
      @value  = value
      @expire = expire
      @db_id  = db_id
    end
  end
end
