Redis.current = Redis.new(
  url: ENV["REDIS_URL"],
  ssl: { verify: :none }
)