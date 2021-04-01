from ipbus import *


def set_trigger_mask(ctu, rw, value=0):
    if rw == "r":
        return hex(ctu.get("trig_maskr"))
    else:
        ctu.set("trig_mask", value)
        return 0


def set_threshold(ctu, rw, value=0):
    if rw == "r":
        return hex(ctu.get("thresholdr"))
    else:
        ctu.set("threshold", value)
        return 0


def set_period(ctu, rw, value=0):
    if rw == "r":
        return hex(ctu.get("periodr"))
    else:
        ctu.set("period", value)
        return 0


def set_trigger_window(ctu, rw, value=0):
    if rw == "r":
        return hex(ctu.get("trig_windowr"))
    else:
        ctu.set("trig_window", value)
        return 0


def force_trigger(ctu):
    ctu.set("force_trig", 1)
    ctu.set("force_trig", 0)
    return 0


def set_channel_mask(ctu, rw, number=0, value=0):
    channel = "ch_mask" + str(number)
    if rw == "r":
        return hex(ctu.get(channel + "r"))
    else:
        ctu.set(channel, value)
        return 0


def trigger_information(ctu, rst=False):
    if rst:
        ctu.set("trig_info", 0)
        return 0
    else:
        info0 = hex(ctu.get("trig_info"))
        info1 = hex(ctu.get("trig_info"))
        return info0, info1


def fifo_counter(ctu):
    return ctu.get("fifo_cnt")


def board_info(ctu):
    version = hex(ctu.get("version"))
    aligned = hex(ctu.get("rx_aligned"))
    return version, aligned


def temp_voltage(ctu):
    temp = ctu.get("temp_fpga") * 503.975 / 4096 - 273.15
    voltage = ctu.get("voltages")
    Vaux = (voltage >> 12) * 3.0 / 4096
    Vint = (voltage & 0xFFF) * 3.0 / 4096
    return temp, Vaux, Vint


def main():
    regs = "ctu_register.dat"
    ctu = GLIB(ipaddress="192.168.10.116", registers=regs)
    while True:
        command = input("cmd: ")
        if command == "quit":
            break
        else:
            cmd_list = command.split()
            if len(cmd_list) == 1:
                get_value = hex(ctu.get(cmd_list[0]))
                print("%s is %s" % (cmd_list[0], get_value))
            elif len(cmd_list) == 2:
                value = int(cmd_list[1], 16)
                set_value = hex(ctu.set(cmd_list[0], value))
                print("%s is set to %s" % (cmd_list[0], set_value))
            else:
                print("Wrong input format!")


if __name__ == "__main__":
    main()
