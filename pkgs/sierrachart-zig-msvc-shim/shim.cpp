/* Copyright (C) 2024 Emmanuel Rosa
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <iterator>
#include <string>
#include <iomanip>
#include <sstream>
#include <vector>
#include <chrono>
#include <thread>
#include <filesystem>
#include <regex>

/* shim.cpp
 * 
 * This is a shim for the MSVC (Microsoft Visual C++) compiler,
 * designed to compile Sierra Chart studies using the Zig compiler
 * (Clang) when running Sierra Chart on Linux using Wine.
 *
 * It works by parsing the arguments to vl.exe as specified in
 * Sierra Chart's VisualCCompile.Bat, to look for the source files
 * and the final DLL file name. It then uses that information to
 * call the Zig compiler to compile the Sierra Chart study.
 */

std::string readFile(const std::string s) {
    std::ifstream file(s);
    std::istreambuf_iterator<char> it(file), end;
    return {it, end};
}

/* Converts the given Windows path into a UNIX path,
 * while rooting the C: drive in the $WINEPREFIX/drive_c
 * and the Z: drive in the UNIX / directory.
 */
std::string convertToUnixPath(const std::string path) {
    std::regex slashRegex(R"(\\)");
    std::regex cDriveRegex("C:");
    std::regex zDriveRegex("Z:");

    std::string out = std::regex_replace(path, slashRegex, R"(/)");
    out = std::regex_replace(out, cDriveRegex, R"($WINEPREFIX/drive_c)");
    out = std::regex_replace(out, zDriveRegex, R"()");

    return out;
}

int main(int argc, char* argv[]) {
    using namespace std::chrono_literals;

    const std::string SEPARATOR = "*************************************************************";
    const std::string OUTPUT_FILE = R"(C:\windows\temp\msvc-shim-output.txt)";
    const std::string PID_FILE = R"(C:\windows\temp\msvc-shim.pid)";
    const std::filesystem::path pidFilePath{PID_FILE};

    // Give the runner a maximum of 4 seconds to start.
    const std::chrono::duration RUNNER_START_DELAY = 100ms;
    const int RUNNER_START_RETRY = 40;

    // Give the runner a maximum of 5 minutes to finish.
    const std::chrono::duration RUNNER_END_DELAY = 100ms;
    const int RUNNER_END_RETRY = 3000;

    std::vector<std::string> sourceFiles;
    std::string outputDll;
    std::string command = R"(cmd.exe /c C:\msvc-shim\runner.sh)";
    bool collectSourceFiles = false;
    bool enableDebugging = false;
    bool runnerStarted = false;
    bool runnerFinished = false;

    for(int i = 0; i != argc; i++) {
        std::string arg(argv[i]);

        if(arg == "/link") collectSourceFiles = false;
        if(arg == "/JMC") enableDebugging = true;

        if(collectSourceFiles) sourceFiles.push_back(arg);

        if(arg == "/nologo") collectSourceFiles = true;
        if(arg.starts_with("/OUT:")) outputDll = arg.substr(5);
    }

    if(sourceFiles.empty()) {
        std::cout << "ERROR: Unable to detect source files." << std::endl;
        return 1;
    }

    if(outputDll.empty()) {
        std::cout << "ERROR: Unable to detect output DLL name." << std::endl;
        return 1;
    }

    command.append(" ");
    if(enableDebugging) command.append("-d ");
    command.append(" -o ").append(convertToUnixPath(outputDll));
    command.append(" ");

    for(std::string file : sourceFiles) {
        command.append(" -s ").append(convertToUnixPath(file));
    }

    command.append(" > ").append(OUTPUT_FILE).append(" 2>&1");

    std::cout << "Sierra Chart MSVC shim (Zig/Clang implementation)" << std::endl;
    if(enableDebugging) printf("cmd: %s\n", command.c_str());
    std::remove(PID_FILE.c_str());
    std::remove(OUTPUT_FILE.c_str());

    std::system(command.c_str());
    if(enableDebugging) std::cout << "Waiting on runner to start..." << std::endl;

    for(int i = 0; i < RUNNER_START_RETRY; i++) {
        if(std::filesystem::exists(pidFilePath)) {
            runnerStarted = true;
            break;
        }
        std::this_thread::sleep_for(RUNNER_START_DELAY);
    }

    if(!runnerStarted) {
        std::cout << "ERROR: Runner failed to start within the allotted time!" << std::endl;
        return 1;
    };

    std::string pid = readFile(PID_FILE);
    std::string runnerProcessPathStr = R"(Z:\proc\)";
    runnerProcessPathStr.append(pid);
    std::filesystem::path runnerProcessPath = std::filesystem::path(runnerProcessPathStr);
    if(enableDebugging) std::cout << "Waiting on runner to finish (" << runnerProcessPath.string() << ")..." << std::endl;

    for(int i = 0; i < RUNNER_END_RETRY; i++) {
        if(!std::filesystem::exists(runnerProcessPath)) {
            runnerFinished = true;
            break;
        }

        std::this_thread::sleep_for(RUNNER_END_DELAY);
    }

    if(!runnerFinished) {
        std::cout << "ERROR: Runner failed to finish within the allotted time!" << std::endl;
        return 1;
    };

    std::cout << SEPARATOR << std::endl;
    std::cout << SEPARATOR << std::endl;
    std::cout << readFile(OUTPUT_FILE);
}
