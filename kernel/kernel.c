void kernel_main(){
	char *vga = (char*)0xB8000;
	const char *msg = "Welcome To Ishan 0S--Ishan";
	for (int i= 0; msg[i]!=0; i++){
		vga[i*2]= msg[i];
		vga[i*2+1]= 0x0F;
	}
    while(1);
}

