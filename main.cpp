#include <iostream>
#include <filesystem>
#include <vector>
#include <string>
#include <future> // <-- for std::async
#include <mutex>
using namespace std;

// ======================== Initialisation =============================
namespace fsx = filesystem;
mutex output_mutex;

template <typename T>
using list = std::vector<T>;

// ============================= func : find files recursivel : find_files ===========================
list<fsx::path> find_files_in_dir(const fsx::path &dir, const string &pattern)
{
    list<fsx::path> matches;

    cout << "🔍 Searching for files in: " << fsx::absolute(dir) << endl;
    cout << "🫤 Pattern to match: \n"
         << pattern << "\"n\n";

    for (const auto &entry : fsx::recursive_directory_iterator(dir))
    {
        cout << "📂 Checking: " << entry.path() << endl;

        if (fsx::is_regular_file(entry))
        {
            string filename = entry.path().filename().string();

            if (filename.find(pattern) != string::npos)
            {
                cout << "✅ Matched: " << entry.path() << endl;
                matches.push_back(entry.path());
            };
        }
    };

    return matches;
}

// =================== App Entry Point =========================
int main()
{
    fsx::path root = ".";
    string pattern = "_x_";
    auto start_time = chrono::high_resolution_clock::now(); // Start timer

    list<future<list<fsx::path>>> futures;

    for (const auto &entry : fsx::directory_iterator(root))
    {
        if (entry.is_directory())
        {
            futures.push_back(async(launch::async, find_files_in_dir, entry.path(), pattern));
        }
    };

    // files directly under root
    list<fsx::path> main_dir_matches = find_files_in_dir(root, pattern);

    for (auto &f : futures)
    {
        auto sub_matches = f.get();
        main_dir_matches.insert(main_dir_matches.end(), sub_matches.begin(), sub_matches.end());
    }

    if (main_dir_matches.size() > 0)
    {
        for (const auto &file : main_dir_matches)
        {
            cout << "matched file: " << file << endl;
        }
    }
    else
    {
        cout << "╰─ ‼️  NO Match Found \n"
             << endl;
    }

    auto end_time = chrono::high_resolution_clock::now(); // End timer
    auto duration_ms = chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();

    cout << "⏱️  Total execution time: " << duration_ms << " ms" << endl;

    return 0;
}
