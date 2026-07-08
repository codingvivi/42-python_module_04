import sys
import typing


def print_header(title: str) -> None:
    print(f"=== {title} ===")
    print("")


def main() -> None:
    if len(sys.argv) == 1:
        print(f"Usage: {sys.argv[0]} <file>")
        return

    print_header("Cyber Archives Recovery & Preservation")

    file_path: str = sys.argv[1]
    print(f"Accessing file '{file_path}'")

    try:
        file: typing.IO[str] = open(file_path)
    except Exception as e:
        sys.stdout.flush()
        print(
            f"[STDERR] Error opening file '{file_path}': {e}",
            file=sys.stderr,
            flush=True,
        )
        return

    try:
        file_contents: str = file.read()

        print("---\n")
        print(f"{file_contents}")
        print("---")
    except Exception as e:
        sys.stdout.flush()
        print(
            f"[STDERR] Error opening file '{file_path}': {e}",
            file=sys.stderr,
            flush=True,
        )
        return
    finally:
        file.close()
        print(f"File '{file_path}' closed")

    new_contents: str = (
        "\n".join(line + "#" for line in file_contents.splitlines()) + "\n"
    )

    print("Transform data:")
    print("---\n")
    print(f"{new_contents}")
    print("---")

    print("Enter new file name (or empty):", end="", flush=True)
    new_file_path: str = sys.stdin.readline().rstrip("\n")

    if not new_file_path:
        print("Not saving data")
        return

    new_file: typing.IO[str] | None = None
    try:
        new_file = open(new_file_path, "w")

        print(f"Saving data to '{new_file_path}'")
        new_file.write(new_contents)
        new_file.flush()

        print(f"Data saved in file '{new_file_path}'.")
    except Exception as e:
        sys.stdout.flush()
        print(
            f"[STDERR] Error writing file '{new_file_path}': {e}",
            file=sys.stderr,
            flush=True,
        )
        print("Data not saved")
    finally:
        if new_file is not None:
            new_file.close()
            print(f"new_File '{new_file_path}' closed")


if __name__ == "__main__":
    main()
