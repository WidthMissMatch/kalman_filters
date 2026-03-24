# CA_UKF Parameter Configurations

Pre-tuned parameter sets for different tracking applications using Constant Acceleration model.

---

## Quick Reference Table

| Scenario | q_power | R (m²) | Best for |
|----------|---------|--------|----------|
| **Drone (Moderate)** | 56.25 | 0.25 | Consumer drones, moderate maneuvers |
| **Drone (Aggressive)** | 225.0 | 0.25 | Racing drones, aggressive flight |
| **Highway Vehicle** | 14.06 | 0.50 | Cars on highway, steady cruise |
| **Urban Vehicle** | 56.25 | 1.00 | City traffic, frequent stops |
| **Aircraft (Cruise)** | 3.52 | 2.00 | Commercial aircraft, steady flight |
| **Aircraft (Tactical)** | 225.0 | 1.00 | Fighter jets, maneuvers |
| **Pedestrian** | 3.52 | 0.10 | Walking humans, slow motion |
| **Ballistic** | 900.0 | 0.50 | Projectiles, high acceleration |

---

## 1. Drone Tracking (Moderate) **[CURRENT DEFAULT]**

**Application**: Consumer drones, DJI-style quadcopters, moderate maneuvers

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 50.0 m²        -- ±7m position uncertainty
P0_vel = 200.0 (m/s)²   -- ±14 m/s velocity uncertainty
P0_acc = 5.0 (m/s²)²    -- ±2.2 m/s² acceleration uncertainty

-- Process Noise Q (q_power = 56.25, dt = 0.02)
Q11, Q44, Q77 = 0           -- Position (negligible)
Q22, Q55, Q88 = 2516        -- Velocity (0.00015 in Q24.24)
Q33, Q66, Q99 = 18874368    -- Acceleration (1.125 in Q24.24)

-- Measurement Noise R
R11, R22, R33 = 0.25 m²     -- GPS/visual positioning
```

### Q24.24 Constants for VHDL
```vhdl
constant Q11_Q24_24 : signed(47 downto 0) := to_signed(0, 48);
constant Q22_Q24_24 : signed(47 downto 0) := to_signed(2516, 48);
constant Q33_Q24_24 : signed(47 downto 0) := to_signed(18874368, 48);
constant R11_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);
```

### Expected Performance
- **Typical acceleration**: ~5-10 m/s²
- **Max speed**: ~20 m/s
- **RMSE**: 1-3m (with GPS R=0.25m²)
- **Convergence**: ~10 cycles

---

## 2. Drone Tracking (Aggressive)

**Application**: Racing drones, FPV quadcopters, high-speed maneuvers

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 100.0 m²       -- ±10m (higher uncertainty)
P0_vel = 400.0 (m/s)²   -- ±20 m/s
P0_acc = 20.0 (m/s²)²   -- ±4.5 m/s²

-- Process Noise Q (q_power = 225.0, dt = 0.02)
Q11, Q44, Q77 = 0           -- Position
Q22, Q55, Q88 = 10065       -- Velocity (0.0006 in Q24.24)
Q33, Q66, Q99 = 75497472    -- Acceleration (4.5 in Q24.24)

-- Measurement Noise R
R11, R22, R33 = 0.25 m²     -- GPS
```

### Q24.24 Constants
```vhdl
constant Q22_Q24_24 : signed(47 downto 0) := to_signed(10065, 48);
constant Q33_Q24_24 : signed(47 downto 0) := to_signed(75497472, 48);
```

### Expected Performance
- **Typical acceleration**: ~15-25 m/s²
- **Max speed**: ~40 m/s
- **RMSE**: 2-4m
- **Convergence**: ~15 cycles (more aggressive filtering)

---

## 3. Highway Vehicle Tracking

**Application**: Cars/trucks on highway, steady cruise with occasional lane changes

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 25.0 m²        -- ±5m
P0_vel = 100.0 (m/s)²   -- ±10 m/s
P0_acc = 2.0 (m/s²)²    -- ±1.4 m/s²

-- Process Noise Q (q_power = 14.06, dt = 0.02)
Q11, Q44, Q77 = 0           -- Position
Q22, Q55, Q88 = 629         -- Velocity (0.0000375 in Q24.24)
Q33, Q66, Q99 = 4718592     -- Acceleration (0.28 in Q24.24)

