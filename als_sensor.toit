import net
import i2c
import gpio
import vcnl4040 show Vcnl4040
import net.udp
import encoding.json

BROADCAST_PORT ::= 13280
BROADCAST_ADDRESS ::= net.SocketAddress
  net.IpAddress.parse "255.255.255.255"
  BROADCAST_PORT

UPDATE_RATE ::= Duration --ms=10
BROADCAST_RATE ::= Duration --ms=10

SDA ::= gpio.Pin 16
SCL ::= gpio.Pin 17

als_data := 0

main:
  // Open network connection.
  print "SET UP NETWORK CONNECTION"
  network := net.open
  socket := network.udp_open
  socket.broadcast = true

  // Set up ALS driver.
  print "SET UP DRIVER"
  bus := i2c.Bus --sda=SDA --scl=SCL

  driver := Vcnl4040
    bus.device Vcnl4040.I2C_ADDRESS

  driver.set_als_integration_time 80
  driver.set_als_power true

  task::
    print "START READING DATA"
    UPDATE_RATE.periodic:
      als_data = driver.read_als_data

  task::
    print "START BROADCASTING"
    BROADCAST_RATE.periodic:
      data := json.encode {
        "als": als_data
      }
      socket.send
        udp.Datagram data BROADCAST_ADDRESS
