#include "idt.h"

extern void isr0();  // From isr.asm

struct idt_entry idt[256];
struct idt_ptr idtp;

static void idt_set_gate(int n, uint32_t handler) {
    idt[n].offset_low = handler & 0xFFFF;
    idt[n].selector = 0x08;
    idt[n].zero = 0;
    idt[n].type_attr = 0x8E;
    idt[n].offset_high = (handler >> 16) & 0xFFFF;
}

void idt_install() {
    idtp.limit = sizeof(idt) - 1;
    idtp.base = (uint32_t)&idt;

    idt_set_gate(0, (uint32_t)isr0);

    asm volatile("lidt %0" : : "m"(idtp));
}
