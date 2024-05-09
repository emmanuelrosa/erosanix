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

int main(int argc, char* argv[]) {
    const std::string OUTPUT_FILE = R"(C:\msvc-shim-output.txt)";
    std::string sourceFiles;
    std::string outputDll;
    std::string command = R"(C:\mingw\bin\g++.exe -D _WIN64 -U NOMINMAX -march=x86-64 -mtune=x86-64 -O2 -shared -static -static-libgcc -static-libstdc++ -s -fno-rtti -fno-exceptions -std=gnu++17 -Wno-deprecated )"; 
    bool collectSourceFiles = false;
    bool enableDebugging = false;

    for(int i = 0; i != argc; i++) {
        std::string arg(argv[i]);

        if(arg == "/link") collectSourceFiles = false;
        if(arg == "/JMC") enableDebugging = true;

        if(collectSourceFiles) {
            if(sourceFiles.empty()) {
                sourceFiles.append(arg);
            } else {
                sourceFiles.append(" ");
                sourceFiles.append(arg);
            }
        }

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

    if(enableDebugging) command.append("--verbose ");
    command.append(sourceFiles).append(" -o ").append(outputDll);
    command.append(" > ").append(OUTPUT_FILE).append(" 2>&1");

    std::cout << "MSVC shim (MinGW): Processing the following files:" << std::endl;
    printf("sources: %s\n", sourceFiles.c_str());
    printf("out: %s\n", outputDll.c_str());
    std::system(command.c_str());
    std::ifstream file(OUTPUT_FILE);
    std::istreambuf_iterator<char> it(file), end;
    std::string output{it, end};
    std::cout << output;
}
