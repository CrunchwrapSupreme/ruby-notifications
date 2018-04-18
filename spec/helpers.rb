module Helpers
  @max_retries = 3

  def retry
    k = 0
    loop do
      success = yield
      break if (success or k >= @max_retries)
      k +=1
      sleep(1)
    end

    if k >= @max_retries then
      raise "Could not perform block in #{@max_retries}"
    end
  end

  extend self
end
