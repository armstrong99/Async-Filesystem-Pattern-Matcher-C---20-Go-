# 🔍 Async Filesystem Pattern Matcher

A modern C++20 program to **search for files** with a given substring pattern in their names — recursively and concurrently!

> 🧠 Uses **`std::filesystem`** for walking directories, and **`std::async`** for concurrency.
> 📦 Perfect for beginners exploring **modern C++**, file I/O, and multithreading.

---

## 📦 What This Program Does

- It **recursively scans** a directory tree.
- It **finds all files** that contain a given pattern in their filename.
- It **uses concurrency** to scan subdirectories in parallel, making it faster for large folder structures.
- It prints colorful logs showing:

  - Where it’s searching
  - What it’s checking
  - What matches

---

## 🚀 Getting Started

### 1. 🛠 Generate Random Files & Folders

To test the program, generate sample files and folders using this script:

```bash
bash fc.sh &
```

The script `fc.sh` (you should create it) could randomly create folders/files like:

```bash
mkdir -p testdir/{a,b,c} && touch testdir/a/file_x_a.txt testdir/b/hello_x_b.txt testdir/c/otherfile.txt
```

Make sure it creates multiple folders and files — some with `_x_` in the name.

---

### 2. ⚙️ Compile & Run (macOS / Clang)

Use the following command to compile and run with C++20 and `libc++`:

```bash
clang++ -std=c++20 -stdlib=libc++ main.cpp -o myprogram && ./myprogram
```

> ✅ This works well if you’re on **macOS** or using Clang with libc++.
> If using **GCC**, just use:
>
> ```bash
> g++ -std=c++20 main.cpp -o myprogram && ./myprogram
> ```

---

## 🔧 What’s Inside the Code

### Main Features:

- ✅ Uses `std::filesystem` (aliased as `fsx`)
- ✅ Recursively walks directories using `recursive_directory_iterator`
- ✅ Filters filenames that contain a given string
- ✅ Uses `std::async` to process each top-level subdirectory concurrently
- ✅ Mutex (`std::mutex`) is declared (but not used yet — you can extend with thread-safe logging!)

### Pattern to Match

The pattern used is:

```cpp
string pattern = "_x_";
```

So any file like:

```
file_x_a.txt
log_x_output.log
something_x_else.cpp
```

…will match.

---

## 🧵 Concurrency

We use this simple line to scan each subdirectory asynchronously:

```cpp
futures.push_back(async(launch::async, find_files_in_dir, entry.path(), pattern));
```

This allows each folder to be scanned in its own thread.
When all are done, we `get()` their results and merge into the main result.

---

## 📄 Sample Output

```
🔍 Searching for files in: "/Users/you/projects/testdir"
🫤 Pattern to match: _x_

📂 Checking: "/Users/you/projects/testdir/a/file_x_a.txt"
✅ Matched: "/Users/you/projects/testdir/a/file_x_a.txt"
📂 Checking: "/Users/you/projects/testdir/a/other.txt"
...
matched file: "./testdir/a/file_x_a.txt"
matched file: "./testdir/b/hello_x_b.txt"
```

---

## 💡 Extend It

Want to go further?

- Add mutex logging to avoid garbled output from multiple threads
- Replace the pattern with a command-line argument
- Store results in a file
- Add file size or date filtering using `fsx::file_size` or `last_write_time`

---

## 🧠 Learning Points

- `std::filesystem` = powerful, modern way to deal with paths & files.
- `std::async` = easy entry into concurrency.
- `string::npos` = sentinel meaning "not found".
- Using C++20 = clean, readable, and powerful for system programming.

---

## 🧪 Test Again

Re-run the program after modifying the file structure or script:

```bash
./myprogram
```

---

## ✅ Requirements

- C++20 compiler (Clang or GCC)
- POSIX shell (for `fc.sh`)
- No extra libraries needed

---
