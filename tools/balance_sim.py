"""Offline simulator for the zombies balance math.

Mirrors common/math.xs (pow, sqrt, powFloat), common/balance/balanceMath.xs
(getGenericTeamScale) and the Director daily factor in
zombies/mapGen/director/director.xs. Keep the defaults in sync with
zombies/globals.xs.

Usage:
    python tools/balance_sim.py scale
    python tools/balance_sim.py days --destruction 0.0 0.1 0.2 0.4 0.6
    python tools/balance_sim.py check
"""

import argparse
import math

ALPHA_SENSITIVITY = 2.5
EXPONENT_K = 0.70
TARGET_DESTRUCTION = 0.2
MIN_DAILY_BUFF = 1.0
MAX_DAILY_BUFF = 1.5
MIN_FLOOR = 1.0
MAX_CAP = 6.0


def xs_pow(n, x):
    if x == 0:
        return 1.0
    r = n
    for _ in range(1, abs(x)):
        r *= n
    return 1.0 / r if x < 0 else r


def xs_sqrt(s):
    if s < 0.0:
        s = -s
    h = 10.0
    for _ in range(6):
        h = (h + s / h) / 2.0
    return (h + s / h) / 2.0


def xs_pow_float(n, x):
    if x == 0.0:
        return 1.0
    invert = x < 0.0
    if invert:
        x = -x
    whole = int(x)
    fraction = x - whole
    result = xs_pow(n, whole)
    root = n
    for _ in range(24):
        root = xs_sqrt(root)
        fraction *= 2.0
        if fraction >= 1.0:
            result *= root
            fraction -= 1.0
    return 1.0 / result if invert else result


def generic_team_scale(
    my_size, opposing_size, k=EXPONENT_K, min_floor=MIN_FLOOR, max_cap=MAX_CAP
):
    if my_size <= 0 or opposing_size <= 0:
        return 1.0
    scale = xs_pow_float(opposing_size / my_size, k)
    return min(max(scale, min_floor), max_cap)


def daily_factor(destruction, alpha, target, min_factor, max_factor):
    raw = 1.0 + alpha * (target - destruction)
    return min(max(raw, min_factor), max_factor)


def cmd_check(_args):
    print("powFloat vs math.pow (XS approximation error)")
    worst = 0.0
    for base in (0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 25.0):
        for exponent in (0.3, 0.7, 1.5, -0.7):
            actual = xs_pow_float(base, exponent)
            expected = math.pow(base, exponent)
            error = abs(actual - expected) / expected
            worst = max(worst, error)
            print(f"  {base:>5}^{exponent:<5} {actual:10.6f} {expected:10.6f} rel.err {error:.2e}")
    print(f"worst relative error: {worst:.2e}")


def cmd_scale(args):
    sizes = range(1, args.max_team + 1)
    print(f"getGenericTeamScale(zombies, humans), k={args.k}, floor={MIN_FLOOR}, cap={MAX_CAP}")
    print("zombies\\humans " + "".join(f"{h:>7}" for h in sizes))
    for zombies in sizes:
        row = "".join(f"{generic_team_scale(zombies, h, args.k):7.2f}" for h in sizes)
        print(f"{zombies:>14} {row}")


def cmd_days(args):
    scale = generic_team_scale(args.zombies, args.humans, args.k)
    print(f"{args.zombies} zombie player(s) vs {args.humans} human(s): team scale {scale:.3f}")
    print("The team scale is applied once at setup; each night applies only dailyFactor.")
    print("day  destruction  dailyFactor  cumulativeHP")
    cumulative = scale
    for day, destruction in enumerate(args.destruction, start=1):
        factor = daily_factor(
            destruction, args.alpha, args.target, args.min_buff, args.max_buff
        )
        cumulative *= factor
        print(f"{day:>3}  {destruction:>11.2f}  {factor:>11.3f}  {cumulative:>12.3f}")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("check", help="compare powFloat against math.pow").set_defaults(func=cmd_check)

    scale = sub.add_parser("scale", help="print a team size scale table")
    scale.add_argument("--max-team", type=int, default=10)
    scale.add_argument("--k", type=float, default=EXPONENT_K)
    scale.set_defaults(func=cmd_scale)

    days = sub.add_parser("days", help="simulate daily factors from tower destruction ratios")
    days.add_argument("--destruction", type=float, nargs="+", required=True)
    days.add_argument("--zombies", type=int, default=1)
    days.add_argument("--humans", type=int, default=10)
    days.add_argument("--k", type=float, default=EXPONENT_K)
    days.add_argument("--alpha", type=float, default=ALPHA_SENSITIVITY)
    days.add_argument("--target", type=float, default=TARGET_DESTRUCTION)
    days.add_argument("--min-buff", type=float, default=MIN_DAILY_BUFF)
    days.add_argument("--max-buff", type=float, default=MAX_DAILY_BUFF)
    days.set_defaults(func=cmd_days)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
