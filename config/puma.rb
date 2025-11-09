# Environment
environment ENV.fetch("RACK_ENV") { "development" }

# Threads per worker (min:max)
threads_count = ENV.fetch("PUMA_THREADS") { 5 }.to_i
threads threads_count, threads_count

# Number of worker processes (for multi-process concurrency)
workers ENV.fetch("PUMA_WORKERS") { 2 }.to_i

# Preload the app for copy-on-write
preload_app!

# Port
port ENV.fetch("PORT") { 9292 }

# Logging
stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true
