require 'minitest/spec'
require 'minitest/autorun'
require_relative '../lib/simple_circuit_breaker'

describe SimpleCircuitBreaker do
  describe 'constructor' do
    it 'takes two arguments' do
      breaker = SimpleCircuitBreaker.new(5, 8)

      breaker.failure_threshold.must_equal 5
      breaker.retry_timeout.must_equal 8
    end

    it 'works without explicit arguments' do
      breaker = SimpleCircuitBreaker.new

      breaker.failure_threshold.must_equal 3
      breaker.retry_timeout.must_equal 10
    end
  end

  describe 'closed circuit' do
    before do
      @breaker = SimpleCircuitBreaker.new(3, 10)
    end

    it 'is initially closed' do
      foo = @breaker.handle do
        42
      end

      foo.must_equal 42
    end

    it 'works with BasicObject return values' do
      object = BasicObject.new
      foo = @breaker.handle do
        object
      end

      assert foo.equal?(object)
    end

    it 'opens after 3 consecutive failures with no explicit handled exceptions' do
      3.times do
        begin
          @breaker.handle { raise RuntimeError }
        rescue RuntimeError
        end
      end

      Proc.new do
        @breaker.handle do
          raise RuntimeError
        end
      end.must_raise SimpleCircuitBreaker::CircuitOpenError
    end

    it 'opens after 3 consecutive failures for handled exception' do
      3.times do
        begin
          @breaker.handle(RuntimeError) { raise RuntimeError }
        rescue RuntimeError
        end
      end

      Proc.new do
        @breaker.handle(RuntimeError) do
          raise RuntimeError
        end
      end.must_raise SimpleCircuitBreaker::CircuitOpenError
    end

    it 'opens after 3 consecutive failures for subclasses of a handled exception' do
      subclass = Class.new(StandardError)

      3.times do
        begin
          @breaker.handle(StandardError) { raise subclass }
        rescue subclass
        end
      end

      Proc.new do
        @breaker.handle(StandardError) do
          raise subclass
        end
      end.must_raise SimpleCircuitBreaker::CircuitOpenError
    end

    it 'doesn\'t open after 3 consecutive failures for non-handled exception' do
      class FooError < Exception
      end

      4.times do
        begin
          @breaker.handle(FooError) { raise RuntimeError }
        rescue RuntimeError
        end
      end
    end

    it 'doesn\'t open after 3 non-consecutive failures for handled exception' do
      4.times do
        begin
          @breaker.handle(RuntimeError) {}
          @breaker.handle(RuntimeError) { raise RuntimeError }
        rescue RuntimeError
        end
      end
    end
  end

  describe 'opened circuit' do
    before do
      @breaker = SimpleCircuitBreaker.new(3, 0.1)
      3.times do
        @breaker.handle { raise RuntimeError } rescue nil
      end

      lambda { @breaker.handle {} }.must_raise SimpleCircuitBreaker::CircuitOpenError
    end

    it 'closes after timeout and subsequent success' do
      sleep(0.15)

      @breaker.handle { 23 }.must_equal 23
    end

    it 'stays open after timeout and subsequent error' do
      sleep(0.15)

      Proc.new do
        @breaker.handle do
          raise RuntimeError
        end
      end.must_raise RuntimeError

      lambda { @breaker.handle {} }.must_raise SimpleCircuitBreaker::CircuitOpenError
    end
  end
end
