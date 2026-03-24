#!/usr/bin/env python3
"""Quick script to convert VHDL Q24.24 outputs to decimal CSV"""

import pandas as pd
import numpy as np
from pathlib import Path

Q_SCALE = 2**24  # 16777216

def convert_q24_to_decimal(q24_value):
    """Convert Q24.24 fixed-point integer to decimal"""
    return float(q24_value) / Q_SCALE

def parse_vhdl_output(vhdl_file):
    """Parse VHDL output file (Q24.24 format)"""
    results = []

    with open(vhdl_file, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip empty lines and headers
            if not line or line.startswith('===') or line.startswith('Cycles:') or line.startswith('Total'):
                continue

            # Parse cycle lines
            if line.startswith('Cycle '):
                parts = line.split(': ')
                if len(parts) != 2:
                    continue

                cycle_num = int(parts[0].replace('Cycle', '').strip())

                # Parse state values
                state_parts = parts[1].split()
                states = {}
                for part in state_parts:
                    if '=' in part:
                        key, value = part.split('=')
                        states[key] = int(value)

                # Convert to decimal
                result = {
                    'cycle': cycle_num,
                    'time': cycle_num * 0.02,  # dt = 0.02 seconds
                    'est_x_pos': convert_q24_to_decimal(states.get('x_pos', 0)),
                    'est_x_vel': convert_q24_to_decimal(states.get('x_vel', 0)),
                    'est_x_acc': convert_q24_to_decimal(states.get('x_acc', 0)),
                    'est_y_pos': convert_q24_to_decimal(states.get('y_pos', 0)),
                    'est_y_vel': convert_q24_to_decimal(states.get('y_vel', 0)),
                    'est_y_acc': convert_q24_to_decimal(states.get('y_acc', 0)),
                    'est_z_pos': convert_q24_to_decimal(states.get('z_pos', 0)),
                    'est_z_vel': convert_q24_to_decimal(states.get('z_vel', 0)),
                    'est_z_acc': convert_q24_to_decimal(states.get('z_acc', 0)),
                }
                results.append(result)

    return pd.DataFrame(results)

if __name__ == "__main__":
    base_dir = Path(__file__).parent.parent
    vhdl_dir = base_dir / "results" / "vhdl_outputs" / "vivado"
    output_dir = base_dir / "results" / "vhdl_outputs" / "csv"
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 80)
    print("VHDL Q24.24 → CSV CONVERTER (Quick)")
    print("=" * 80)

    for vhdl_file in vhdl_dir.glob("vhdl_output_*.txt"):
        dataset_name = vhdl_file.stem.replace('vhdl_output_', '')
        print(f"\nProcessing: {vhdl_file.name}")

        try:
            df = parse_vhdl_output(vhdl_file)
            output_file = output_dir / f"vhdl_{dataset_name}.csv"
            df.to_csv(output_file, index=False, float_format='%.6f')
            print(f"  ✓ Saved {len(df)} cycles to {output_file}")
        except Exception as e:
            print(f"  ✗ Error: {e}")

    print("\n" + "=" * 80)
    print("CONVERSION COMPLETE")
    print(f"Output directory: {output_dir}")
    print("=" * 80)
