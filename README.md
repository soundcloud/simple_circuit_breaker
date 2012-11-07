# SimpleCircuitBreaker

## Overview

Simple Ruby implementation of the [Circuit Breaker design pattern][0].

This implementation aims to be as simple as possible. It does not have external
dependencies and only handles the core circuit breaker functionality. Wrapping
backend calls in timeouts and other exception handling is left to the user of
the library.

## Usage

```ruby
failure_threshold = 3 # Trip the circuit after 3 consecutive failures.
retry_timeout = 10    # Retry on an open circuit after 10 seconds.
circuit_breaker = SimpleCircuitBreaker.new(failure_threshold, retry_timeout)

# By default, all exceptions will trip the circuit.
circuit_breaker.handle do
  FooClient.new.request
end

# Setting explicit exceptions that trip the circuit:
circuit_breaker.handle FooError, BarError do
  FooClient.new.request
end
```

`SimpleCircuitBreaker#handle` raises a `SimpleCircuitBreaker::CircuitOpenError`
when the circuit is open. Otherwise, it re-raises any exceptions that occur in
the block.

## Installation

```bash
gem install simple_circuit_breaker
```

## Testing

[![Build Status](https://secure.travis-ci.org/soundcloud/simple_circuit_breaker.png)][1]

Run the tests with

```bash
rake
```

## Authors

Julius Volz (julius@soundcloud.com), Tobias Schmidt (ts@soundcloud.com).

## Alternatives

  * [Circuit Breaker][2]: heavily customizable circuit handler
  * [CircuitB][3]: supports keeping global circuit state in memcached

## Contributing

Pull requests welcome!

[0]: http://en.wikipedia.org/wiki/Circuit_breaker_design_pattern
[1]: http://travis-ci.org/soundcloud/simple_circuit_breaker
[2]: https://github.com/wsargent/circuit_breaker
[3]: https://github.com/alg/circuit_b
