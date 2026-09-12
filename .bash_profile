# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/denizgokcin/.docker/bin"
# End of Docker Desktop section.

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{aliases,functions,path,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
if [ -f "/Users/denizgokcin/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/denizgokcin/.config/fabric/fabric-bootstrap.inc"; fi
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/denizgokcin/.local/bin:$PATH"
