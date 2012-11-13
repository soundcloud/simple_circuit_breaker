class SimpleCircuitBreaker
  VERSION = '0.2.0'

  class CircuitOpenError < StandardError
  end

  attr_reader :failure_threshold, :retry_timeout

  def initialize(failure_threshold=3, retry_timeout=10)
    @failure_threshold = failure_threshold
    @retry_timeout = retry_timeout
    reset!
  end

  def handle(*exceptions, &block)
    if tripped?
      raise CircuitOpenError, 'Circuit is open'
    else
      execute(exceptions, &block)
    end
  end

protected

  def execute(exceptions, &block)
    begin
      yield.tap { reset! }
    rescue Exception => exception
      if exceptions.empty? || exceptions.include?(exception.class)
        fail!
      end
      raise
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
    @state == :open && !timeout_exceeded?
  end

  def timeout_exceeded?
    @open_time + @retry_timeout < Time.now
  end

end
