import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :genserver_and_task_demo, GenserverAndTaskDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QN4S1x/oA+nW4rb+k2RH3XRuxyP3T2lBK/FhSHiFojFkb4qg1B8A3JlD2YqQIcVG",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
