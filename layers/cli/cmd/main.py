#!/usr/bin/env python3
import argparse
import sys


def main():
    parser = argparse.ArgumentParser(description="[PROJECT_NAME]")
    parser.add_argument("--version", action="version", version="0.1.0")

    subparsers = parser.add_subparsers(dest="command")

    # Add subcommands here
    # run_parser = subparsers.add_parser("run", help="Run something")

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
