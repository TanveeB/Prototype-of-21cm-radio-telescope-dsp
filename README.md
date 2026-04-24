#Chebyshev Filter & HI Line Detection

Prototype implementation of a low-cost 21cm radio telescope for 
detecting galactic HI line emissions and deriving the Milky Way 
rotation curve.

## What Was Built

- **Horn antenna** — pyramidal, aluminium foil/cardboard construction,
  tuned to 1420 MHz
- **9th-order Chebyshev bandpass filter** — designed in MATLAB,  
  110 MHz bandwidth centred at 1420 MHz, 0.01 dB passband ripple
- **RF receiver chain** — horn antenna → LNA → BPF1 → custom BPF2 
  → RTL-SDR
- **Signal processing** — FFT-based spectral analysis in MATLAB to extract Doppler-shifted HI emission profiles

## Filter Design

The custom microstrip bandpass filter (BPF2) is a 9th-order 
inter-digital Chebyshev Type I filter:

| Parameter | Value |
|---|---|
| Centre frequency | 1420 MHz |
| Bandwidth (-3dB) | 110 MHz |
| Passband ripple | 0.01 dB |
| Filter order | 9 |
| Stopband attenuation | > 100 dB |


## Results
- Fabricated pyramidal horn antenna (aluminium foil 
  and cardboard construction, tuned to 1420 MHz)
- Designed 9th-order inter-digital Chebyshev microstrip bandpass 
  filter in MATLAB — 110 MHz bandwidth centred at 1420 MHz, 
  0.01 dB passband ripple, simulated in CST Studio and Ansys 
  Electronics Desktop
