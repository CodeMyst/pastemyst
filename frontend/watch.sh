GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

echo "${GREEN}${BOLD}Watching files for changes...${NORMAL}${NC}"

while inotifywait -qq -e close_write **/*; do
    echo "Files changed, compiling..."
    
    if tsout=$(tsc); then
        echo "${GREEN}${BOLD}TypeScript compiled successfully${NORMAL}${NC}"

        if tslint=$(tslint -c tslint.json src/**/*.ts); then
             echo "${GREEN}${BOLD}TypeScript linting OK${NORMAL}${NC}"
        else
            echo "${RED}${BOLD}${tslint}${NORMAL}${NC}"
        fi
    else
        echo "${RED}${BOLD}${tsout}${NORMAL}${NC}"
    fi

    if scss=$(scss src/styles/styles.scss dist/styles/styles.css); then
        echo "${GREEN}${BOLD}SCSS compiled successfully${NORMAL}${NC}"
    else
        echo "${RED}${BOLD}${scss}${NORMAL}${NC}"
    fi

    if pug=$(pug src/views/index.pug -o dist); then
        echo "${GREEN}${BOLD}Pug compiled successfully${NORMAL}${NC}"
    else
        echo "${RED}${BOLD}${pug}${NORMAL}${NC}"
    fi

    cp -r src/assets dist
    echo "${GREEN}${BOLD}Copied all assets${NORMAL}${NC}"
done