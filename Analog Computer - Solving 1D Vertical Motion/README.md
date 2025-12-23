# Analog Computer - Solving 1D Vertical Motion

This project demonstrates an **analog computing approach** to simulate the vertical motion of a **mass-spring-damper system** using op-amp circuits. By modeling the system’s second-order differential equation through summing and integrator stages, the circuit converts acceleration into velocity and displacement in real time. The use of **Howland current source integrators** improves accuracy and simplifies initialization.

---

## Objective
Design an analog circuit that simulates the motion of a block under:
- Gravity
- Damping (drag)
- Spring force  

using **op-amp-based circuits**.

Equation of motion:
\[
F = ma = -mg - bv - ky
\]
where:
- \(m\): mass of block  
- \(g\): gravitational acceleration  
- \(b\): damping coefficient  
- \(k\): spring constant  
- \(v\): velocity  
- \(y\): displacement  

---

## Components
- 2 × 10µF Capacitors (Howland Integrator)
- Resistors: 1kΩ, 5kΩ, 200kΩ
- 2 × TL084 IC (quad op-amp)

---

## Circuit Parts
- **Buffer Circuit** → Prevents loading on the gravity voltage supply  
- **Summation Circuit** → Combines gravity, damping, and spring voltages  
  

\[
  V_{out} = -(V_g + V_{damping} + V_{spring})
  \]


- **Integration Circuit** → Converts acceleration → velocity → displacement  
- **Feedback & Damping Control** → Adjusts input based on velocity & position  

---

## Howland Current Source Integrator
Advantages over traditional op-amp integrators:
- Easier initialisation of initial conditions  
- Better stability & linearity  
- Grounded capacitor avoids polarity issues  

---

## Simulation
The circuit was simulated using **SPICE** with TL084 op-amps.

### Observations:
- **Underdamped response** → Oscillations gradually reduce in amplitude  
- **Mean position shift** → Settles around -0.657 V due to gravity term  
- **Phase & frequency** → Position and velocity show a slight phase difference  

---

## Output Waveform
- Velocity and displacement waveforms show oscillatory motion  
- System stabilises around a steady-state equilibrium  

---

## Summary
This project successfully demonstrates:
- Designed and implemented an analog computer circuit for 1D vertical motion  
- Used **Howland current source integrators** for improved accuracy & initialization  
- Demonstrated real-time simulation of a damped second-order system  

Applications:
- System modelling  
- Control applications  
- Educational visualisation of mechanical dynamics  

---

## Acknowledgment
Special thanks to **Prof. Anil Kottantharayil (IIT Bombay)** for guidance, and **WEL Labs at IIT Bombay** for providing resources and support.

---

