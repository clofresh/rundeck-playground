alias rd='docker run --rm --network rundeck-playground_default --mount type=bind,source="$(pwd)",target=/root -e RD_PROJECT=hello-project playground-rundeck-cli '
