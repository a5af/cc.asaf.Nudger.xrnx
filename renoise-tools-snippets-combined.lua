--[[============================================================================
Classes.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

--[[

Renoises lua API has a simple OO support inbuilt -> class "MyClass". All
Renoise API objects use such classes.

See http://www.rasterbar.com/products/luabind/docs.html#defining-classes-in-lua
for more technical info and below for some simple examples

Something to keep in mind:

- constructor "function MyClass:\_\_init(args)" must be defined for each class,
  or the class can't be used to instantiate objects
- class defs are always global, so even locally defined classes will be
  registered globally...

--]]

---

-- abstract class

class 'Animal'
function Animal:\_\_init(name)
self.name = name
self.can_fly = nil
end

function Animal:\_\_tostring()
assert(self.can_fly ~= nil, "I don't know if I can fly or not")

    return ("I am a %s (%s) and I %s fly"):format(self.name, type(self),
      (self.can_fly and "can fly" or "can not fly"))

end

-- derived classes

-- MAMMAL
class 'Mammal' (Animal)
function Mammal:**init(str)
Animal.**init(self, str)
self.can_fly = false
end

-- BIRD
class 'Bird' (Animal)
function Bird:**init(str)
Animal.**init(self, str)
self.can_fly = true
end

-- FISH
class 'Fish' (Animal)
function Fish:**init(str)
Animal.**init(self, str)
self.can_fly = false
end

-- run

local farm = table.create()

farm:insert(Mammal("cow"))
farm:insert(Bird("sparrow"))
farm:insert(Fish("bass"))

print(("type(Mammal('cow')) -> %s"):format(type(Mammal("cow"))))
print(("type(Mammal) -> %s"):format(type(Mammal)))

for \_,animal in pairs(farm) do
print(animal)
end

---

-- Class operators

-- You can overload most operators in Lua for your classes. You do this by
-- simply declaring a member function with the same name as an operator
-- (the name of the metamethods in Lua).

--[[ The operators you can overload are:

- \_\_add
- \_\_sub
- \_\_mul
- \_\_div
- \_\_pow
- \_\_lt
- \_\_le
- \_\_eq
- \_\_call
- \_\_unm
- \_\_tostring
- \_\_len

--]]

-- "\_\_tostring" isn't really an operator, but it's the metamethod that is
-- called by the standard library's tostring() function.

--[[============================================================================
Files&Bits.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

-- reading integer numbers or raw bytes from a file

local function read_word(file)
local bytes = file:read(2)
if (not bytes or #bytes < 2) then
return nil
else
return bit.bor(bytes:byte( 1),
bit.lshift(bytes:byte(2), 8))
end
end

local function read_dword(file)
local bytes = file:read(4)
if (not bytes or #bytes < 4) then
return nil
else
return bit.bor(bytes:byte(1),
bit.lshift(bytes:byte(2), 8),
bit.lshift(bytes:byte(3), 16),
bit.lshift(bytes:byte(4), 24))  
 end  
 end

-- and so on (adapt as needed to mess with endianess!) ...

local file = io.open("some_binary_file.bin", "rb")

local bytes = file:read(512)

if (not bytes or #bytes < 512) then
print("unexpected end of file")
else
for i = 1, #bytes do
print(bytes:byte(i))
end
end

print(read_word(file) or "unexpected end of file")
print(read_dword(file) or "unexpected end of file")

-- more bit manipulation? -> See "bit" in "Lua.Standard.API.lua"

--[[============================================================================
Instruments.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

--[[

This procedure sorts instruments from biggest to smallest using the Bubble
Sort algorithm.

Bubble sort is Computer Science 101 material. It is included as a code snippet
for learning purposes, but to be honest, this is a horrible idea. The
procedure "works" but will take a long time to finish. This is not a practical
solution, only educational.

]]--

-- Set up a table named 'placeholder'
-- The key is the instrument position
-- The value is the size of the sample(s) contained within

local placeholder = { }
local instruments = renoise.song().instruments
local total = #instruments
for i = 1,total do
for j = 1,#instruments[i].samples do
placeholder[i] = 0
if instruments[i].samples[j].sample_buffer.has_sample_data then
-- Shortcuts
local frames = instruments[i].samples[j].sample_buffer.number_of_frames
local n_channels = instruments[i].samples[j].sample_buffer.number_of_channels
local bits_per_sample = instruments[i].samples[j].sample_buffer.bit_depth
-- Calculate the size of the sample
local bytes_in_frame = n_channels _ (bits_per_sample / 8)
local size = bytes_in_frame _ frames
-- Append to the table
placeholder[i] = placeholder[i] + size
end
end
end

-- Debug: Before
-- rprint(placeholder)

-- Bubble Sort

local num_swaps = 0
local i = 1
while( i < total ) do
local j = i + 1
while( j <= total ) do
if ( placeholder[j] > placeholder[i] ) then
local tmp = placeholder[j]
placeholder[j] = placeholder[i];
renoise.song():swap_instruments_at(j, i)
placeholder[i] = tmp
num_swaps = num_swaps + 1
end
j = j + 1;
end
i = i + 1;
end

-- Debug: After
-- rprint(placeholder)

-- Alert box
local alert = renoise.app():show_prompt(
'Bubble Sort Complete',
'Total number of swaps was: ' .. num_swaps,
{'Ok'}
)

--[[============================================================================
Midi.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

-- midi input listener (function callback)

local inputs = renoise.Midi.available_input_devices()
local midi_device = nil

if not table.is_empty(inputs) then
local device_name = inputs[1]

    local function midi_callback(message)
      assert(#message == 3)
      assert(message[1] >= 0 and message[1] <= 0xff)
      assert(message[2] >= 0 and message[2] <= 0xff)
      assert(message[3] >= 0 and message[3] <= 0xff)

      print(("%s: got MIDI %X %X %X"):format(device_name,
        message[1], message[2], message[3]))
    end

    -- note: sysex callback would be a optional 2nd arg...
    midi_device = renoise.Midi.create_input_device(
      device_name, midi_callback)

    -- stop dumping with 'midi_device:close()' ...

end

---

-- midi input and sysex listener (class callbacks)

class "MidiDumper"
function MidiDumper:\_\_init(device_name)
self.device_name = device_name
end

    function MidiDumper:start()
      self.device = renoise.Midi.create_input_device(
        self.device_name,
        { self, MidiDumper.midi_callback },
        { MidiDumper.sysex_callback, self }
      )
    end

    function MidiDumper:stop()
      if self.device then
        self.device:close()
        self.device = nil
      end
    end

    function MidiDumper:midi_callback(message)
      print(("%s: MidiDumper got MIDI %X %X %X"):format(
        self.device_name, message[1], message[2], message[3]))
    end

    function MidiDumper:sysex_callback(message)
      print(("%s: MidiDumper got SYSEX with %d bytes"):format(
        self.device_name, #message))
    end

local inputs = renoise.Midi.available_input_devices()

if not table.is_empty(inputs) then
local device_name = inputs[1]

    -- should be global to avoid premature garbage collection when
    -- going out of scope.
    midi_dumper = MidiDumper(device_name)

    -- will dump till midi_dumper:stop() is called or the MidiDumber object
    -- is garbage collected ...
    midi_dumper:start()

end

---

-- midi output

local outputs = renoise.Midi.available_output_devices()

if not table.is_empty(outputs) then
local device_name = outputs[1]
midi_device = renoise.Midi.create_output_device(device_name)

    -- note on
    midi_device:send {0x90, 0x10, 0x7F}
    -- sysex (MMC start)
    midi_device:send {0xF0, 0x7F, 0x00, 0x06, 0x02, 0xF7}

    -- no longer need the device...
    midi_device:close()

end

--[[============================================================================
Osc.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

-- create some handy shortcuts
local OscMessage = renoise.Osc.Message
local OscBundle = renoise.Osc.Bundle

-- NB: when using TCP instead of UDP as socket protocol, manual SLIP en/decoding
-- of OSC message data would be required too. This is left out here, so the examples
-- below only work with UDP servers/clients.

---

---- Osc server (receive Osc from one or more clients)

-- open a socket connection to the server
local server, socket_error = renoise.Socket.create_server(
"localhost", 8008, renoise.Socket.PROTOCOL_UDP)

if (socket_error) then
renoise.app():show_warning(("Failed to start the " ..
"OSC server. Error: '%s'"):format(socket_error))
return
end

server:run {
socket_message = function(socket, data)
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
        "Here's one in return:"):format(socket.peer_address, socket.peer_port))

      -- open a socket connection to the client
      local client, socket_error = renoise.Socket.create_client(
        socket.peer_address, socket.peer_port, renoise.Socket.PROTOCOL_UDP)

      if (not socket_error) then
        client:send(OscMessage("/flowers"))
      end
    end

}

-- shut off the server at any time with:
-- server:close()

---

-- Osc client & message construction (send Osc to a server)

-- open a socket connection to the server
local client, socket_error = renoise.Socket.create_client(
"localhost", 8008, renoise.Socket.PROTOCOL_UDP)

if (socket_error) then
renoise.app():show_warning(("Failed to start the " ..
"OSC client. Error: '%s'"):format(socket_error))
return
end

-- construct and send messages
client:send(
OscMessage("/someone/transport/start")
)

client:send(
OscMessage("/someone/transport/bpm", {
{tag="f", value=127.5}
})
)

-- construct and send bundles
client:send(
OscBundle(os.clock(), OscMessage("/someone/transport/start"))
)

local message1 = OscMessage("/some/message")

local message2 = OscMessage("/another/one", {
{tag="b", value="with some blob data"},
{tag="s", value="and a string"}
})

client:send(
OscBundle(os.clock(), {message1, message2})
)

--[[============================================================================
PatternIterator.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

---

-- change notes in selection
-- (all "C-4"s to "E-4" in the selection in the current pattern)

local pattern_iter = renoise.song().pattern_iterator
local pattern_index = renoise.song().selected_pattern_index

for pos,line in pattern*iter:lines_in_pattern(pattern_index) do
for *,note_column in pairs(line.note_columns) do
if (note_column.is_selected and
note_column.note_string == "C-4") then
note_column.note_string = "E-4"
end
end
end

---

-- generate a simple arp sequence (repeating in the current
-- pattern & track from line 0 to the pattern end)

local pattern_iter = renoise.song().pattern_iterator

local pattern_index = renoise.song().selected_pattern_index
local track_index = renoise.song().selected_track_index
local instrument_index = renoise.song().selected_instrument_index

local EMPTY_VOLUME = renoise.PatternLine.EMPTY_VOLUME
local EMPTY_INSTRUMENT = renoise.PatternLine.EMPTY_INSTRUMENT

local arp_sequence = {
{note="C-4", instrument = instrument_index, volume = 0x20},
{note="E-4", instrument = instrument_index, volume = 0x40},
{note="G-4", instrument = instrument_index, volume = 0x80},
{note="OFF", instrument = EMPTY_INSTRUMENT, volume = EMPTY_VOLUME},
{note="G-4", instrument = instrument_index, volume = EMPTY_VOLUME},
{note="---", instrument = EMPTY_INSTRUMENT, volume = EMPTY_VOLUME},
{note="E-4", instrument = instrument_index, volume = 0x40},
{note="C-4", instrument = instrument_index, volume = 0x20},
}

for pos,line in pattern_iter:lines_in_pattern_track(pattern_index, track_index) do
if not table.is_empty(line.note_columns) then

      local note_column = line:note_column(1)
      note_column:clear()

      local arp_index = math.mod(pos.line - 1, #arp_sequence) + 1
      note_column.note_string = arp_sequence[arp_index].note
      note_column.instrument_value = arp_sequence[arp_index].instrument
      note_column.volume_value = arp_sequence[arp_index].volume
    end

end

---

-- This procedure hides empty volume, panning, and delay colums.

for track*index, track in pairs(renoise.song().tracks) do
-- Set some bools
local found_volume = false
local found_panning = false
local found_delay = false
local found_sample_effects = false
-- Check whether or not this is a regular track
if
track.type ~= renoise.Track.TRACK_TYPE_MASTER and
track.type ~= renoise.Track.TRACK_TYPE_SEND
then
-- Iterate through the regular track
local iter = renoise.song().pattern_iterator:lines_in_track(track_index)
for *,line in iter do
-- Check whether or not the line is empty
if not line.is*empty then
-- Check each column on the line
for *,note_column in ipairs(line.note_columns) do
-- Check for volume
if note_column.volume_value ~= renoise.PatternLine.EMPTY_VOLUME then
found_volume = true
end
-- Check for panning
if note_column.panning_value ~= renoise.PatternLine.EMPTY_PANNING then
found_panning = true
end
-- Check for delay
if note_column.delay_value ~= renoise.PatternLine.EMPTY_DELAY then
found_delay = true
end
-- Check for sample effects
if note_column.effect_number_value ~= renoise.PatternLine.EMPTY_EFFECT_NUMBER then
found_sample_effects = true
end
if note_column.effect_amount_value ~= renoise.PatternLine.EMPTY_EFFECT_AMOUNT then
found_sample_effects = true
end

          end
          -- If we found something in all three vol, pan, and del
          -- Then there's no point in continuing down the rest of the track
          -- We break this loop and move on to the next track
          if found_volume and found_panning and found_delay and found_sample_effects then
            break
          end
        end
      end
      -- Set some properties
      track.volume_column_visible = found_volume
      track.panning_column_visible = found_panning
      track.delay_column_visible = found_delay
      track.sample_effects_column_visible = found_sample_effects
    end

end

--[[============================================================================
SampleBuffer.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

-- modify the selected sample

local sample_buffer = renoise.song().selected_sample.sample_buffer

-- check if sample data is preset at all first
if (sample_buffer.has_sample_data) then

    -- before touching any sample, let renoise create undo data, when necessary
    sample_buffer:prepare_sample_data_changes()

    -- modify sample data in the selection (defaults to the whole sample)
    for channel = 1, sample_buffer.number_of_channels do
      for frame = sample_buffer.selection_start, sample_buffer.selection_end do
        local value = sample_buffer:sample_data(channel, frame)
        value = -value -- do something with the value
        sample_buffer:set_sample_data(channel, frame, value)
      end
    end

    -- let renoise update sample overviews and caches. apply bit depth
    -- quantization. create undo/redo data if needed...
    sample_buffer:finalize_sample_data_changes()

else
renoise.app():show_warning("No sample preset...")
end

---

-- generate a new sample

local selected_sample = renoise.song().selected_sample
local sample_buffer = selected_sample.sample_buffer

-- create new or overwrite sample data for our sound:
local sample_rate = 44100
local num_channels = 1
local bit_depth = 32
local num_frames = sample_rate / 2

local allocation_succeeded = sample_buffer:create_sample_data(
sample_rate, bit_depth, num_channels, num_frames)

-- check for allocation failures
if (not allocation_succeeded) then
renoise.app():show_error("Out of memory. Failed to allocate sample data")
return
end

-- let renoise know we are about to change the sample buffer
sample_buffer:prepare_sample_data_changes()

-- fill in the sample data with an amazing zapp sound
for channel = 1,num_channels do
for frame = 1,num_frames do
local sample_value = math.sin(num_frames / frame)
sample_buffer:set_sample_data(channel, frame, sample_value)
end
end

-- let renoise update sample overviews and caches. apply bit depth
-- quantization. finalize data for undo/redo, when needed...
sample_buffer:finalize_sample_data_changes()

-- setup a pingpong loop for our new sample
selected_sample.loop_mode = renoise.Sample.LOOP_MODE_PING_PONG
selected_sample.loop_start = 1
selected_sample.loop_end = num_frames

--[[============================================================================
Sockets.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

-- HTTP / GET client

-- create a TCP socket and connect it to www.wurst.de, http, giving up
-- the connection attempt after 2 seconds

local connection_timeout = 2000

local client, socket_error = renoise.Socket.create_client(
"www.wurst.de", 80, renoise.Socket.PROTOCOL_TCP, connection_timeout)

if socket_error then
renoise.app():show_warning(socket_error)
return
end

-- request something
local succeeded, socket_error =
client:send("GET / HTTP/1.0\n\n")

if (socket_error) then
renoise.app():show_warning(socket_error)
return
end

-- loop until we get no more data from the server.
-- note: this is a silly example. we should check the HTTP
-- header here and stop after receiveing "Content-Length"
local receive_succeeded = false
local receive_content = ""

while (true) do
local receive_timeout = 500

    local message, socket_error =
      client:receive("*line", receive_timeout)

    if (message) then
      receive_content = receive_content .. message .. "\n"

    else
      if (socket_error == "timeout" or
          socket_error == "disconnected")
      then
        -- could retry here on timeout. we just stop in this example...
        receive_succeeded = true
        break
      else
        renoise.app():show_warning(
          "'socket reveive' failed with the error: " .. socket_error)
        break
      end
    end

end

-- close the connection if it was not closed by the server
if (client and client.is_open) then
client:close()
end

-- show what we've got
if (receive_succeeded and #receive_content > 0) then
renoise.app():show_prompt(
"GET / HTTP/1.0 response",
receive_content,
{"OK"}
)
else
renoise.app():show_prompt(
"GET / HTTP/1.0 response",
"Socket receive timeout.",
{"OK"}
)
end

---

-- echo udp server (using a table as notifier):

local server, socket_error = renoise.Socket.create_server(
"localhost", 1025, renoise.Socket.PROTOCOL_UDP)

if socket_error then
app:show_warning(
"Failed to start the echo server: " .. socket_error)
else
server:run {
socket_error = function(socket_error)
renoise.app():show_warning(socket_error)
end,

      socket_accepted = function(socket)
        print(("client %s:%d connected"):format(
          socket.peer_address, socket.peer_port))
      end,

      socket_message = function(socket, message)
        print(("client %s:%d sent '%s'"):format(
          socket.peer_address, socket.peer_port,  message))
        -- simply sent the message back
        socket:send(message)
      end
    }

end

-- will run and echo as long as the script runs...

---

-- echo TCP server (using a class as notifier, and allowing any addresses
-- to connect by not specifying an address):

class "EchoServer"
function EchoServer:\_\_init(port)
-- create a server socket
local server, socket_error = renoise.Socket.create_server(port)

     if socket_error then
       app:show_warning(
         "Failed to start the echo server: " .. socket_error)
     else
       -- start running
       self.server = server
       self.server:run(self)
     end
    end

    function EchoServer:socket_error(socket_error)
      renoise.app():show_warning(socket_error)
    end

    function EchoServer:socket_accepted(socket)
      print(("client %s:%d connected"):format(
        socket.peer_address, socket.peer_port))
    end

    function EchoServer:socket_message(socket, message)
      print(("client %s:%d sent '%s'"):format(
        socket.peer_address, socket.peer_port,  message))
      -- simply sent the message back
      socket:send(message)
    end

-- create and run the echo server on port 1025
local echo_server = EchoServer(1025)

-- will run and echo as long as the script runs or the EchoServer
-- object is garbage collected...

--[[============================================================================
TrackAutomation.lua
============================================================================]]--

error("do not run this file. read and copy/paste from it only...")

---

-- Access the selected parameters automation
-- (selected in the "Automation" tab in Renoise)

local selected_track_parameter = renoise.song().selected_track_parameter
local selected_pattern_track = renoise.song().selected_pattern_track

-- is a parameter selected?.
if (selected_track_parameter) then
local selected_parameters_automation = selected_pattern_track:find_automation(
selected_track_parameter)

    -- is there automation for the seelcted parameter?
    if (not selected_parameters_automation) then

      -- if not, create a new automation for the currently selected pattern/track
      selected_parameters_automation = selected_pattern_track:create_automation(
        selected_track_parameter)
    end

    ---- do something with existing automation

    -- iterate over all existing automation points
    for _,point in pairs(selected_parameters_automation.points) do
      print(("track automation: time=%s, value=%s"):format(
        point.time, point.value))
    end

    -- clear all points
    selected_parameters_automation.points = {}

    -- insert a single new point at line 2
    selected_parameters_automation:add_point_at(2, 0.5)
    -- change its value when it already exists
    selected_parameters_automation:add_point_at(2, 0.8)
    -- remove it again (must exist here)
    selected_parameters_automation:remove_point_at(2)

    -- batch creation/insertion of points
    local new_points = table.create()
    for i=1,selected_parameters_automation.length do
      new_points:insert {
        time=i,
        value=i/selected_parameters_automation.length
      }
    end

    -- assign them (note that new_points must be sorted by time)
    selected_parameters_automation.points = new_points

    -- change the automations interpolation mode
    selected_parameters_automation.playmode =
      renoise.PatternTrackAutomation.PLAYMODE_CUBIC

end

---

-- add menu entries for automation

-- shows up in the automation list on the left of the "Automation" tab
renoise.tool():add_menu_entry {
name = "Track Automation:Do Something With Automation",
invoke = function() do_something_with_current_automation() end,
active = function() return can_do_something_with_current_automation() end
}

-- shows up in the context menu of the automation !rulers!
renoise.tool():add_menu_entry {
name = "Track Automation List:Do Something With Automation",
invoke = function() do_something_with_current_automation() end,
active = function() return can_do_something_with_current_automation() end
}

function can_do_something_with_current_automation()
-- is a parameter selected and automation present?
return (renoise.song().selected_track_parameter ~= nil and
selected_pattern_track:find_automation(selected_track_parameter))
end

function do_something_with_current_automation()
-- do something with selected_parameters_automation
end
