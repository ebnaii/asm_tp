# tp_asm
TP_ASM 3SI

Some exercices in assembly x64 NASM

Compiled with : 
function asm(){
  if [ $# -ne 1 ]; then
    echo "Usage: asm <file.s>"
    return 1
  fi

  filename="${1%.*}"
  nasm -f elf64 -o "$filename.o" "$1" && ld -o "$filename" "$filename.o" 

}

alias asm='asm'
