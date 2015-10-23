# config/unicorn.rb
if ENV["RAILS_ENV"] == "development"
  worker_processes 1
else
  worker_processes 3
end

## serve app on localhost:3000
after_fork do |server, worker|
  addr = "127.0.0.1:3000"
  server.listen(addr, :tries => -1, :delay => 5)
end

timeout 30
