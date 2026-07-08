import sys
import typing


def print_header(title: str) -> None:
    print(f"=== {title} ===")
    print("")


def main() -> None:
    if len(sys.argv) == 1:
        print(f"Usage: {sys.argv[0]} <file>")
        return

    print_header("Cyber Archives Recovery")

    file_path: str = sys.argv[1]
    print(f"Accessing file '{file_path}'")

    try:
        file: typing.IO[str] = open(file_path)
    except Exception as e:
        print(f"Error opening file '{file_path}': {e}")
        return

    try:
        file_contents: str = file.read()

        print("---\n")
        print(f"{file_contents}")
        print("---")
    except Exception as e:
        print(f"Error opening file '{file_path}': {e}")
    finally:
        file.close()
        print(f"File '{file_path}' closed")


if __name__ == "__main__":
    main()
