class SimpleCircuitBreaker
  VERSION = '0.1.0'

  class Error < StandardError
  end

  attr_reader :failure_threshold, :retry_timeout

  def initialize(failure_threshold=3, retry_timeout=10)
    @failure_threshold = failure_threshold
    @retry_timeout = retry_timeout
    reset!
  end

  def handle(&block)
    if tripped?
      raise Error, 'Circuit is open'
    else
      execute(&block)
    end
  end

protected

  def execute(&block)
    begin
      yield.tap { success! }
    rescue Exception
      fail!
      raise
    end
  end

  def success!
    if @state == :half_open
      reset!
    end
  end

  def fail!
    @failures += 1
    if @failures >= @failure_threshold
      @state = :open
      @open_time = Time.now
    end
  end

  def reset!
    @state = :closed
    @failures = 0
  end

  def tripped?
    @state != :closed && !try_to_close
  end

  def try_to_close
    if timeout_exceeded?
      @state = :half_open
      true
    else
      false
    end
  end

  def timeout_exceeded?
    @open_time + @retry_timeout < Time.now
  end

end
