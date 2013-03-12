#! /bin/bash

# This is an utility shell-script to manage multiple homebrew installations.
# You can install new homebrew environment named "dev" by:
#
#   maltybrew new dev
#
# Then switch to this environment:
#
#   maltybrew switch dev
#
# Now you are in "dev" environment. You can install any formura without
# affecting your default system.
#
#   brew install ruby
#
# To back to the original environment, simply exit the current shell by
# exit command or Ctrl-D.
#
# note:
# maltybrew modifies only PATH and DYLD_LIBRARY_PATH by default. you can add
# additional initialization/cleanup process in .maltybrew/<env-name>/maltyrc.

if [ -z $MALTYBREW_HOME ]; then
    MALTYBREW_HOME=$HOME/.maltybrew
fi

function maltybrew_new {
    local ROOT=$MALTYBREW_HOME/$1

    if [ -z $1 ]; then
        return 1
    elif [ -e $ROOT ]; then
        return 2
    fi

    mkdir -p $MALTYBREW_HOME && mkdir $ROOT
    if [ $? -ne 0 ]; then
        return 3
    fi

    curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C $ROOT
    if [ $? -ne 0 ]; then
        return 4
    fi

    $ROOT/bin/brew update

    cat <<EOF > $ROOT/maltyrc
# -*- mode:shell-script -*-

# \$1: enter or exit
# \$2: ~/.maltybrew/<env-name>

if [ \$1 == enter ]; then

    :
    # Put additional initializations here.
    #
    #export PATH=\$2/share/npm/bin:\$2/share/python:\$2/Cellar/ruby/1.9.3-p362/bin:\$PATH
    #
    #export ORIGINAL_LANG=\$LANG
    #export LANG=C
    #
    #mysql.server status > /dev/null
    #if [ \$? -ne 0 ]; then
    #    mysql.server start
    #    MYSQL_SHOULD_STOP=true
    #fi


else

    :
    # Recover the original environment.
    #
    ## PATH and DYLD_LIBRARY_PATH are recovered implicitly.
    #
    #if [ \$ORIGINAL_LANG ]; then
    #    export LANG=\$ORIGINAL_LANG
    #else
    #    unset LANG
    #fi
    #unset ORIGINAL_LANG
    #
    #if [ \$MYSQL_SHOULD_STOP ]; then
    #    mysql.server stop
    #fi

fi
EOF

    return 0
}

function maltybrew_init {
    local ROOT=$MALTYBREW_HOME/$1

    if [ -z $1 ]; then
        return 1
    elif [ -d $ROOT ]; then

        export MALTYBREW_ORIGINAL_PATH=$PATH
        export MALTYBREW_ORIGINAL_LIBRARY_PATH=$DYLD_LIBRARY_PATH

        export MALTYBREW_NAME=$1
        export DYLD_LIBRARY_PATH=$ROOT/lib:$DYLD_LIBRARY_PATH
        export PATH=$ROOT/bin:$PATH

        if [ -f $ROOT/maltyrc ]; then
            . $ROOT/maltyrc enter $ROOT
        fi

    else
        return 5
    fi

    return 0
}

function maltybrew_cleanup {
    local ROOT=$MALTYBREW_HOME/$MALTYBREW_NAME

    if [ $MALTYBREW_NAME -a -d $ROOT ]; then

        if [ -f $ROOT/maltyrc ]; then
            . $ROOT/maltyrc exit $ROOT
        fi

        export PATH=$MALTYBREW_ORIGINAL_PATH

        if [ $MALTYBREW_ORIGINAL_LIBRARY_PATH ]; then
            export DYLD_LIBRARY_PATH=$MALTYBREW_ORIGINAL_LIBRARY_PATH
        else
            unset DYLD_LIBRARY_PATH
        fi

        unset MALTYBREW_ORIGINAL_PATH
        unset MALTYBREW_ORIGINAL_LIBRARY_PATH
        unset MALTYBREW_NAME

    else
        return 6
    fi

    return 0
}

function maltybrew_list {
    for name in $MALTYBREW_HOME/* ; do
        if [ -d $name ]; then
            echo ${name##*/}
        fi
    done
    return 0
}

function maltybrew_error {
    case $1 in
        0 ) return 0;;
        1 ) echo "Illegal envname." >&2 ;;
        2 ) echo "$MALTYBREW_HOME/$2 is already exist." >&2 ;;
        3 ) echo "mkdir $MALTYBREW_HOME/$2 is failed." >&2 ;;
        4 ) echo "Failed to install homebrew into $MALTYBREW_HOME/$2." >&2 ;;
        5 ) echo "$MALTYBREW_HOME/$2 is not exist nor a directory." >&2 ;;
        6 ) echo "You are not drunk." >&2 ;;
        * ) echo "Unknown error." >&2 ;;
    esac
    if [ -z $3 ]; then
        exit $1
    fi
}

function maltybrew_help {
    cat <<EOF
Create new homebrew installation named "dev":
  maltybrew new dev

Switch to "dev" environment:
  maltybrew switch dev

List all homebrew installations:
  maltybrew list

EOF
}

if [ -z $1 ]; then

    maltybrew_help

elif [ $1 == n -o $1 == new ]; then

    maltybrew_new $2
    maltybrew_error $? $2

elif [ $1 == s -o $1 == switch ]; then

    if [ $MALTYBREW_NAME ]; then
        maltybrew_cleanup
    fi
    maltybrew_init $2
    maltybrew_error $? $2

    $SHELL -i

    if [ $MALTYBREW_NAME ]; then
        maltybrew_cleanup
    fi

elif [ $1 == l -o $1 == list ]; then

    maltybrew_list
    maltybrew_error $? $2

elif [ $1 == switch_inplace ]; then

    if [ $MALTYBREW_NAME ]; then
        maltybrew_cleanup
    fi
    maltybrew_init $2
    maltybrew_error $? $2 no

else

    maltybrew_help

fi
