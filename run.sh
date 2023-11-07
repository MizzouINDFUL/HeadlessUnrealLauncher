THISFOLDER=$(dirname $(readlink -f $0))
source $THISFOLDER/src/scripts/shared.sh
eval $(parse_yaml $HOME_DIR/config.yml)

export UELAUNCHER_HOME=$HOME_DIR
export SIM_START_DATE=$(date +%Y-%m-%d_%H-%M-%S)

echo "" > $HOME_DIR/src/logs/Unreal.log

#This will initiate the basic structure of tmux:
# - Unreal Engine: This is where we are talking to the instance of UE: both compilation adn the launch of the project are happening here
# - tellunreal: a window where we can send commands to the Unreal Engine instance. For example: tellunreal 'py print("hello world")' will execute a hello world command in the Unreal Engine instance
# - Orchestartor: a window that tracks the logs of the current Unreal Engine instance and launches scripts whenever it sees trigger phrases in it. Initially this will be create with nothing running in it. But users can new panes to this that will run actual listener scripts whenever it is needed.

tmux new-session -d -s SIM -n UnrealEngine
tmux new-window -t SIM:1 -n tellunreal
tmux new-window -t SIM:2 -n Orchestrator

tmux pipe-pane -o -t SIM:UnrealEngine "cat >> $HOME_DIR/src/logs/Unreal.log"

# Examples of how to bind scripts to events:
# bind_script_to_event "Editor Started" $HOME_DIR/src/scripts/dummy.sh
# bind_script_to_event "another test" $HOME_DIR/src/scripts/dummy.sh
# bind_script_to_event "and another one" $HOME_DIR/src/scripts/dummy.sh

#preparing to launch Unreal Engine
tmux send-keys -t SIM:UnrealEngine "$HOME_DIR/src/scripts/unreal/init_unreal.sh" C-m

#when External Command Line object is initialized, create an alias called 'tellunreal' inside tellunreal tmux window that will send the argument to command.txt in src/plugins_link/CommandLineExternal
bind_script_to_event "External Command Line object is initialized" $HOME_DIR/src/scripts/unreal/start_tellunreal.sh

tmux set -g mouse on
tmux attach-session -t SIM:0