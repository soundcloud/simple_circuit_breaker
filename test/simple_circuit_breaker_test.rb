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

    it 'opens after 3 consecutive failures' do
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
      end.must_raise SimpleCircuitBreaker::Error
    end
  end

  describe 'opened circuit' do
    before do
      @breaker = SimpleCircuitBreaker.new(3, 0.1)
      3.times do
        @breaker.handle { raise RuntimeError } rescue nil
      end

      lambda { @breaker.handle {} }.must_raise SimpleCircuitBreaker::Error
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

      lambda { @breaker.handle {} }.must_raise SimpleCircuitBreaker::Error
    end
  end
end
