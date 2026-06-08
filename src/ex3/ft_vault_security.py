READ = "r"
WRITE = "w"


def secure_archive(
    filename: str,
    action: str = READ,
    content: str = "",
) -> tuple[bool, str]:
    if action not in (READ, WRITE):
        return (False, f"Invalid action: {action!r}")
    try:
        with open(filename, action) as file:
            if action == READ:
                return (True, file.read())
            file.write(content)
            return (True, "Content successfully written to file")
    except OSError as e:
        return (False, str(e))


def print_header(title: str) -> None:
    print(f"=== {title} ===")
    print("")


def main() -> None:
    print_header("Cyber Archives Security")

    print("Using 'secure_archive' to read from a nonexistent file:")
    print(secure_archive("/not/existing/file"))
    print()

    print("Using 'secure_archive' to read from an inaccessible file:")
    print(secure_archive("/etc/master.passwd"))
    print()

    print("Using 'secure_archive' to read from a regular file:")
    read_result: tuple[bool, str] = secure_archive("ancient_fragment.txt")
    print(read_result)
    print()

    print("Using 'secure_archive' to write previous content to a new file:")
    print(secure_archive("new_fragment.txt", WRITE, read_result[1]))
    print()

    print("Using 'secure_archive' with an invalid action:")
    print(secure_archive("ancient_fragment.txt", "bogus"))


if __name__ == "__main__":
    main()
