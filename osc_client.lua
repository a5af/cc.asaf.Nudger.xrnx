function init_osc_client()
  local OscMessage = renoise.Osc.Message
  local OscBundle = renoise.Osc.Bundle
  print("init osc client")

  -- open a socket connection to the server
  local client, socket_error = renoise.Socket.create_client("192.168.1.48",
                                                            10000,
                                                            renoise.Socket
                                                              .PROTOCOL_UDP)

  if (socket_error) then
    renoise.app():show_warning(("Failed to start the " ..
                                 "OSC client. Error: '%s'"):format(socket_error))
    return
  end

  -- construct and send messages
  client:send(OscMessage("/someone/transport/start"))

  client:send(OscMessage("/someone/transport/bpm", {{tag = "f", value = 127.5}}))

  -- construct and send bundles
  client:send(OscBundle(os.clock(), OscMessage("/someone/transport/start")))

  local message1 = OscMessage("/some/message")

  local message2 = OscMessage("/another/one", {
    {tag = "b", value = "with some blob data"},
    {tag = "s", value = "and a string"}
  })

  client:send(OscBundle(os.clock(), {message1, message2}))

end

