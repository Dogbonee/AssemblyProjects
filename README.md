# Building
To build run  
  ``nasm -f elf -o [PROJECT_NAME].o [PROJECT_NAME].asm``  
then  
  ``gcc -no-pie -m32 [PROJECT_NAME].o -o [PROJECT_NAME]``  
then run the executable generated.
