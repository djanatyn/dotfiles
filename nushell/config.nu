use std/util "path add"

$env.LANG = "en_US.UTF-8"
$env.LC_CTYPE = "en_US.UTF-8"
$env.EDITOR = "nvim"
$env.TERM = "xterm-256color"
$env.GPG_TTY = (tty)
$env.PINENTRY_USER_DATA = "USE_CURSES=1"

$env.config.edit_mode = 'vi'
$env.config.buffer_editor = 'nvim'
$env.config.show_banner = false

const NODE_VERSION = "v20.19.0"

path add "/opt/homebrew/bin"
path add ($env.HOME | path join ".local" "bin")
path add ($env.HOME | path join ".nvm" "versions" "node" $NODE_VERSION "bin")
path add ($env.HOME | path join ".nix-profile" "bin")
path add ($env.HOME | path join ".cargo" "bin")

# catppucin_mocha theme
# https://github.com/catppuccin/nushell/blob/main/themes/catppuccin_mocha.nu
source ~/catppuccin_mocha.nu

# atuin
source ~/.local/share/atuin/init.nu 

def download-album [url: string] {
    let output = './%(artist)s - %(album)s'

    yt-dlp ...[
        --playlist-items 1
        --skip-download
        --write-thumbnail
        --convert-thumbnails jpg
        -o ($output + '/cover.%(ext)s')
    ] $url

    yt-dlp ...[
        --embed-metadata
        --audio-format mp3
        -x
        -o ($output + '/%(track)s.%(ext)s')
    ] $url
}

# Extract every *.zip in `dir` into a subdirectory named after the zip's stem.
# Deletes each zip only if its extraction succeeded (exit code 0).
def extract-zips [
    dir: path = .   # directory containing the zips
    --keep (-k)     # keep the zip files even on success
] {
    glob ($dir | path join "*.zip") | each {|zip|
        let stem = ($zip | path parse | get stem)
        let dest = ($dir | path join $stem)
        print $"extracting ($zip) -> ($dest)"
        let result = (unzip -o $zip -d $dest | complete)
        if $result.exit_code == 0 {
            print $result.stdout
            if not $keep {
                rm $zip
                print $"removed ($zip)"
            }
        } else {
            print -e $"FAILED ($zip), code ($result.exit_code):\n($result.stderr)"
        }
    }
}
