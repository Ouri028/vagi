CC = v
FILES = main.v
ARGS = -cg


all : ${FILES}
# make only uses tabs and not spaces for indents
	${CC} ${ARGS} run ${FILES}

prod:
	- rm -r ./dist
	- mkdir ./dist
	v ${ARGS} . --prod -o ./dist/touched-agi-v
