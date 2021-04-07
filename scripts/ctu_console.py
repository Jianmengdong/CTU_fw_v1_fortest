from ctu_control import *


regs = "ctu_register.dat"
ctu = GLIB(ipaddress="192.168.10.116", registers=regs)
while True:
    print("#############################")
    reply = input("select function: \n"
                  "1: set trigger threshold\n"
                  "2: set trigger period\n"
                  "3: set trigger mask\n"  # force trigger, FMC, SMA, periodic, nhit
                  "4: set trigger window\n"
                  "5: set channel mask\n"
                  "6: force trigger\n"
                  "7: check board information\n"
                  "8: check trigger fifo counter\n"
                  "9: read trigger fifo\n"
                  "10: reset trigger fifo\n"
                  "11: GCU test pulse\n"
                  "q: exit\n")
    if reply == "1":
        th = input("press 'Enter' to read, or input value (decimal) to set:\n")
        if len(th) == 0:
            print(set_threshold(ctu, "r"))
        else:
            set_threshold(ctu, "w", int(th))
            print("done!")
    elif reply == "2":
        period = input("press 'Enter' to read, or input value (decimal) to set:\n")
        if len(period) == 0:
            print(set_period(ctu, "r"))
        else:
            set_period(ctu, "w", int(period))
            print("done!")
    elif reply == "3":
        mask = input("press 'Enter' to read, or input value (hexidecimal) to set:\n")
        if len(mask) == 0:
            print(set_trigger_mask(ctu, "r"))
        else:
            set_trigger_mask(ctu, "w", int(mask, 16))
            print("done!")
    elif reply == "4":
        window = input("press 'Enter' to read, or input value (decimal) to set:\n")
        if len(window) == 0:
            print(set_trigger_window(ctu, "r"))
        else:
            set_trigger_window(ctu, "w", int(window))
            print("done!")
    elif reply == "5":
        mask = input("press 'Enter' to read, or input value (decimal) to set:\n")
        if len(mask) == 0:
            print(set_channel_mask(ctu, "r"))
        else:
            set_channel_mask(ctu, "w", 0, int(mask))
            print("done!")
    elif reply == "6":
        force_trigger(ctu)
        print("done")
    elif reply == "7":
        print("Version: ", board_info(ctu))
        temp, vaux, vint = temp_voltage(ctu)
        print("FPGA temperature: %.2f C" % temp)
        print("VCCint: %.2f V; VCCaux: %.2f V" % (vint, vaux))
    elif reply == "8":
        print(fifo_counter(ctu))
    elif reply == "9":
        print(trigger_information(ctu))
    elif reply == "10":
        trigger_information(ctu, True)
        print("done!")
    elif reply == "11":
        gcu_test_pulse(ctu)
        print("done")
    elif reply == "q":
        break
