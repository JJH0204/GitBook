# vscode for mac

## c\_cpp\_properties.json

{% code title="c_cpp_properties.json" %}
```json
{

"configurations": [

{

"name": "Mac",

"includePath": [

"${workspaceFolder}/**"

],

"defines": [],

"macFrameworkPath": [

"/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks"

],

"compilerPath": "/usr/bin/clang",

"intelliSenseMode": "macos-clang-arm64",

"cStandard": "c11",

"cppStandard": "c++17",

"compilerArgs": ["-std=c++17", "-stdlib=libc++"]

}

],

"version": 4

}
```
{% endcode %}

***

## launch.json

{% code title="launch.json" %}
```json
{

"configurations": [

{

"name": "C/C++: clang++ 활성 파일 빌드 및 디버그",

"type": "cppdbg",

"request": "launch",

"program": "${fileDirname}/${fileBasenameNoExtension}",

"args": [],

"stopAtEntry": false,

"cwd": "${fileDirname}",

"environment": [],

"externalConsole": false,

"MIMode": "lldb",

"preLaunchTask": "C/C++: clang++ build active file"

}

],

"version": "2.0.0"

}
```
{% endcode %}

***

## tasks.json

{% code title="tasks.json" %}
```json
{

"version":"2.0.0",

"tasks": [

{

"type": "cppbuild",

"label": "C/C++: clang++ build active file",

"command": "/usr/bin/clang++",

"args":[

"-std=c++17",

"-stdlib=libc++",

"fdiagnostics-color=always",

"-g",

"${file}",

"-o",

"${fileDirname}/${fileBasenameNoExtension}"

],

"options": {

"cwd": "${fileDirname}"

},

"problemMatcher": ["$gcc"],

"group": {

"kind": "build",

"isDefault": true

},

"detail": "compiler: /usr/bin/clang++"

}

]

}
```
{% endcode %}
