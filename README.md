# SimpleCircuitBreaker

## Overview

Simple Ruby implementation of the [Circuit Breaker design pattern][0].

## Usage

```ruby
failure_threshold = 3 # Trip the circuit after 3 consecutive failures.
retry_timeout = 10    # Retry on an open circuit after 10 seconds.
circuit_breaker = SimpleCircuitBreaker.new(failure_threshold, retry_timeout)

circuit_breaker.handle do
  FakeClient.new.request
end
```

`SimpleCircuitBreaker#handle` raises a `SimpleCircuitBreaker::Error` when the
circuit is open.

## Testing

Run the tests with

```bash
rake
```

## Authors

Julius Volz (julius@soundcloud.com), Tobias Schmidt (ts@soundcloud.com).

## Contributing

Pull requests welcome!

[0]: http://en.wikipedia.org/wiki/Circuit_breaker_design_pattern
