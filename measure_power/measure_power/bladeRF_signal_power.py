import sys
import os
import threading
import time
import numpy as np
from multiprocessing.pool import ThreadPool
from configparser import ConfigParser

from bladerf import _bladerf

from scipy.io import loadmat
from bladerf import _bladerf
import argparse
import csv
import struct
from pathlib import Path


# =============================================================================
# Close the device and exit
# =============================================================================
def shutdown(error=0, board=None):
    print("Shutting down with error code: " + str(error))
    if board != None:
        board.close()
    sys.exit(error)


# =============================================================================
# Search for a bladeRF device attached to the host system
# Returns a bladeRF device handle.
# =============================================================================
def probe_bladerf():
    device = None
    print("Searching for bladeRF devices...")
    try:
        devinfos = _bladerf.get_device_list()
        if len(devinfos) == 1:
            device = "{backend}:device={usb_bus}:{usb_addr}".format(
                **devinfos[0]._asdict()
            )
            print("Found bladeRF device: " + str(device))
        if len(devinfos) > 1:
            print("Unsupported feature: more than one bladeRFs detected.")
            print("\n".join([str(devinfo) for devinfo in devinfos]))
            shutdown(error=-1, board=None)
    except _bladerf.BladeRFError:
        print("No bladeRF devices found.")
        pass

    return device


# =============================================================================
# RECEIVE
# =============================================================================
def receive(
    device,
    channel: int,
    _freq: int,
    _rate: int,
    _gain: int,
    tx_start=None,
    rx_done=None,
    rxfile: str = "",
    _num_samples: int = 1024,
):
    status = 0

    if device == None:
        print("RX: Invalid device handle.")
        return -1

    if channel == None:
        print("RX: Invalid channel.")
        return -1

    # Configure BladeRF
    ch = device.Channel(channel)
    ch.frequency = _freq
    ch.sample_rate = _rate
    ch.gain = _gain

    # Setup synchronous stream
    device.sync_config(
        layout=_bladerf.ChannelLayout.RX_X1,
        fmt=_bladerf.Format.SC16_Q11,
        num_buffers=16,
        buffer_size=8192,
        num_transfers=8,
        stream_timeout=3500,
    )

    # Enable module
    print("RX: Start")
    ch.enable = True

    # Create receive buffer
    bytes_per_sample = 4
    buf = bytearray(1024 * bytes_per_sample)
    num_samples_read = 0

    # Tell TX thread to begin
    if tx_start != None:
        tx_start.set()

    # Save the samples
    with open(rxfile, "wb") as outfile:
        while True:
            if _num_samples > 0 and num_samples_read == _num_samples:
                break
            elif _num_samples > 0:
                num = min(len(buf) // bytes_per_sample, _num_samples - num_samples_read)
            else:
                num = len(buf) // bytes_per_sample

            # Read into buffer
            device.sync_rx(buf, num)
            num_samples_read += num

            # Write to file
            outfile.write(buf[: num * bytes_per_sample])

    # Disable module
    print("RX: Stop")
    ch.enable = False

    if rx_done != None:
        rx_done.set()

    print("RX: Done")

    return 0


def chunked_read(fobj, chunk_bytes=4 * 1024):
    while True:
        data = fobj.read(chunk_bytes)
        if not data:
            break
        else:
            yield data


def bin2csv(binfile=None, csvfile=None, chunk_bytes=4 * 1024):
    with open(binfile, "rb") as b:
        with open(csvfile, "w") as c:
            csvwriter = csv.writer(c, delimiter=",")
            count = 0
            for data in chunked_read(b, chunk_bytes=chunk_bytes):
                count += len(data)
                for i in range(0, len(data), 4):
                    (sig_i,) = struct.unpack("<h", data[i : i + 2])
                    (sig_q,) = struct.unpack("<h", data[i + 2 : i + 4])
                    csvwriter.writerow([sig_i, sig_q])
    # print( "Processed", str(count//2//2), "samples." )


##########################################################################
def calculate_power_in_db(csv_path):
    # Load the CSV file
    maxPower = 0
    with open(csv_path, "r") as csv_file:
        reader = csv.reader(csv_file)
        csv_reader = csv.reader(csv_file)
        data = []
        pow = []
        sum = 0
        max = 0
        numRows = 0
        for row in csv_reader:
            i, q = float(row[0]), float(row[1])
            sqr = i**2 + q**2
            if sqr > max:
                max = sqr
            sum = sum + sqr
            numRows += 1
            data.append(i + 1j * q)
        # print("max: " + str(10*np.log10(sqr)))

    # Calculate the power
    power = np.mean(np.abs(data) ** 2)
    # Convert to dB
    power_db = 10 * np.log10(sqr)

    # Convert power in dB to a string
    power_db_str = str(round(power_db, 2))

    return power_db


def measure_power(freq, rate, gain, num_samples):
    uut = probe_bladerf()
    if uut == None:
        print("No bladeRFs detected. Exiting.")
        shutdown(error=-1, board=None)
    b = _bladerf.BladeRF(uut)
    rx_ch = _bladerf.CHANNEL_RX(0)
    # seconds = time.time()
    print(
        "Freq: "
        + str(freq)
        + " Rate: "
        + str(rate)
        + " Gain: "
        + str(gain)
        + " Samples: "
        + str(num_samples)
    )
    receive(
        device=b,
        channel=rx_ch,
        _freq=freq,
        _rate=rate,
        _gain=gain,
        tx_start=None,
        rx_done=None,
        rxfile="rx.bin",
        _num_samples=num_samples,
    )
    # print(time.time()-seconds)
    bin2csv("rx.bin", "rx_csv.csv")
    power = calculate_power_in_db("rx_csv.csv")
    # print("power " + power)
    # shutdown(0, uut)
    os.remove("rx.bin")
    os.remove("rx_csv.csv")
    b.close()
    return power

if __name__ == "__main__":
    print(measure_power(102900000, 35000000, 1, 2000))
