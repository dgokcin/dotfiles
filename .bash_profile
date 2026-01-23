# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{aliases,functions,path,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
if [ -f "/Users/denizgokcin/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/denizgokcin/.config/fabric/fabric-bootstrap.inc"; fi
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
