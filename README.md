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

# Component Cubes

A concept added to Tonga v2, this is a holder for loose components inside the case.
Components are mounted vertically stacked on top of a cube-like shape which has a void in the shape of a half sphere on the bottom, about 6.5mm diameter.
This fits a corresponding "mounting dome" in the case, preventing sideways movement.
The Component Cube is designed such that the top of the component stack fits _just_ under the lid, so that it can't move upwards (and therefore is stuck in all directions) when the lid is closed.

## Temperature+Humidity+GPS

- [Temperature+Humidity AHT20 StemmaQT breakout board by Adafruit](https://www.adafruit.com/product/4566)
- [Mini GPS PA1010D StemmaQT breakout board by Adafruit](https://www.adafruit.com/product/4415)
- [Model (OpenSCAD code)](./cube-temp-hum-gps.scad)
- [Render for printing (STL)](./cube-temp-hum-gps.stl)
- [Printing settings (Bambu Lab A1 mini)](./cube-temp-hum-gps.3mf)
