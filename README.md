## ⚙️ Setup

### 1. Generate Test Directories

Use a script like `fc.sh` to create test data:

```bash
mkdir -p testdir/{a,b,c}
touch testdir/a/file_x_a.txt testdir/b/hello_x_b.txt testdir/c/otherfile.txt
```

You can run:

```bash
bash fc.sh
```

Make sure to include some files with `_x_` in the filename.

---

## 🚀 Running the Programs

### Go (Recommended for Speed)

#### 🛠 Build & Run

```bash
go run main.go
```

#### Highlights

- Uses a **buffered `dirChan`** and a pool of workers (`NumCPU * 4`)
- Implements the **fan-out / fan-in** concurrency pattern
- Matches root files separately from subdirectory workers
- Uses `filepath.WalkDir` for efficient directory walking

#### Sample Output

```
🔍 Searching for files in: /absolute/path/to/testdir/a
🫤 Pattern to match: _x_
✅ Matched: /testdir/a/file_x_a.txt
...
⏱️  Total time spent is 6.6ms
```

---

### C++20

#### 🛠 Compile & Run

##### macOS (Clang)

```bash
clang++ -std=c++20 -stdlib=libc++ main.cpp -o cppmatcher && ./cppmatcher
```

##### Linux (GCC)

```bash
g++ -std=c++20 main.cpp -o cppmatcher && ./cppmatcher
```

#### Highlights

- Uses `std::filesystem::recursive_directory_iterator`
- Spawns one `std::async` thread **per top-level subdirectory**
- Gathers results using `future.get()` calls
- Measures total execution time using `std::chrono`

#### Sample Output

```
🔍 Searching for files in: "/absolute/testdir/b"
🫤 Pattern to match: _x_
✅ Matched: "/testdir/b/hello_x_b.txt"
⏱️  Total execution time: 18 ms
```

---

## ⚖️ Performance Comparison

| Language | Concurrency Model      | Directory Handling             | Execution Time |
| -------- | ---------------------- | ------------------------------ | -------------- |
| **Go**   | Goroutines + Channels  | `filepath.WalkDir` (fast)      | \~6ms          |
| **C++**  | `std::async` + Futures | `recursive_directory_iterator` | \~18ms         |

> 💡 Go is significantly faster here due to lightweight goroutines, buffered channels, and more optimized directory traversal.

---

## 🧵 Concurrency Details

### Go: Fan-Out / Fan-In Pattern

- Buffered `dirChan` distributes directories to worker goroutines
- Each goroutine runs `findFilesMatchingPattern(dir, pattern)`
- A `matchesChan` collects results and merges them at the end
- Uses `sync.WaitGroup` to handle fan-in

### C++: `std::async` Thread-per-Dir

- Each top-level subdirectory gets an `async` call
- Root files are processed synchronously
- Results are collected by waiting on futures
- Good for smaller workloads; overhead increases with scale

---

## 🧪 Extending the Tools

Ideas for extending either version:

- Accept pattern and path as **CLI arguments**
- Add **file metadata filters** (size, last modified)
- Write results to a file or CSV
- Use **mutex** in C++ to log safely from threads
- Add context cancellation in Go for large scans

---

## 📁 Directory Structure

```
.
├── fc.sh           # test data generator
├── main.cpp        # C++20 version
├── main.go         # Go version
└── README.md       # this file
```

---

## ✅ Requirements

| Language | Version     | Notes                     |
| -------- | ----------- | ------------------------- |
| Go       | ≥ 1.18      | Uses goroutines, channels |
| C++      | ≥ C++20     | Requires std::filesystem  |
| OS       | macOS/Linux | POSIX shell for `fc.sh`   |

---

## 🏁 Conclusion

This project is a great example of using **modern C++ and Go idioms** to solve a real-world filesystem problem efficiently.

Both are valid, but when performance and concurrency scaling matter, Go’s model clearly wins — thanks to lightweight goroutines and buffered work distribution.

---
