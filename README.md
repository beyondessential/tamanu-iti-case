# Tamanu Iti cases

## Tonga full case

Full 3D printed case.
Square footprint with plenty of internal space for componentry.
Tall enough to accommodate the HatDrive Top.

This was used for the Tonga Village Mission Clinic trial.

- [Model (OpenSCAD code)](./tonga/case.scad)
- Version 1:
  - [Case main body](./tonga/renders/case-tonga-1C.stl)
  - [Lid](./tonga/renders/case-tonga-1L.stl)
  - [Text inlay for lid](./tonga/renders/case-tonga-1T.stl)
- Version 2:
  - [Case main body](./tonga/renders/case-tonga-2C.stl)
  - [Case light pipe / RTC holder](./tonga/renders/case-tonga-2P.stl)
  - [Lid](./tonga/renders/case-tonga-2L.stl)
  - [Text inlay for lid](./tonga/renders/case-tonga-2T.stl)

![Photo of the 3D printed and fully assembled case](./tonga/renders/case-tonga-2.jpg)

## Prototype trials

These didn't go anywhere.
Meant to fit on top of the official case (replacing the "lid").

- [SCAD code](./proto-0/case.scad)
- [Version 0 STL](./proto-0/renders/case-proto-0.stl)
- [Version 1 STL](./proto-0/renders/case-proto-1.stl)
- [Version 2 STL](./proto-0/renders/case-proto-2.stl) and [text inlay](./proto-0/renders/case-proto-2T.stl)
- [Version 3 STL](./proto-0/renders/case-proto-3.stl) and [text inlay](./proto-0/renders/case-proto-3T.stl)
- [Version 4 STL](./proto-0/renders/case-proto-4.stl) and [text inlay](./proto-0/renders/case-proto-4T.stl)
- [Version 5 STL](./proto-0/renders/case-proto-5.stl) and [text inlay](./proto-0/renders/case-proto-5T.stl)

# E-ink screen

2.13" WeAct Epaper module

## SPI [pinout](https://pinout.xyz/pinout/spi)

| SPI Name | Pin | Wire colour            | Pin | RPi Name  |
|----------|-----|------------------------|-----|-----------|
| BUSY     | 1   | :black_circle: black   | 16  | GPIO 23   |
| RES      | 2   | :orange_circle: orange | 18  | GPIO 24   |
| D/C      | 3   | :white_circle: white   | 22  | GPIO 25   |
| CS       | 4   | 🔵 blue                | 24  | SPI0 CE0  |
| SCL      | 5   | :green_circle: green   | 23  | SPI0 SCLK |
| SDA      | 6   | :yellow_circle: yellow | 19  | SPI0 MOSI |
| GND      | 7   | :black_circle: black   | 20  | Ground    |
| VCC      | 8   | :red_circle: red       | 17  | 3v3 Power |
