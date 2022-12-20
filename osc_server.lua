function init_osc_server()
  local OscMessage = renoise.Osc.Message
  local OscBundle = renoise.Osc.Bundle
  print("init osc server")
  -- open a socket connection to the server
  local server, socket_error = renoise.Socket.create_server("192.168.1.48",
                                                            10000,
                                                            renoise.Socket
                                                              .PROTOCOL_UDP)

  if (socket_error) then
    renoise.app():show_warning(("Failed to start the " ..
                                 "OSC server. Error: '%s'"):format(socket_error))
    return
  end

  server:run{
    socket_message = function(socket, data)

      print('recived msg')

      -- decode the data to Osc
      local message_or_bundle, osc_error = renoise.Osc.from_binary_data(data)

      -- show what we've got
      if (message_or_bundle) then
        if (type(message_or_bundle) == "Message") then
          print(("Got OSC message: '%s'"):format(tostring(message_or_bundle)))

        elseif (type(message_or_bundle) == "Bundle") then
          print(("Got OSC bundle: '%s'"):format(tostring(message_or_bundle)))

        else
          -- never will get in here
        end

      else
        print(("Got invalid OSC data, or data which is not " ..
                "OSC data at all. Error: '%s'"):format(osc_error))
      end

      socket:send(("%s:%d: Thank you so much for the OSC message. " ..
                    "Here's one in return:"):format(socket.peer_address,
                                                    socket.peer_port))

      -- open a socket connection to the client
      local client, socket_error = renoise.Socket.create_client(
                                     socket.peer_address, socket.peer_port,
                                     renoise.Socket.PROTOCOL_UDP)

      if (not socket_error) then client:send(OscMessage("/flowers")) end
    end
  }
end

