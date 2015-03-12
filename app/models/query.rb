class Query
  @queue = :query

  def self.perform(id, sql)
    puts "Job #{id}: perform #{sql}"
    query_id = "sql:query:#{id}"

    (0..100).each do |n|
      Resque.redis.multi do |r|
        r.rpush(query_id, (10*n..10*n+9).to_a)
        r.ltrim(query_id, -50, -1)
      end
      sleep(1)
    end
  end
end
