# START: Jabba's Python virtualenv tools
# heavily inspired by https://github.com/jaapz/virtualenv-tools

# virtualenvs will be created in this directory
# if this variable is not defined, then the virtualenv will be created in the project folder
export WORKON_HOME=$HOME/.virtualenvs

# first call this function to initialize the project folder
# venv_make requires an initialized project folder
function venv_init () {
    if [[ -f ./python_version.txt ]]; then
        echo "Warning! The file \"python_version.txt\" already exists!"
    else
        echo -n "Do you want a Python 2 or a Python 3 project? (2, 3): "
        read py_ver
        if [[ "$py_ver" != "2" && "$py_ver" != "3" ]]; then
            echo "Invalid option."
            return 1
        fi
        #
        echo "python${py_ver}" > ./python_version.txt
        echo "The project was initialized as a Python ${py_ver} project."
    fi
}

# create a Python 2 or Python 3 virtual environment
# depending on how the folder was initialized
function venv_make () {
    if [ -z "$WORKON_HOME" ]; then
        echo "The variable WORKON_HOME is undefined, thus creating the virt. env. in the current directory."
        base=.
        env="venv"
    else
        base=$WORKON_HOME
        pwd=`which pwd`
        here=`$pwd`
        env=`basename "$here"`
    fi
    dir_path="$base/$env"
    if [[ -f ./python_version.txt ]]; then
        read -r py_ver < ./python_version.txt
        virtualenv -p $py_ver "$dir_path"
        echo "cd \"$here\"" > "$dir_path"/cd_project_dir.sh
        echo "cd \"$dir_path\"" > cd_venv_dir.sh
        "$dir_path"/bin/pip install pip -U
        source "$dir_path"/bin/activate
    else
        echo "Error! The file \"python_version.txt\" doesn't exist!"
        echo "Tip: run venv_init first."
    fi
}

# create a temporary project folder with an associated virtual environment in the folder /tmp
# It is not deleted automatically!
# However, /tmp is cleaned upon reboot, so that may be enough.
function venv_tmp () {
    echo -n "Create a temp virt. env. with Python 2 or Python 3 (2, 3): "
    read py_ver
    if [[ "$py_ver" != "2" && "$py_ver" != "3" ]]; then
        echo "Invalid option."
        return 1
    fi
    #
    base=`mktemp -d -t venv_XXXXX`
    cd $base
    env="venv"
    dir_path="$base/$env"
    virtualenv -p python$py_ver "$dir_path"
    "$dir_path"/bin/pip install pip -U
    source "$dir_path"/bin/activate
}

# activate the virtual environment
# call this function in the project folder
# OR (new feature):
# if you are in a direct subfolder of the project folder,
# call it with an argument by specifying where the project folder is, ex.: on ..
function on () {
    proj_dir=$1    # passed as a parameter to the function
    if [ -z "$proj_dir" ]; then
        proj_dir=.
    fi
    proj_dir=`realpath "$proj_dir"`
#    echo "# proj_dir: ${proj_dir}"

    if [ -d "${proj_dir}/venv" ] || [ -z "$WORKON_HOME" ]; then
        base=$proj_dir
        env="venv"
    else
        base=$WORKON_HOME
        env=`basename "$proj_dir"`
    fi

    activate="${base}/${env}/bin/activate"
    echo "# calling ${activate}"

    source "${activate}"
}

# deactivate the virtual environment
alias off='deactivate'

# END: Jabba's Python virtualenv tools
