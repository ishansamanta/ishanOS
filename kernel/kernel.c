#include "idt.h"

void print_at(const char *msg, int x, int y, unsigned char color) {
    char *vga = (char*)0xB8000;
    int distance = (y * 80 + x) * 2;
    
    for (int i = 0; msg[i] != '\0'; i++) {
        vga[distance + (i * 2)] = msg[i];
        vga[distance + (i * 2) + 1] = color;
    }
}

void clear_screen() {
    char *vga = (char*)0xB8000;
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        vga[i] = ' ';      
        vga[i+1] = 0x07;   
    }
}

void kernel_main() {
    idt_install();
    clear_screen();

   
    print_at(" _____     _                 ____  ____  ", 20, 10, 0x0A);
    print_at("|_   _|   | |               / __ \\/ ___| ", 20, 11, 0x0A);
    print_at("  | |  ___| |__   __ _ _ __| |  | \\___ \\ ", 20, 12, 0x0A);
    print_at("  | | / __| '_ \\ / _` | '_ \\ |  | |   \\ \\", 20, 13, 0x0A);
    print_at(" _| |_\\__ \\ | | | (_| | | | | |__| |___/ /", 20, 14, 0x0A);
    print_at("|_____|___/_| |_|\\__,_|_| |_|\\____/|____/ ", 20, 15, 0x0A);

    
    print_at("--- (c) 2026 All Rights Reserved, by ISHAN ORGANISATION ---", 11, 18, 0x0B); 

    while (1);
}