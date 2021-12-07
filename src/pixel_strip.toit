import net
import math
import gpio
import net.udp
import encoding.json
import pixel_strip show *
import .als_sensor show BROADCAST_PORT

TX := 16

STEPS_ ::= [27, 23, 19, 16]
PIXELS ::= 30

compute_color als max_val -> int:
  return als == 0 ? max_val : max 0 max_val - ((math.log als 2) / (math.log 2500 2) * max_val).to_int

als_to_brightness als/int r/ByteArray g/ByteArray b/ByteArray :
  als = als < 20 ? 0 : als - 20
  red := compute_color als 253
  r.fill red
  green := compute_color als 244
  g.fill green
  blue := compute_color als 220
  b.fill blue
  print "rgb: $red, $green, $blue"

main:
  print "SET UP NETWORK CONNECTION"
  network := net.open
  socket := network.udp_open --port=BROADCAST_PORT

  print "SET UP LED PIXEL STRIP"
  neopixel := UartPixelStrip PIXELS --pin=16 --bytes_per_pixel=3

  r := ByteArray PIXELS: 0
  g := ByteArray PIXELS: 0
  b := ByteArray PIXELS: 0

  neopixel.output r g b

  print "START RECEIVING DATA"
  while true:
    datagram := socket.receive
    data := json.decode datagram.data
    print data
    als_to_brightness data["als"] r g b
    neopixel.output r g b
    sleep --ms=2
