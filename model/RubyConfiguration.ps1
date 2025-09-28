[Flags()]
enum RubyConfiguration {
    Shell  = 0b00001 # 0x01
    Local  = 0b00010 # 0x02
    Global = 0b00100 # 0x04
    System = 0b01000 # 0x08
    Remote = 0b10000 # 0x10
}
