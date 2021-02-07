# pastry

pastry is a command line tool to paste files to pastemyst

you can find the source here: [https://github.com/CodeMyst/pastry](https://github.com/CodeMyst/pastry)

## download

you can download the binaries from the release page on the github repo: [pastry/releases](https://github.com/CodeMyst/pastry/releases)

download from cli on linux:
```sh
wget https://github.com/CodeMyst/pastry/releases/download/v1.0.0/pastry-linux-64.tar.gz
```

after downloading just extract the archive file, and place it in some directory thats in your path

there is also a package for arch on the aur: [pastry-aur](https://aur.archlinux.org/packages/pastry/)

to build from source you will need dmd and dub, then just run `dub build`

## usage

create a paste from files and/or directories
```sh
pastry file1.txt file2.txt someDir/
```

set title
```sh
pastry file1.txt -t "paste title"
```

set language of all files
```sh
pastry file1 -l markdown
```

set expires in
```sh
pastry file1 -e oneHour
```

setting the default expires in time, this value will be used when you dont specify the `--expires|-e` option
```sh
pastry --set-default-expires oneDay
```

setting the language to be used for files without an extension, default is plaintext
```sh
pastry --set-no-extension markdown
```

set the token, you can get your token on your pastemyst profile settings page. once you set the token you can create private pastes, and all pastes you make will show on your profile
```sh
pastry --set-token <YOUR_TOKEN>

# create private paste
pastry file1.txt -p
```

