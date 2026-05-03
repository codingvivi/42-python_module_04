import sys
import typing


def print_header(title: str) -> None:
    print(f"=== {title} ===")
    print("")


def main() -> None:
    if len(sys.argv) == 1:
        print(f"Usage: {sys.argv[0]} <file>")
        return

    print_header("Cyber archives recovery")

    file_path: str = sys.argv[1]
    print(f"Accessing file '{file_path}'")

    try:
        file: typing.IO = open(file_path, "r")
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
        return
    finally:
        file.close()
        print(f"File '{file_path}' closed")

    new_contents: str = "\n".join(line + "#" for line in file_contents.splitlines())

    print("Transform data:")
    print("---\n")
    print(f"{new_contents}")
    print("---")

    new_file_path: str = input("Enter new file name (or empty):")

    if not new_file_path:
        print("Not saving data")
        return

    try:
        new_file: typing.IO = open(new_file_path, "w")
        print(f"Saving data to '{new_file_path}'")
        new_file.write(new_contents)
        print(f"Data saved in file '{new_file_path}'.")

    except Exception as e:
        print(f"Error error writing file '{new_file_path}': {e}")


if __name__ == "__main__":
    main()
