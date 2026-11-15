#!/usr/bin/env python3
"""Audit the Icarus demo VCD and export stable falling-edge samples (1 ps units)."""
import csv
from pathlib import Path


def read_vcd(path):
    scope, names, values, samples = [], {}, {}, []
    timestamp = None
    previous_clock = None

    def capture():
        nonlocal previous_clock
        clock = values.get(names['tb_pipeline.clk'])
        if clock == 0 and previous_clock == 1:
            samples.append((timestamp, values.copy()))
        previous_clock = clock

    for line in path.read_text().splitlines():
        parts = line.split()
        if not parts:
            continue
        if parts[0] == '$scope':
            scope.append(parts[2])
        elif parts[0] == '$upscope':
            scope.pop()
        elif parts[0] == '$var':
            names['.'.join(scope + [parts[4]])] = parts[3]
        elif line.startswith('#'):
            if timestamp is not None:
                capture()
            timestamp = int(line[1:])
        elif timestamp is not None:
            if line[0] in 'bB':
                bits, code = parts[0][1:], parts[1]
            elif line[0] in '01xXzZ':
                bits, code = line[0], line[1:]
            else:
                continue
            values[code] = None if any(x in bits.lower() for x in 'xz') else int(bits, 2)
    if timestamp is not None:
        capture()
    return names, samples


def main():
    names, samples = read_vcd(Path('build/pipeline.vcd'))
    fields = ['cycles', 'pc', 'ev', 'ed', 'fa', 'fb', 'stall', 'a', 'b', 'result']
    rows = []
    for timestamp, values in samples:
        if values[names['tb_pipeline.reset']] != 0:
            continue
        # Skip the final held state after the forwarding core has completed.
        if values[names['tb_pipeline.fast.done']] != 0:
            continue
        row = {'time_ps': timestamp}
        row.update({f: values[names['tb_pipeline.fast.' + f]] for f in fields})
        if any(row[f] is None for f in fields):
            raise SystemExit('FAIL unknown value in active pipeline waveform')
        rows.append(row)
    checks = {
        'EX/MEM forwarding to operand A': lambda r: r['ev'] and r['ed'] == 6 and r['fa'] == 2 and r['a'] == 3,
        'MEM/WB forwarding to operand B': lambda r: r['ev'] and r['ed'] == 7 and r['fb'] == 1 and r['b'] == 3,
        'newest producer on both operands': lambda r: r['ev'] and r['ed'] == 8 and r['fa'] == r['fb'] == 2 and r['a'] == r['b'] == 10,
        'load-use interlock': lambda r: r['stall'] == 1 and r['ev'] and r['ed'] == 9,
        'loaded data forwarded after bubble': lambda r: r['ev'] and r['ed'] == 10 and r['fa'] == 1 and r['a'] == 103,
    }
    for label, predicate in checks.items():
        matches = [r['time_ps'] for r in rows if predicate(r)]
        if not matches:
            raise SystemExit('FAIL missing waveform case: ' + label)
        print(f'PASS waveform {label}: time_ps={matches[0]}')
    if sum(r['stall'] for r in rows) != 1:
        raise SystemExit('FAIL expected exactly one stalled cycle')
    with Path('build/waveform-cases.csv').open('w', newline='') as output:
        writer = csv.DictWriter(output, fieldnames=['time_ps'] + fields)
        writer.writeheader()
        writer.writerows(rows)


if __name__ == '__main__':
    main()