-- Measurement Noise R
R11, R22, R33 = 0.50 m²     -- Radar/lidar
```

### Q24.24 Constants
```vhdl
constant Q22_Q24_24 : signed(47 downto 0) := to_signed(629, 48);
constant Q33_Q24_24 : signed(47 downto 0) := to_signed(4718592, 48);
constant R11_Q24_24 : signed(47 downto 0) := to_signed(8388608, 48);
```

### Expected Performance
- **Typical acceleration**: ~1-3 m/s²
- **Max speed**: ~30 m/s (110 km/h)
- **RMSE**: 0.5-2m
- **Convergence**: ~5 cycles

---

## 4. Urban Vehicle Tracking

**Application**: City traffic, frequent stops, acceleration/braking

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 50.0 m²        -- ±7m
P0_vel = 200.0 (m/s)²   -- ±14 m/s
P0_acc = 5.0 (m/s²)²    -- ±2.2 m/s²

-- Process Noise Q (q_power = 56.25, dt = 0.02)
Q22_Q24_24 = 2516           -- Same as drone (moderate)
Q33_Q24_24 = 18874368

-- Measurement Noise R
R11, R22, R33 = 1.00 m²     -- Noisy GPS in urban canyon
```

### Q24.24 Constants
```vhdl
constant R11_Q24_24 : signed(47 downto 0) := to_signed(16777216, 48);  -- 1.0 m²
```

### Expected Performance
- **Typical acceleration**: ~3-8 m/s²
- **Max speed**: ~15 m/s (55 km/h)
- **RMSE**: 1-3m (urban GPS degradation)
- **Convergence**: ~10 cycles

---

## 5. Aircraft Tracking (Cruise)

**Application**: Commercial aircraft, steady flight, minimal maneuvers

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 100.0 m²       -- ±10m
P0_vel = 2500.0 (m/s)²  -- ±50 m/s
P0_acc = 1.0 (m/s²)²    -- ±1 m/s²

-- Process Noise Q (q_power = 3.52, dt = 0.02)
Q22_Q24_24 = 157            -- Very low (smooth flight)
Q33_Q24_24 = 1179648        -- Low acceleration changes

-- Measurement Noise R
R11, R22, R33 = 2.00 m²     -- Radar tracking
```

### Q24.24 Constants
```vhdl
constant Q22_Q24_24 : signed(47 downto 0) := to_signed(157, 48);
constant Q33_Q24_24 : signed(47 downto 0) := to_signed(1179648, 48);
constant R11_Q24_24 : signed(47 downto 0) := to_signed(33554432, 48);  -- 2.0 m²
```

### Expected Performance
- **Typical acceleration**: ~0.5-2 m/s²
- **Max speed**: ~250 m/s (900 km/h)
- **RMSE**: 2-5m
- **Convergence**: ~5 cycles

---

## 6. Aircraft Tracking (Tactical)

**Application**: Fighter jets, evasive maneuvers, combat scenarios

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 200.0 m²       -- ±14m
P0_vel = 10000.0 (m/s)² -- ±100 m/s
P0_acc = 50.0 (m/s²)²   -- ±7 m/s²

-- Process Noise Q (q_power = 225.0, dt = 0.02)
Q22_Q24_24 = 10065          -- High for maneuvers
Q33_Q24_24 = 75497472       -- High acceleration changes

-- Measurement Noise R
R11, R22, R33 = 1.00 m²     -- Radar
```

### Expected Performance
- **Typical acceleration**: ~10-30 m/s² (1-3 G)
- **Max speed**: ~500 m/s (Mach 1.5)
- **RMSE**: 3-8m
- **Convergence**: ~20 cycles (aggressive)

---

## 7. Pedestrian Tracking

**Application**: Walking humans, crowd tracking, surveillance

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 10.0 m²        -- ±3m
P0_vel = 4.0 (m/s)²     -- ±2 m/s
P0_acc = 0.5 (m/s²)²    -- ±0.7 m/s²

-- Process Noise Q (q_power = 3.52, dt = 0.02)
Q22_Q24_24 = 157            -- Very low (slow motion)
Q33_Q24_24 = 1179648

