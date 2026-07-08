# Eval notes


## "What type does `open()` return?"

### Buffer types
- Unbuffered — every write goes out immediately.
  stderr is typically unbuffered
  (you want errors to appear right away, even if the program crashes a millisecond later).
- Line-buffered — the buffer is flushed whenever a newline \n is written.
  This is what stdout uses when it's connected to a terminal.
  So each print() shows up as soon as its line completes — feels immediate.
- Block-buffered (a.k.a. full buffering) — the buffer is only flushed when it fills up to a fixed size (commonly 4 KB or 8 KB),
  or when the file is closed,
  or when you explicitly flush().
  This is what stdout switches to when it's not a terminal — i.e. when it's redirected to a file or a pipe.

### In python
- `open()` returns **file object**,
  which is an **`io.TextIOWrapper`** when opened in text mode (default)
- More generally it's an object satisfying `typing.IO[str]` (text) or `typing.IO[bytes]` (binary)
- text mode → `io.TextIOWrapper`;
  binary buffered → `io.BufferedReader`/`BufferedWriter`;
  raw → `io.FileIO`.
  All are subtypes of `io.IOBase`.
- One-line answer for the eval: **"A file object — specifically an `io.TextIOWrapper` in text mode, typed as `typing.IO[str]`."**

---

## File modes (ex1 hint: "create or replace")

| Mode | Meaning | If file exists | If missing |
|------|---------|----------------|------------|
| `"r"` | read (default) | reads | **error** (FileNotFoundError) |
| `"w"` | write | **truncates to empty** | creates |
| `"a"` | append | writes at end | creates |
| `"x"` | exclusive create | **error** (FileExistsError) | creates |
| `"r+"` | read+write | keeps content | error |

- Default is **text mode** (`"t"`) with the platform's default encoding.
  Add `"b"` for bytes.

---

## Streams (ex2)

- Three standard streams: **stdin** (0, input), **stdout** (1, normal output), **stderr** (2, errors).
  Older than the internet — the "three sacred channels."
- `.rstrip("\n")` on the readline result — strips the trailing newline that `readline()` keeps
  (unlike `input()`, which drops it).
- **Buffering / flushing:** stdout is line-buffered to a terminal but **block-buffered to a pipe**,
  and stderr is usually unbuffered.
  When mixing the two, output can appear out of order.
  That's why the code calls `flush()` — to force pending stdout out before writing to stderr so the messages stay in the right order.
  Be ready to explain *why the flush is there.*

---

## Why `try/finally` in ex0–ex2 instead of `with`

Because the subject **forbids `with` before ex3**.
`try/finally` gives the same guarantee manually:

```python
file = open(path)      # may raise -> caught by outer try/except
try:
    ...                # use the file
finally:
    file.close()       # runs even if the body raises -> no leak
```

`finally` is the manual version of `__exit__`.
If asked "why not just call `.close()` at the end?" → because an exception in the body would skip it;
`finally` (and `with`) run regardless.

---

## Misc

- **Q: What does `open()` return?**
  → A file object / `io.TextIOWrapper`, typed `typing.IO[str]`.
- **Q: What happens if you don't close a file?**
  → The OS file descriptor leaks;
  buffered writes may not be flushed to disk.
  `with`/`finally` prevents this.
- **Q: Difference between `"w"` and `"a"`?**
  → `"w"` truncates then writes from the top;
  `"a"` appends at the end.
- **Q: How does `with` know to close the file?**
  → The file object implements `__enter__`/`__exit__`;
  `with` calls `__exit__` on block exit, which closes it.
- **Q: Why print errors to stderr?**
  → Separates errors from real output so pipes/redirects (`2>`) can handle them independently;
  stdout stays clean data.
- **Q: `FileNotFoundError` vs `PermissionError`?**
  → Errno 2 (missing) vs Errno 13 (no access rights);
  both subclass `OSError`.
- **Q: What does `secure_archive` return and why a tuple?**
  → `(bool, str)`: success flag + payload (file contents on read, confirmation msg on write, or the error string on failure).
  The immutable pair cleanly signals outcome + data in one value.
- **Q: What's `read_result[1]` in ex3?**
  → The content string read from the regular file, reused as the payload written to the new file.
