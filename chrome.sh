#!/bin/bash

FILE_PATH="list.txt"

# Check if file exists, if not, create it
if [[ ! -e $FILE_PATH ]]; then
    touch $FILE_PATH
fi

echo ""
echo "Welcome to the Chrome launcher script!"
echo "---------------------------------------"
echo ""

create_new_dir() {
    echo ""
    read -p "Please enter the name for the new directory: " new_dir_name
    mkdir "./$new_dir_name"
    echo "$(pwd)/$new_dir_name" >> $FILE_PATH
    echo "New directory '$new_dir_name' has been created and added to the list."
    echo ""
}

start_chrome() {
    dir=$1
    homepage="data:text/html,<h1>$dir</h1>"
    open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="$dir" --no-first-run --no-default-browser-check "$homepage"
    echo "Chrome started with directory '$dir'"
    echo ""
}

choose_directory() {
    if [[ -s $FILE_PATH ]]; then
        echo "Please select a directory:"
        select dir in $(cat $FILE_PATH); do
            if [ -n "$dir" ]; then
                echo "You chose $dir."
                start_chrome "$dir"
                break
            else
                echo "Invalid option."
            fi
        done
    else
        echo "No directories in the list. Please add a new directory first."
    fi
}

remove_dir_from_list() {
    if [[ -s $FILE_PATH ]]; then
      echo ""
      echo "Please select a directory to remove:"
      select dir_name in $(cat $FILE_PATH); do
          if [[ -n $dir_name ]]; then
              # Check if Chrome is running from this directory
              pids=$(pgrep -f "$dir_name" | tr '\n' ',' | sed 's/,$//')
              if [[ -n $pids ]]; then
                  echo "A Chrome instance is running from the directory '$dir_name' with PIDs: $pids."
                  echo "Please close it before deleting the directory !!!"
              else
                  echo "Removing directory..."
                  escaped_dir_name=$(echo $dir_name | sed 's_/_\\/_g')
                  sed -i "" "/$escaped_dir_name/d" $FILE_PATH
                  rm -r "$dir_name"
                  echo "Directory removed."
              fi
              break
          else
              echo "Invalid selection. Please choose a number from the list."
          fi
      done
    else
      echo "No directories in the list. Nothing to remove."
    fi
}

while true; do
    echo "Please choose an option:"
    echo "   - Enter 'n' to create a new directory."
    echo "   - Enter 'l' to choose a directory from the list."
    echo "   - Enter 'r' to remove a directory from the list."
    read choice

    case "$choice" in
        n)  echo "You chose to create a new directory."
            create_new_dir
            start_chrome "$(tail -n 1 $FILE_PATH)"
            break
            ;;
        l)  echo "You chose to select a directory from the list."
            choose_directory
            break
            ;;
        r)  echo "You chose to remove a directory from the list."
            remove_dir_from_list
            break
            ;;
        *)  echo "Invalid option. Please enter 'n', 'l', or 'r'."
            ;;
    esac
done

