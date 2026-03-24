#!/usr/bin/env python3
"""Download F1 qualifying telemetry from 2024 season for UKF stress testing"""

import fastf1
from pathlib import Path
import sys

# Enable caching to avoid repeated API calls
cache_dir = Path('../test_data/real_world/raw/f1_cache')
cache_dir.mkdir(parents=True, exist_ok=True)
fastf1.Cache.enable_cache(str(cache_dir))

# Select challenging races with diverse characteristics
races = [
    ('Monaco', 2024, 'Q'),       # Tight corners, heavy braking, 3D elevation
    ('Singapore', 2024, 'Q'),    # Street circuit, 90° corners
    ('Suzuka', 2024, 'Q'),       # High-speed 130R, aggressive transitions
    ('Silverstone', 2024, 'Q')   # Maggotts-Becketts complex (6 direction changes)
]

output_dir = Path('../test_data/real_world/raw/f1')
output_dir.mkdir(parents=True, exist_ok=True)

print("=== F1 Telemetry Download Starting ===\n")

for circuit, year, session_type in races:
    try:
        print(f"Downloading {circuit} {year} {session_type}...")

        session = fastf1.get_session(year, circuit, session_type)
        session.load()

        # Get fastest lap telemetry
        laps = session.laps
        fastest_lap = laps.pick_fastest()
        driver = fastest_lap['Driver']
        lap_time = fastest_lap['LapTime']

        # Get telemetry data with position, speed, acceleration
        telemetry = fastest_lap.get_telemetry()

        # Save telemetry data
        output_file = output_dir / f'{circuit.lower()}_{year}.pkl'
        telemetry.to_pickle(output_file)

        print(f"  ✓ Saved to {output_file.name}")
        print(f"  ✓ Fastest lap: {driver} - {lap_time}")
        print(f"  ✓ Telemetry points: {len(telemetry)}\n")

    except Exception as e:
        print(f"  ✗ ERROR downloading {circuit}: {e}\n")
        continue

print("=== F1 Telemetry Download Complete ===")
