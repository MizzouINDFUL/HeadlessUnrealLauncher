import unreal
import glob
import os

class CommandLineReader():
    def __init__(self) -> None:
        tickhandle = unreal.register_slate_pre_tick_callback(self.tick)
        #shutdown = unreal.register_python_shutdown_callback(self.shutdown)

        #get the name of the project
        project_path = unreal.Paths.project_dir()
        project_file = glob.glob(project_path + "*.uproject")
        self.project_name = os.path.splitext(os.path.basename(project_file[0]))[0]

        #self.pipe_path = f'/tmp/{self.project_name}_cmd'

        #open pipe to communicate with the editor
        #if not os.path.exists(self.pipe_path):
            #os.mkfifo(self.pipe_path)

        print("External Command Line object is initialized.")

    def __del__(self):
        self.shutdown()

    def shutdown(self):
        if os.path.exists(self.pipe_path):
            os.remove(self.pipe_path)
    
    def tick(self, delta_time):
        self.read_file_commands()
        #self.read_pipe_commands()

    '''
        example of sending a command to a pipe from the terminal:
        echo 'py print("Hello")' > /tmp/MyProject_cmd
    '''
    def read_pipe_commands(self):
        #open pipe to communicate with the editor
        pipe = open(self.pipe_path, 'r')

        #read the command
        command = pipe.read()

        #check if the string is empty
        if not command or command == "":
            return

        #execute the command
        unreal.SystemLibrary.execute_console_command(None, command)

        with open(self.pipe_path, 'w') as f:
            f.write("")

    def read_file_commands(self):
        #this text file will contain the command to execute
        command_file = unreal.Paths.project_plugins_dir() + "CommandLineExternal/command.txt"

        if os.path.exists(command_file):
            with open(command_file, "r") as f:
                command = f.read()
            #check if the string is empty
            if not command:
                return
            #execute the command
            unreal.SystemLibrary.execute_console_command(None, command)

            #empty the file
            with open(command_file, "w") as f:
                f.write("")

CommandLineReader()
