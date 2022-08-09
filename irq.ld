ENTRY(_start)
SECTIONS
{
    . = 0x0;
    .text : { *(.text); }
    .data : { *(.data) }
    . = ALIGN(8);
    . = . + 0x1000; /* 4kB of stack memory */
    stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    pilhaA = .;
    . = . + 0x1000; /* 4kB of stack memory */
    pilhaB = .;
    . = . + 0x1000; /* 4kB of stack memory */
    pilhaINTERRUPT = .;
    . = . + 0x1000; /* 4kB of stack memory */
    pilhaSUPERVISOR = .;
}