-- Measurement Noise R
R11, R22, R33 = 0.10 m²     -- Visual tracking (camera)
```

### Q24.24 Constants
```vhdl
constant R11_Q24_24 : signed(47 downto 0) := to_signed(1677721, 48);  -- 0.1 m²
```

### Expected Performance
- **Typical acceleration**: ~0.5-2 m/s²
- **Max speed**: ~3 m/s (walking)
- **RMSE**: 0.2-0.5m
- **Convergence**: ~3 cycles

---

## 8. Ballistic Trajectory Tracking

**Application**: Projectiles, missiles, artillery shells

### Parameters
```vhdl
-- Initial Covariance P0
P0_pos = 500.0 m²       -- ±22m
P0_vel = 40000.0 (m/s)² -- ±200 m/s
P0_acc = 100.0 (m/s²)²  -- ±10 m/s² (gravity + drag)

-- Process Noise Q (q_power = 900.0, dt = 0.02)
Q22_Q24_24 = 40259          -- Very high
Q33_Q24_24 = 301989888      -- Very high (ballistic physics)

-- Measurement Noise R
R11, R22, R33 = 0.50 m²     -- Radar
```

### Q24.24 Constants
```vhdl
constant Q22_Q24_24 : signed(47 downto 0) := to_signed(40259, 48);
constant Q33_Q24_24 : signed(47 downto 0) := to_signed(301989888, 48);
```

### Expected Performance
- **Typical acceleration**: ~30-100 m/s² (gravity + drag)
- **Max speed**: ~1000 m/s (supersonic)
- **RMSE**: 5-15m
- **Convergence**: ~30 cycles (very aggressive)

---

## How to Apply Parameters

### Method 1: Edit VHDL Constants

Edit `process_noise_3d.vhd` lines 45-65:

```vhdl
-- Choose one configuration above, then update these lines:
constant Q11_Q24_24 : signed(47 downto 0) := to_signed(0, 48);        -- Position
constant Q22_Q24_24 : signed(47 downto 0) := to_signed(2516, 48);     -- Velocity (from table)
constant Q33_Q24_24 : signed(47 downto 0) := to_signed(18874368, 48); -- Acceleration (from table)
```

Edit `state_update_3d.vhd` lines 125-127:

```vhdl
constant R11_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);  -- R from table
constant R22_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);
constant R33_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);
```

Edit `ukf_supreme_3d.vhd` initial P0 values (lines 180-200).

### Method 2: Use Python Script

```bash
python3 scripts/set_ukf_parameters.py --config drone_moderate
```

(Create this script to automate parameter updates)

---

## Process Noise Formula

For reference, Q values are derived from:

```
q_power = acceleration_variance²
dt = time_step (0.02 seconds for 50Hz)

Q_pos = q_power * (dt⁵ / 20)     ≈ 0 (negligible)
Q_vel = q_power * (dt³ / 3)      (velocity process noise)
Q_acc = q_power * dt              (acceleration process noise)
```

**Example for drone (moderate):**
```
q_power = 56.25 (σ_a ≈ 7.5 m/s²)
Q_vel = 56.25 * (0.02³ / 3) = 0.00015 m²/s
Q_acc = 56.25 * 0.02 = 1.125 m²/s²
```

---

## Tuning Guidelines

### When to Increase Q (More Process Noise):
- Target makes frequent, unpredictable maneuvers
- Measurements are very accurate (low R)
- Filter is too slow to respond (lagging)

### When to Decrease Q (Less Process Noise):
- Target motion is very smooth
- Measurements are noisy (high R)
- Filter is too jittery (high-frequency noise)

### When to Increase R (More Measurement Noise):
- Sensors are noisy or unreliable
- Urban environment (GPS degradation)
- Filter trusts model too much

### When to Decrease R (Less Measurement Noise):
- High-quality sensors (RTK-GPS, lidar)
- Open sky conditions
- Filter trusts measurements too much

---

## Testing Your Configuration

After setting parameters:

1. **Compile and run** simulation on test dataset
2. **Check RMSE** - should be 2-5× sensor noise (R)
3. **Verify convergence** - covariance should stabilize within 10-30 cycles
4. **Check innovation** - residuals should be zero-mean, white noise
5. **Monitor covariance** - P should not grow unbounded or collapse to zero

---

Last updated: February 4, 2026
